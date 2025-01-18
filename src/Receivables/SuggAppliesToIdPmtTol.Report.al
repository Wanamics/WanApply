namespace Wanamics.Apply;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
report 87470 "Sugg. Applies-to ID Tolerance"
{
    Caption = 'Suggest Applies-to ID Tolerance';
    ApplicationArea = All;
    UsageCategory = None;
    ProcessingOnly = true;
    Permissions = TableData "Cust. Ledger Entry" = rimd;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            dataitem(Integer; Integer)
            {
                DataItemTableView = sorting(Number);
                trigger OnPreDataItem()
                begin
                    OutstCustLedgerEntries.SetRange(CustomerNo, Customer."No.");
                    // OutstCustLedgerEntries.SetFilter(NoOfEntries, '>1');
                    OutstCustLedgerEntries.SetFilter(RemainingAmount, RemainingAmountFilter);
                    OutstCustLedgerEntries.Open();
                end;

                trigger OnAfterGetRecord()
                var
                    PostingDate: Date;
                begin
                    if not OutstCustLedgerEntries.Read() then
                        CurrReport.Break()
                    else if Abs(OutstCustLedgerEntries.RemainingAmount) <= Abs(MaxPaymentToleranceAmount) then begin
                        SetAmountToApply(OutstCustLedgerEntries, PostingDate);
                        InsertGenJournalLine(OutstCustLedgerEntries, PostingDate);
                    end;
                end;
            }
            trigger OnPreDataItem()
            var
                ConfirmLbl: Label 'Do-you want to suggest payment tolerance by "%1" for %2 "%3"?', Comment = '%1:FieldCaption("Applies-to ID", %2 Count, %3:TableCaption';
                TempGenJournalLine: Record "Gen. Journal Line" temporary;
            begin
                if not Confirm(ConfirmLbl, false, TempGenJournalLine.FieldCaption("Applies-to ID"), Count, TableCaption) then
                    CurrReport.Quit();
                Progress.Open('#1 #2', "No.", Name);
                RemainingAmountFilter := StrSubstNo('-%1..%1&<>0', Abs(MaxPaymentToleranceAmount));
            end;

            trigger OnAfterGetRecord()
            begin
                Progress.Update();
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
                group(Options)
                {
                    Caption = 'Options';
                    field(PaymentTolerance; MaxPaymentToleranceAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Max. Payment Tolerance Amount';
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            if MaxPaymentToleranceAmount = 0 then
                MaxPaymentToleranceAmount := GLSetup."Max. Payment Tolerance Amount";
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
        Progress: Dialog;
        OutstCustLedgerEntries: Query OutstCustLedgerEntries;
        MaxPaymentToleranceAmount: Decimal;
        RemainingAmountFilter: Text;

    procedure SetGenJournalLine(var pGenJournalLine: Record "Gen. Journal Line")
    var
        JournalMustBeEmptyErr: Label 'Journal must be empty';
    begin
        Default.SetRange("Journal Template Name", pGenJournalLine."Journal Template Name");
        Default.SetRange("Journal Batch Name", pGenJournalLine."Journal Batch Name");
        if not Default.IsEmpty then
            Error(JournalMustBeEmptyErr);
        Default := pGenJournalLine;
        // Default.Validate("Posting Date", WorkDate());
        Default.Validate("Document Type", Default."Document Type"::" ");
        Default.Validate("Account Type", Default."Account Type"::Customer);
        Default.Validate("Bal. Account Type", Default."Account Type"::"G/L Account");
    end;

    local procedure InsertGenJournalLine(pQuery: Query OutstCustLedgerEntries; pPostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        DescriptionLbl: Label 'Payment Tolerance %1 %2', Comment = '%1:FieldCaption("Applies-to ID"), %2:"Applies-to ID"';
    begin
        Default."Line No." += 10000;
        GenJournalLine := Default;
        GenJournalLine.Validate("Posting Date", pPostingDate);
        GenJournalLine.Validate("Account No.", pQuery.CustomerNo);
        GenJournalLine.Validate(Description, StrSubstNo(DescriptionLbl, GenJournalLine.FieldCaption("Applies-to ID"), pQuery.AppliestoID));
        GenJournalLine.Validate("Currency Code", pQuery.CurrencyCode);
        GenJournalLine.Validate(Amount, -pQuery.RemainingAmount);
        GenJournalLine.Validate("External Document No.", pQuery.AppliestoID);
        if pQuery.CustomerPostingGroup <> CustomerPostingGroup.Code then
            CustomerPostingGroup.Get(pQuery.CustomerPostingGroup);
        if pQuery.Amount > 0 then
            GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Debit Acc.")
        else
            GenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Credit Acc.");
        GenJournalLine.Validate("Applies-to ID", pQuery.AppliestoID);
        GenJournalLine.Insert(true);
    end;

    local procedure SetAmountToApply(pOutstCustLedgerEntries: Query OutstCustLedgerEntries; var pPostingDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LastOne: Integer;
    begin
        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date", "Applies-to ID");
        CustLedgerEntry.SetRange("Customer No.", pOutstCustLedgerEntries.CustomerNo);
        CustLedgerEntry.SetRange("Applies-to ID", pOutstCustLedgerEntries.AppliestoID);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Currency Code", pOutstCustLedgerEntries.CurrencyCode);
        CustLedgerEntry.SetRange("Customer Posting Group", pOutstCustLedgerEntries.CustomerPostingGroup);
        CustLedgerEntry.SetAscending("Posting Date", false);
        CustLedgerEntry.FindSet();
        LastOne := CustLedgerEntry."Entry No.";
        pPostingDate := CustLedgerEntry."Posting Date";
        repeat
            CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
            CustLedgerEntry."Applying Entry" := CustLedgerEntry."Entry No." = LastOne;
            CustLedgerEntry.Modify();
        until CustLedgerEntry.Next() = 0;
    end;
}
