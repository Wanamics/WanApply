namespace Wanamics.Apply.Receivables;

using Microsoft.Sales.Receivables;
query 87477 "Customer Apply Applies-to ID"
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
    procedure GetRemainingAmount(pEntry: Record "Cust. Ledger Entry"): Decimal
    begin
        SetRange(No, pEntry."Customer No.");
        SetRange(AppliestoID, pEntry."Applies-to ID");
        SetRange(CurrencyCode, pEntry."Currency Code");
        SetRange(PostingGroup, pEntry."Customer Posting Group");
        Open();
        if Read() then
            exit(RemainingAmount);
    end;
}
