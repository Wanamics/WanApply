namespace Wanamics.Apply.HRPayables;

using Microsoft.HumanResources.Employee;
using System.Utilities;
using Microsoft.HumanResources.Payables;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;
using Microsoft.Finance.ReceivablesPayables;
using System.Security.User;
report 87479 "Apply Employee Applies-to ID"
{
    ApplicationArea = All;
    Caption = 'Apply Employee Applies-to ID';
    UsageCategory = Administration;
    ProcessingOnly = true;
    Permissions = tabledata Employee = M;

    dataset
    {
        dataitem(Entity; Employee)
        {
            RequestFilterFields = "No.";

            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);
                trigger OnPreDataItem()
                begin
                    HoldApplicationMethod := Entity."Application Method";
                    if Entity."Application Method" <> Entity."Application Method"::"Apply to Oldest" then begin
                        Entity."Application Method" := Entity."Application Method"::"Apply to Oldest";
                        Entity.Modify(false);
                    end;
                    ApplyLedgerEntryQuery.SetRange(No, Entity."No.");
                    ApplyLedgerEntryQuery.SetFilter(NoOfEntry, '>1');
                    if RequestAppliestoID <> '' then
                        ApplyLedgerEntryQuery.SetRange(AppliestoID, RequestAppliestoID);
                    ApplyLedgerEntryQuery.Open();
                end;

                trigger OnAfterGetRecord()
                begin
                    if not ApplyLedgerEntryQuery.Read() then
                        CurrReport.Break()
                    else
                        if ApplyLedgerEntryQuery.RemainingAmount = 0 then
                            ApplyAll(ApplyLedgerEntryQuery)
                        else if AllowRemainingAmount then
                            ApplyToInvoice(ApplyLedgerEntryQuery);
                end;

                trigger OnPostDataItem()
                begin
                    if Entity."Application Method" <> HoldApplicationMethod then begin
                        Entity."Application Method" := HoldApplicationMethod;
                        Entity.Modify(false);
                    end;
                end;
            }
            trigger OnPreDataItem()
            var
                ConfirmMsg: Label 'Do you want to apply %1 "%2" based on %3?';
                CustVendLedgerEntry: Record "Employee Ledger Entry";
            begin
                if CurrReport.UseRequestPage then
                    if not Confirm(ConfirmMsg, false, Count(), TableCaption(), CustVendLedgerEntry.FieldCaption("Applies-to ID")) then
                        CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field(RequestAppliestoID; RequestAppliestoID)
                {
                    Caption = 'Applies-to ID';
                    // ApplicationArea = All;
                }
                field(AllowRemainingAmount; AllowRemainingAmount)
                {
                    Caption = 'Allow Remaining Amount';
                }
            }
        }
    }
    var
        ApplyLedgerEntryQuery: Query "Apply Employee Applies-to ID";
        GLSetup: Record "General Ledger Setup";
        ProgressDialog: Codeunit "Progress Dialog";
        HoldApplicationMethod: Enum "Application Method";
        RequestAppliestoID: Code[50];
        AllowRemainingAmount: Boolean;

    trigger OnInitReport()
    var
        UserSetup: Record "User Setup";
    begin
        GLSetup.Get();
#if v19
        if GLSetup."Journal Templ. Name Mandatory" then begin
            GLSetup.TestField("Apply Jnl. Template Name");
            GLSetup.TestField("Apply Jnl. Batch Name");
        end;
