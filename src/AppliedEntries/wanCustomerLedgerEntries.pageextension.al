namespace Wanamics.Apply.AppliedEntries;

using Microsoft.Sales.Receivables;
pageextension 87474 "wan Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field(AppliedToCode; AppliedEntriesHelper.AppliedToCode(Rec."Entry No.", Rec.Open, Rec."Closed by Entry No."))
            {
                Caption = 'Applied-to Code';
                Width = 6;
                Editable = false;
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
    var
        AppliedEntriesHelper: Codeunit "wan Applied Entries Helper";
}
