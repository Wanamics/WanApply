namespace Wanamics.Apply.Receivables;

using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;
using Microsoft.Finance.ReceivablesPayables;
using System.Security.User;
report 87476 "Apply Applies-to ID/Cust.Inv."
{
    ApplicationArea = All;
    Caption = 'Apply Applies-to ID to Invoices';
    ToolTip = 'This report applies open customer ledger entries with an Applies-to ID to open customer invoices with the same Applies-to ID.';
    ;
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(InvoiceLedgerEntry; "Cust. Ledger Entry")
        {
            RequestFilterFields = "Customer No.", "Document Type";
            DataItemTableView =
                sorting("Customer No.", "Applies-to ID", Open, Positive, "Due Date")
                where(Open = const(true), Positive = const(true), "Applies-to ID" = filter('<>'''''));
            CalcFields = "Remaining Amount";

            dataitem(LedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLinkReference = InvoiceLedgerEntry;
                DataItemLink =
                    "Customer No." = field("Customer No."),
                    "Applies-to ID" = field("Applies-to ID"),
                    "Currency Code" = field("Currency Code"),
                    "Customer Posting Group" = field("Customer Posting Group");
                DataItemTableView = sorting("Customer No.", "Applies-to ID", Open, Positive, "Due Date") where(Open = const(true));
                CalcFields = "Remaining Amount";
                trigger OnPreDataItem()
                begin
                    InvoiceLedgerEntry."Amount to Apply" := 0;
                    LedgerEntry.SetFilter("Entry No.", '<>%1', InvoiceLedgerEntry."Entry No.");
                end;

                trigger OnAfterGetRecord()
                begin
                    LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
                    Codeunit.Run(Codeunit::"Cust. Entry-Edit", LedgerEntry);
                    if LedgerEntry."Posting Date" > ApplicationDate then
                        ApplicationDate := LedgerEntry."Posting Date";
                    InvoiceLedgerEntry."Amount to Apply" -= LedgerEntry."Amount to Apply";
                end;

                trigger OnPostDataItem()
                begin
                    if InvoiceLedgerEntry."Amount to Apply" <> 0 then begin
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", InvoiceLedgerEntry);
                        if InvoiceLedgerEntry."Posting Date" > ApplicationDate then
                            ApplicationDate := InvoiceLedgerEntry."Posting Date";
                        Apply(InvoiceLedgerEntry, ApplicationDate);
                        CountApplied += 1;
                    end;
                end;
            }
            trigger OnPreDataItem()
            var
                ConfirmMsg: Label 'Do you want to apply %1 "%2" based on %3?', Comment = '%1:Count, %2:TableCaption, %3:FieldCaption("Applies-to ID"';
            begin
                if GetFilter("Applies-to ID") = '' then
                    SetFilter("Applies-to ID", '<>%1', '');
                if CurrReport.UseRequestPage then
                    if not Confirm(ConfirmMsg, false, Count(), TableCaption(), LedgerEntry.FieldCaption("Applies-to ID")) then
                        CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax(TableCaption, Count);
            end;

            trigger OnAfterGetRecord()
            var
                ApplyLedgerEntryQuery: Query "Customer Apply Applies-to ID";
            begin
                ProgressDialog.UpdateCopyCount();
                if Positive then
                    if not (ApplyLedgerEntryQuery.GetRemainingAmount(InvoiceLedgerEntry) in [0 .. "Remaining Amount"]) then
                        CurrReport.Skip();
                if not Positive then
                    if not (ApplyLedgerEntryQuery.GetRemainingAmount(InvoiceLedgerEntry) in ["Remaining Amount" .. 0]) then
                        CurrReport.Skip();
            end;

            trigger OnPostDataItem()
            var
                DoneLbl: Label '%1 "%2" applied.';
            begin
                Message(DoneLbl, CountApplied, TableCaption)
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    var
        GLSetup: Record "General Ledger Setup";
        ProgressDialog: Codeunit "Progress Dialog";
        ApplicationDate: Date;
        CountApplied: Integer;

    trigger OnInitReport()
    var
        UserSetup: Record "User Setup";
    begin
        GLSetup.Get();
        if UserSetup.Get(UserId) and
            (UserSetup."Allow Posting From" < GLSetup."Allow Posting From") and
            (UserSetup."Allow Posting From" <> 0D) then
            GLSetup."Allow Posting From" := UserSetup."Allow Posting From";
    end;

    local procedure Apply(var LedgerEntry: Record "Cust. Ledger Entry"; ApplicationDate: Date)
    var
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        ApplyUnapplyParameters.CopyFromCustLedgEntry(LedgerEntry);
        ApplyUnapplyParameters."Posting Date" := ApplicationDate;
        if GLSetup."Journal Templ. Name Mandatory" then begin
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        if ApplyUnapplyParameters."Posting Date" < GLSetup."Allow Posting From" then
            ApplyUnapplyParameters."Posting Date" := GLSetup."Allow Posting From";
        CustEntryApplyPostedEntries.Apply(LedgerEntry, ApplyUnapplyParameters);
    end;
}