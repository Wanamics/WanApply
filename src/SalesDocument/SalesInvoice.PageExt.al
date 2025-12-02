namespace Wanamics.Apply;

using Microsoft.Sales.Document;

pageextension 87477 "Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addbefore("Work Description")
        {
            field("Applies-to ID"; Rec."Applies-to ID")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the ID of entries that will be applied to when you choose the Apply Entries action.';
            }
        }
    }
}
