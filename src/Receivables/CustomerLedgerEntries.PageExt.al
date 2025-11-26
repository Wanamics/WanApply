namespace Wanamics.Apply;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
using Wanamics.Apply.AppliedEntries;
pageextension 87472 "Customer Ledger Entries" extends "Customer Ledger Entries"
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
    actions
    {
        addlast("F&unctions")
        {
            action(wanTransfer)
            {
                Caption = 'Transfer';
                Ellipsis = true;
                Image = TransferFunds;
                ApplicationArea = All;
                trigger OnAction()
                var
                    lRec: Record "Cust. Ledger Entry";
                begin
                    lRec.Copy(Rec);
                    CurrPage.SetSelectionFilter(lRec);
                    Codeunit.Run(Codeunit::"Transfer Cust. Ledger Entry", lRec);
                end;
            }
            action(wanApplyAppliesToID)
            {
                Caption = 'Apply Applies-to ID';
                Ellipsis = true;
                Image = ApplyEntries;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Customer: Record "Customer";
                begin
                    Customer.Get(Rec."Customer No.");
                    Codeunit.Run(Codeunit::"Apply Cust. Ledger Entries", Customer);
                end;
            }
            action(wanCloseAsLost)
            {
                Caption = 'Close as Lost';
                Ellipsis = true;
                Image = GainLossEntries;
                ApplicationArea = All;
                trigger OnAction()
                var
                    lRec: Record "Cust. Ledger Entry";
                begin
                    lRec.Copy(Rec);
                    CurrPage.SetSelectionFilter(lRec);
                    Codeunit.Run(Codeunit::"Close as Lost", lRec);
                end;
            }
        }
    }
    var
        AppliedEntriesHelper: Codeunit "Applied Entries Helper";
}
