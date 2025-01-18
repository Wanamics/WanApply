namespace Wanamics.Apply;

using Microsoft.Sales.Receivables;
query 87470 OutstCustLedgerEntries
{
    Caption = 'OutstCustLedgerEntries', Locked = true;
    QueryType = Normal;

    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableFilter = Open = const(true), "Applies-to ID" = filter(<> '');
            column(CustomerNo; "Customer No.") { }
            column(CurrencyCode; "Currency Code") { }
            column(CustomerPostingGroup; "Customer Posting Group") { }
            column(AppliestoID; "Applies-to ID") { }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(RemainingAmount; "Remaining Amount")
            {
                Method = Sum;
            }
            column(NoOfEntries)
            {
                Method = Count;
            }
        }
    }
}
