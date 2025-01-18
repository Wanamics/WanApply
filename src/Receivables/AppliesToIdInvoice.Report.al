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
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(InvoiceLedgerEntry; "Cust. Ledger Entry")
        {
            RequestFilterFields = "Customer No.", "Document Type"; // "Document No.", "Applies-to ID", "Posting Date";
            DataItemTableView =
                sorting("Customer No.", "Applies-to ID", Open, Positive, "Due Date")
                where(Open = const(true), Positive = const(true), "Applies-to ID" = filter('<>''''')); //"Document Type" = const("Document Type"::Invoice));
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
                    // InvoiceLedgerEntry.SetAmountToApply();
                    InvoiceLedgerEntry."Amount to Apply" := 0;
                    LedgerEntry.SetFilter("Entry No.", '<>%1', InvoiceLedgerEntry."Entry No.");
                    // LedgerEntry.SetRange(Positive, not InvoiceLedgerEntry.Positive);
                    // if InvoiceLedgerEntry.Positive and (-LedgerEntry."Remaining Amount" > InvoiceLedgerEntry."Remaining Amount") or
                    //     not InvoiceLedgerEntry.Positive and (LedgerEntry."Remaining Amount" > -InvoiceLedgerEntry."Remaining Amount") then
                    // CurrReport.Skip;
                    // HoldApplicationMethod := Entity."Application Method";
                    // if Entity."Application Method" <> Entity."Application Method"::"Apply to Oldest" then begin
                    //     Entity."Application Method" := Entity."Application Method"::"Apply to Oldest";
                    //     Entity.Modify(false);
                    // end;
                    // ApplyLedgerEntryQuery.SetRange(No, Entity."No.");
                    // ApplyLedgerEntryQuery.SetFilter(NoOfEntry, '>1');
                    // if RequestAppliestoID <> '' then
                    //     ApplyLedgerEntryQuery.SetRange(AppliestoID, RequestAppliestoID);
                    // ApplyLedgerEntryQuery.Open();
                end;

                trigger OnAfterGetRecord()
                // var
                //     xLedgerEntry: Record "Cust. Ledger Entry";
                begin
                    // if not ApplyLedgerEntryQuery.Read() then
                    //     CurrReport.Break()
                    // else
                    //     if ApplyLedgerEntryQuery.RemainingAmount = 0 then
                    //         ApplyAll(ApplyLedgerEntryQuery)
                    //     else
                    //         ApplyToInvoice(ApplyLedgerEntryQuery);
                    // SetFilters(LedgerEntry, pQuery);
                    // LedgerEntry.SetAutoCalcFields("Remaining Amount");
                    // if LedgerEntry.FindSet() then
                    //     repeat
                    //         xLedgerEntry := LedgerEntry;
                    //         LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
                    //         LedgerEntry."Accepted Payment Tolerance" := 0;
                    //         LedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                    //         Update(LedgerEntry, xLedgerEntry, ApplicationDate);
                    //     until LedgerEntry.Next() = 0;
                    // Apply(LedgerEntry, ApplicationDate);
                    LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
                    Codeunit.Run(Codeunit::"Cust. Entry-Edit", LedgerEntry);
                    if LedgerEntry."Posting Date" > ApplicationDate then
                        ApplicationDate := LedgerEntry."Posting Date";
                    InvoiceLedgerEntry."Amount to Apply" -= LedgerEntry."Amount to Apply";
                end;

                trigger OnPostDataItem()
                begin
                    // if Entity."Application Method" <> HoldApplicationMethod then begin
                    //     Entity."Application Method" := HoldApplicationMethod;
                    //     Entity.Modify(false);
                    // end;
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
                ConfirmMsg: Label 'Do you want to apply %1 "%2" based on %3?';
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
                ApplyLedgerEntryQuery: Query "Apply Customer Applies-to ID";
            begin
                ProgressDialog.UpdateCopyCount();
                // ApplyLedgerEntryQuery.SetRange(No, "Customer No.");
                // ApplyLedgerEntryQuery.SetRange(AppliestoID, "Applies-to ID");
                // ApplyLedgerEntryQuery.SetRange(CurrencyCode, "Currency Code");
                // ApplyLedgerEntryQuery.SetRange(PostingGroup, "Customer Posting Group");
                // // ApplyLedgerEntryQuery.SetFilter(NoOfEntry, '>1');
                // ApplyLedgerEntryQuery.Open();
                // // if not ApplyLedgerEntryQuery.Read() then
                // //     CurrReport.Break()
                // if (InvoiceLedgerEntry.Positive and (ApplyLedgerEntryQuery.RemainingAmount < 0)) or
                //     (not InvoiceLedgerEntry.Positive and (ApplyLedgerEntryQuery.RemainingAmount > 0)) then
                //     CurrReport.Skip();
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
        // layout
        // {
        //     area(Content)
        //     {
        //         field(RequestAppliestoID; RequestAppliestoID)
        //         {
        //             Caption = 'Applies-to ID';
        //             ApplicationArea = All;
        //         }
        //     }
        // }
    }
    var
        // ApplyLedgerEntryQuery: Query "Apply Customer Applies-to ID";
        GLSetup: Record "General Ledger Setup";
        ProgressDialog: Codeunit "Progress Dialog";
        // HoldApplicationMethod: Enum "Application Method";
        // RequestAppliestoID: Code[50];
        ApplicationDate: Date;
        CountApplied: Integer;

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

    // local procedure ApplyAll(pQuery: Query "Apply Customer Applies-to ID")
    // var
    //     LedgerEntry: Record "Cust. Ledger Entry";
    //     ApplicationDate: Date;
    //     xLedgerEntry: Record "Cust. Ledger Entry";
    // begin
    //     SetFilters(LedgerEntry, pQuery);
    //     LedgerEntry.SetAutoCalcFields("Remaining Amount");
    //     if LedgerEntry.FindSet() then
    //         repeat
    //             xLedgerEntry := LedgerEntry;
    //             LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount";
    //             LedgerEntry."Accepted Payment Tolerance" := 0;
    //             LedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
    //             Update(LedgerEntry, xLedgerEntry, ApplicationDate);
    //         until LedgerEntry.Next() = 0;
    //     Apply(LedgerEntry, ApplicationDate);
    // end;

    // local procedure ApplyToInvoice(pQuery: Query "Apply Customer Applies-to ID")
    // var
    //     LedgerEntry: Record "Cust. Ledger Entry";
    //     ApplicationDate: Date;
    //     xLedgerEntry: Record "Cust. Ledger Entry";
    //     InvoiceLedgerEntry: Record "Cust. Ledger Entry";
    // begin
    //     SetFilters(LedgerEntry, pQuery);

    //     InvoiceLedgerEntry.CopyFilters(LedgerEntry);
    //     InvoiceLedgerEntry.SetRange("Document Type", LedgerEntry."Document Type"::Invoice);
    //     if InvoiceLedgerEntry.Count <> 1 then
    //         exit;
    //     InvoiceLedgerEntry.SetAutoCalcFields("Remaining Amount");
    //     InvoiceLedgerEntry.FindFirst();
    //     InvoiceLedgerEntry."Amount to Apply" := 0;
    //     ApplicationDate := InvoiceLedgerEntry."Posting Date";

    //     LedgerEntry.SetFilter("Entry No.", '<>%1', InvoiceLedgerEntry."Entry No.");
    //     LedgerEntry.SetAutoCalcFields("Remaining Amount");
    //     if LedgerEntry.FindSet() then
    //         repeat
    //             xLedgerEntry := LedgerEntry;
    //             if Abs(LedgerEntry."Remaining Amount") <= Abs(InvoiceLedgerEntry."Remaining Amount" - InvoiceLedgerEntry."Amount to Apply") then
    //                 LedgerEntry."Amount to Apply" := LedgerEntry."Remaining Amount"
    //             else
    //                 LedgerEntry."Amount to Apply" := -(InvoiceLedgerEntry."Remaining Amount" - InvoiceLedgerEntry."Amount to Apply");
    //             InvoiceLedgerEntry."Amount to Apply" -= LedgerEntry."Amount to Apply";
    //             Update(LedgerEntry, xLedgerEntry, ApplicationDate);
    //         until LedgerEntry.Next() = 0;

    //     LedgerEntry.SetRange("Entry No.");
    //     if InvoiceLedgerEntry."Amount to Apply" <> 0 then
    //         Apply(LedgerEntry, ApplicationDate);
    // end;

    // local procedure SetFilters(var LedgerEntry: Record "Cust. Ledger Entry"; pQuery: Query "Apply Customer Applies-to ID")
    // begin
    //     LedgerEntry.SetCurrentKey("Customer No.", "Applies-to ID");
    //     LedgerEntry.SetRange(Open, True);
    //     LedgerEntry.SetRange("Customer No.", pQuery.No);
    //     LedgerEntry.SetRange("Applies-to ID", pQuery.AppliestoID);
    //     LedgerEntry.SetRange("Currency Code", pQuery.CurrencyCode);
    //     LedgerEntry.SetRange("Customer Posting Group", pQuery.PostingGroup);
    // end;

    // local procedure Update(var LedgerEntry: Record "Cust. Ledger Entry"; xLedgerEntry: Record "Cust. Ledger Entry"; var ApplicationDate: Date)
    // begin
    //     if (LedgerEntry."Amount to Apply" <> xLedgerEntry."Amount to Apply") or
    //         (LedgerEntry."Accepted Payment Tolerance" <> xLedgerEntry."Accepted Payment Tolerance") or
    //         (LedgerEntry."Accepted Pmt. Disc. Tolerance" <> xLedgerEntry."Accepted Pmt. Disc. Tolerance") then
    //         Codeunit.Run(Codeunit::"Cust. Entry-Edit", LedgerEntry);
    //     if LedgerEntry."Posting Date" > ApplicationDate then
    //         ApplicationDate := LedgerEntry."Posting Date";
    // end;

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