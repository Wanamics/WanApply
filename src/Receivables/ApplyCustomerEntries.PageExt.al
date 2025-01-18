namespace Wanamics.Apply;

using Microsoft.Sales.Receivables;
pageextension 87470 "Apply Customer Entries" extends "Apply Customer Entries"
{
    layout
    {
        Modify(ApplyingDescription)
        {
            Visible = false;
        }
        addafter(ApplyingDescription)
        {
            field(wanApplyingDescription; TempApplyingCustLedgEntry.Description)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Description';
                Editable = false;
                MultiLine = true;
            }
            field(wanApplyingExternalDocumentNo; TempApplyingCustLedgEntry."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'External Document No.';
                Editable = false;
            }
        }
    }
}
