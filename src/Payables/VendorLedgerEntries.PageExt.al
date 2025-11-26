namespace Wanamics.Apply.AppliedEntries;

using Microsoft.Purchases.Payables;
pageextension 87475 "Vendor Ledger Entries" extends "Vendor Ledger Entries"
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
        AppliedEntriesHelper: Codeunit "Applied Entries Helper";
}