#endif
        if UserSetup.Get(UserId) and
            (UserSetup."Allow Posting From" < GLSetup."Allow Posting From") and
            (UserSetup."Allow Posting From" <> 0D) then
            GLSetup."Allow Posting From" := UserSetup."Allow Posting From";
    end;

    local procedure ApplyAll(pQuery: Query "Apply Employee Applies-to ID")
    var
        LedgerEntry: Record "Employee Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        ApplicationDate: Date;
        xLedgerEntry: Record "Employee Ledger Entry";
    begin
        SetFilters(LedgerEntry, pQuery);
        LedgerEntry.SetAutoCalcFields("Remaining Amount");
        if LedgerEntry.FindSet() then
            repeat
                xLedgerEntry := LedgerEntry;
                LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
                // LedgerEntry."Accepted Payment Tolerance" := 0;
                // LedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                Update(LedgerEntry, xLedgerEntry, ApplicationDate);
            until LedgerEntry.Next() = 0;
        Apply(LedgerEntry, ApplicationDate);
        ;
    end;

    local procedure ApplyToInvoice(pQuery: Query "Apply Employee Applies-to ID")
    var
        LedgerEntry: Record "Employee Ledger Entry";
        ApplicationDate: Date;
        xLedgerEntry: Record "Employee Ledger Entry";
        InvoiceLedgerEntry: Record "Employee Ledger Entry";
    begin
        SetFilters(LedgerEntry, pQuery);

        InvoiceLedgerEntry.CopyFilters(LedgerEntry);
        InvoiceLedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::Invoice);
        if InvoiceLedgerEntry.Count <> 1 then
            exit;
        InvoiceLedgerEntry.SetAutoCalcFields("Remaining Amount");
        InvoiceLedgerEntry.FindFirst();
        InvoiceLedgerEntry."Amount to Apply" := 0;
        ApplicationDate := InvoiceLedgerEntry."Posting Date";

        LedgerEntry.SetFilter("Entry No.", '<>%1', InvoiceLedgerEntry."Entry No.");
        LedgerEntry.SetAutoCalcFields("Remaining Amount");
        if LedgerEntry.FindSet() then
            repeat
                xLedgerEntry := LedgerEntry;
                if Abs(LedgerEntry."Remaining Amount") <= Abs(InvoiceLedgerEntry."Remaining Amount" - InvoiceLedgerEntry."Amount to Apply") then
                    LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount"
                else
                    LedgerEntry."Amount to Apply" := -(InvoiceLedgerEntry."Remaining Amount" - InvoiceLedgerEntry."Amount to Apply");
                InvoiceLedgerEntry."Amount to Apply" -= LedgerEntry."Amount to Apply";
                Update(LedgerEntry, xLedgerEntry, ApplicationDate);
            until LedgerEntry.Next() = 0;

        LedgerEntry.SetRange("Entry No.");
        if InvoiceLedgerEntry."Amount to Apply" <> 0 then
            Apply(LedgerEntry, ApplicationDate);
    end;

    local procedure SetFilters(var LedgerEntry: Record "Employee Ledger Entry"; pQuery: Query "Apply Employee Applies-to ID")
    begin
        LedgerEntry.SetCurrentKey("Employee No.", "Applies-to ID");
        LedgerEntry.SetRange(Open, True);
        LedgerEntry.SetRange("Employee No.", pQuery.No);
        LedgerEntry.SetRange("Applies-to ID", pQuery.AppliestoID);
        LedgerEntry.SetRange("Currency Code", pQuery.CurrencyCode);
        LedgerEntry.SetRange("Employee Posting Group", pQuery.PostingGroup);
    end;

    local procedure Update(var LedgerEntry: Record "Employee Ledger Entry"; xLedgerEntry: Record "Employee Ledger Entry"; var ApplicationDate: Date)
    begin
        if (LedgerEntry."Amount to Apply" <> xLedgerEntry."Amount to Apply") /*or
            (LedgerEntry."Accepted Payment Tolerance" <> xLedgerEntry."Accepted Payment Tolerance") or
            (LedgerEntry."Accepted Pmt. Disc. Tolerance" <> xLedgerEntry."Accepted Pmt. Disc. Tolerance") */ then
            Codeunit.Run(Codeunit::"Empl. Entry-Edit", LedgerEntry);
        if LedgerEntry."Posting Date" > ApplicationDate then
            ApplicationDate := LedgerEntry."Posting Date";
    end;

    local procedure Apply(var LedgerEntry: Record "Employee Ledger Entry"; ApplicationDate: Date)
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        ApplyPostedEntries: Codeunit "EmplEntry-Apply Posted Entries";
    begin
        ApplyUnapplyParameters.CopyFromEmplLedgEntry(LedgerEntry);
        ApplyUnapplyParameters."Posting Date" := ApplicationDate;
        if GLSetup."Journal Templ. Name Mandatory" then begin
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        if ApplyUnapplyParameters."Posting Date" < GLSetup."Allow Posting From" then
            ApplyUnapplyParameters."Posting Date" := GLSetup."Allow Posting From";
        ApplyPostedEntries.Apply(LedgerEntry, ApplyUnapplyParameters);
    end;
}