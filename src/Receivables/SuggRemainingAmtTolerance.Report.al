namespace Wanamics.Apply;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;

report 87471 "Sugg. Remaining Amt. Tolerance"
{
    Caption = 'Suggest Remaining Amount Tolerance';
    ProcessingOnly = true;
    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableView = where(Open = const(true));
            RequestFilterFields = "Customer No.", "Remaining Amount", "Posting Date", "Currency Code";
            CalcFields = Amount, "Remaining Amount";

            trigger OnPreDataItem()
            var
                ConfirmLbl: Label 'Do-you want to suggest payment tolerance by "%1" for %2 "%3"?', Comment = '%1:FieldCaption("Remaining Amount"), %2:Count, %3:TableCaption';
            begin
                if not Confirm(ConfirmLbl, false, FieldCaption("Remaining Amount"), Count, TableCaption) then
                    CurrReport.Quit();
                ProgressDialog.OpenCopyCountMax(' ', Count);
            end;

            trigger OnAfterGetRecord()
            begin
                ProgressDialog.UpdateCopyCount();
                InsertGenJournalLine(CustLedgerEntry);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        trigger OnOpenPage()
        begin
            if CustLedgerEntry.GetFilter("Remaining Amount") = '' then
                CustLedgerEntry.SetRange("Remaining Amount", -GLSetup."Max. Payment Tolerance Amount", GLSetup."Max. Payment Tolerance Amount");
        end;
    }
    trigger OnInitReport()
    begin
        GLSetup.Get();
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Default: Record "Gen. Journal Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        ProgressDialog: Codeunit "Progress Dialog";

    procedure SetGenJournalLine(var pGenJournalLine: Record "Gen. Journal Line")
    var
        JournalMustBeEmptyErr: Label 'Journal must be empty';
    begin
        Default.SetRange("Journal Template Name", pGenJournalLine."Journal Template Name");
        Default.SetRange("Journal Batch Name", pGenJournalLine."Journal Batch Name");
        if not Default.IsEmpty then
            Error(JournalMustBeEmptyErr);
        Default := pGenJournalLine;
        Default.Validate("Document Type", Default."Document Type"::" ");
        Default.Validate("Account Type", Default."Account Type"::Customer);
        Default.Validate("Bal. Account Type", Default."Account Type"::"G/L Account");
    end;

    local procedure InsertGenJournalLine(CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Default."Line No." += 10000;
        GenJournalLine := Default;
        if CustLedgerEntry."Posting Date" < GLSetup."Allow Posting From" then
            GenJournalLine.Validate("Posting Date", GLSetup."Allow Posting From")
        else
            GenJournalLine.Validate("Posting Date", CustLedgerEntry."Posting Date");
        GenJournalLine.Validate("Document No.", CustLedgerEntry."Document No.");
        GenJournalLine.Validate("External Document No.", CustLedgerEntry."External Document No.");
        GenJournalLine.Validate("Account No.", CustLedgerEntry."Customer No.");
        GenJournalLine.Validate(Description, CustLedgerEntry.Description);
        GenJournalLine.Validate("Currency Code", CustLedgerEntry."Currency Code");
        GenJournalLine.Validate(Amount, -CustLedgerEntry."Remaining Amount");
        if CustLedgerEntry."Customer Posting Group" <> CustomerPostingGroup.Code then
            CustomerPostingGroup.Get(CustLedgerEntry."Customer Posting Group");
        if CustLedgerEntry.Amount > 0 then
            GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Debit Acc.")
        else
            GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Credit Acc.");
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::" " then
            GenJournalLine.Validate("Applies-to ID", CustLedgerEntry."Applies-to ID")
        else begin
            GenJournalLine.Validate("Applies-to Doc. Type", CustLedgerEntry."Document Type");
            GenJournalLine.Validate("Applies-to Doc. No.", CustLedgerEntry."Document No.");
        end;
        GenJournalLine.Validate("Applies-to Ext. Doc. No.", CustLedgerEntry."External Document No.");
        GenJournalLine.Validate("Dimension Set ID", CustLedgerEntry."Dimension Set ID");
        GenJournalLine.Insert(true);
    end;
}
