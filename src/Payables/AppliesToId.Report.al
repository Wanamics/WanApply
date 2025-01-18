namespace Wanamics.Apply.Payables;

using Microsoft.Purchases.Vendor;
using System.Utilities;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;
using Microsoft.Finance.ReceivablesPayables;
using System.Security.User;
report 87478 "Apply Vendor Applies-to ID"
{
    ApplicationArea = All;
    Caption = 'Apply Vendor Applies-to ID';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Entity; Vendor)
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
                    ApplyLedgerEntryQuery.Open();
                end;

                trigger OnAfterGetRecord()
                begin
                    if not ApplyLedgerEntryQuery.Read() then
                        CurrReport.Break()
                    else
                        if ApplyLedgerEntryQuery.RemainingAmount = 0 then
                            Apply(ApplyLedgerEntryQuery);
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
                CustVendLedgerEntry: Record "Vendor Ledger Entry";
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
    }
    var
        ApplyLedgerEntryQuery: Query "Apply Vendor Applies-to ID";
        GLSetup: Record "General Ledger Setup";
        ProgressDialog: Codeunit "Progress Dialog";
        HoldApplicationMethod: Enum "Application Method";

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

    local procedure Apply(pQuery: Query "Apply Vendor Applies-to ID")
    var
        LedgerEntry: Record "Vendor Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
        ApplicationDate: Date;
        xLedgerEntry: Record "Vendor Ledger Entry";
        HasDebit, HasCredit : boolean;
    begin
        LedgerEntry.SetCurrentKey("Vendor No.", "Applies-to ID");
        LedgerEntry.SetRange("Vendor No.", pQuery.No);
        LedgerEntry.SetRange("Applies-to ID", pQuery.AppliestoID);
        LedgerEntry.SetRange(Open, True);
        LedgerEntry.SetRange("Currency Code", pQuery.CurrencyCode);
        LedgerEntry.SetRange("Vendor Posting Group", pQuery.PostingGroup);
        LedgerEntry.SetAutoCalcFields("Remaining Amount");

        if LedgerEntry.FindSet() then
            repeat
                xLedgerEntry := LedgerEntry;
                // if LedgerEntry."Amount to Apply" = 0 then begin
                // LedgerEntry.CalcFields("Remaining Amount");
                LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
                // end else
                //     LedgerEntry."Amount to Apply" := 0;
                LedgerEntry."Accepted Payment Tolerance" := 0;
                LedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                if (LedgerEntry."Amount to Apply" <> xLedgerEntry."Amount to Apply") or
                    (LedgerEntry."Accepted Payment Tolerance" <> xLedgerEntry."Accepted Payment Tolerance") or
                    (LedgerEntry."Accepted Pmt. Disc. Tolerance" <> xLedgerEntry."Accepted Pmt. Disc. Tolerance") then
                    Codeunit.Run(Codeunit::"Vend. Entry-Edit", LedgerEntry);
                if LedgerEntry."Posting Date" > ApplicationDate then
                    ApplicationDate := LedgerEntry."Posting Date";
                if LedgerEntry."Remaining Amount" > 0 then
                    HasDebit := true;
                if LedgerEntry."Remaining Amount" < 0 then
                    HasCredit := true;
            until LedgerEntry.Next() = 0;

        if HasDebit and HasCredit then begin
            ApplyUnapplyParameters.CopyFromVendLedgEntry(LedgerEntry);
            ApplyUnapplyParameters."Posting Date" := ApplicationDate;
            if GLSetup."Journal Templ. Name Mandatory" then begin
                ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
                ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
            end;
            if ApplyUnapplyParameters."Posting Date" < GLSetup."Allow Posting From" then
                ApplyUnapplyParameters."Posting Date" := GLSetup."Allow Posting From";
            VendEntryApplyPostedEntries.Apply(LedgerEntry, ApplyUnapplyParameters);
        end;
    end;
}