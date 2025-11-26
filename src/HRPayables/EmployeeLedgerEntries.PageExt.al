namespace Wanamics.Apply.AppliedEntries;

using Microsoft.HumanResources.Payables;
pageextension 87476 "Employee Ledger Entries" extends "Employee Ledger Entries"
{
    layout
    {
        addlast(Group)
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
