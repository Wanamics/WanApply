namespace Wanamics.Apply;

using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;
pageextension 87472 "Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Applies-to ID"; Rec."Applies-to ID")
            {
                Editable = true;
                ApplicationArea = All;
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
}
