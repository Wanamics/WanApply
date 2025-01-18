namespace Wanamics.Apply;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 87471 "Cash Receipt Journal" extends "Cash Receipt Journal"
{
    actions
    {
        addlast("F&unctions")
        {
            action(wanSuggestCustPaymentTolerance)
            {
                Caption = 'Suggest Remaining Amount Payment Tolerance';
                ApplicationArea = All;
                Ellipsis = true;
                Image = ChangePaymentTolerance;
                trigger OnAction()
                var
                    SuggestPaymentTolerance: Report "Sugg. Remaining Amt. Tolerance";
                begin
                    SuggestPaymentTolerance.SetGenJournalLine(Rec);
                    SuggestPaymentTolerance.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(wanSuggestAppliesToIDPaymentTolerance)
            {
                Caption = 'Suggest Applies-to ID Payment Tolerance';
                ApplicationArea = All;
                Ellipsis = true;
                Image = ChangePaymentTolerance;
                trigger OnAction()
                var
                    SuggestPaymentTolerance: Report "Sugg. Applies-to ID Tolerance";
                begin
                    SuggestPaymentTolerance.SetGenJournalLine(Rec);
                    SuggestPaymentTolerance.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
