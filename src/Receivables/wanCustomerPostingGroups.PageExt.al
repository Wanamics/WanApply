namespace WanApply.WanApply;

using Microsoft.Sales.Customer;

pageextension 87473 "Customer Posting Groups" extends "Customer Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("wan Close Entry Debit Acc."; Rec."wan Close Entry Debit Acc.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Close Entry Debit Acc. field.', Comment = '%';
            }
            field("wan Close Entry Credit Acc."; Rec."wan Close Entry Credit Acc.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Close Entry Credit field.', Comment = '%';
            }
        }
    }
}
