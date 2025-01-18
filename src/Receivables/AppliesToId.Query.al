namespace Wanamics.Apply.Receivables;

using Microsoft.Sales.Receivables;
query 87477 "Apply Customer Applies-to ID"
{
    Caption = 'Apply Customer Applies-to ID';
    QueryType = Normal;

    elements
    {
        dataitem(LedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableFilter = Open = const(true), "Applies-to ID" = filter(<> '');
            column(No; "Customer No.") { }
            column(CurrencyCode; "Currency Code") { }
            column(PostingGroup; "Customer Posting Group") { }
            column(AppliestoID; "Applies-to ID") { }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(RemainingAmount; "Remaining Amount")
            {
                Method = Sum;
            }
            column(NoOfEntry)
            {
                Method = Count;
            }
        }
    }
    procedure GetRemainingAmount(pCustLedgerEntry: Record "Cust. Ledger Entry"): Decimal
    begin
        SetRange(No, pCustLedgerEntry."Customer No.");
        SetRange(AppliestoID, pCustLedgerEntry."Applies-to ID");
        SetRange(CurrencyCode, pCustLedgerEntry."Currency Code");
        SetRange(PostingGroup, pCustLedgerEntry."Customer Posting Group");
        Open();
        if Read() then
            exit(RemainingAmount);
    end;
}
