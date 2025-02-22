namespace Wanamics.Apply.HRPayables;

using Microsoft.HumanResources.Payables;
query 87479 "Apply Employee Applies-to ID"
{
    Caption = 'Apply Employee Applies-to ID';
    QueryType = Normal;

    elements
    {
        dataitem(LedgerEntry; "Employee Ledger Entry")
        {
            DataItemTableFilter = Open = const(true), "Applies-to ID" = filter(<> '');
            column(No; "Employee No.") { }
            column(CurrencyCode; "Currency Code") { }
            column(PostingGroup; "Employee Posting Group") { }
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
}
