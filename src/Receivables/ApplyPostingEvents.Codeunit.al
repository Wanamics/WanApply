namespace Wanamics.Apply.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;

codeunit 87473 "WanApply Posting Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeCheckIfPostingDateIsEarlier, '', false, false)]
    local procedure OnBeforeCheckIfPostingDateIsEarlier(GenJournalLine: Record "Gen. Journal Line"; ApplyPostingDate: Date; ApplyDocType: Option " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund; ApplyDocNo: Code[20]; var IsHandled: Boolean; RecordVariant: Variant; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        // Text015: Label 'You are not allowed to apply and post an entry to an entry with an earlier posting date.\\Instead, post %1 %2 and then apply it to %3 %4.';
        Text015: Label 'You are not allowed to apply and post an entry to an entry with an earlier posting date.\\Instead, post %1 %2 and then apply it to %3 %4.\%5 %6.';
    begin
        if GenJournalLine."Posting Date" < ApplyPostingDate then
            Error(
            //   Text015, GenJournalLine."Document Type", GenJournalLine."Document No.", ApplyDocType, ApplyDocNo);
              Text015, GenJournalLine."Document Type", GenJournalLine."Document No.", ApplyDocType, ApplyDocNo,
              GenJournalLine.FieldCaption("Applies-to ID"), GenJournalLine."Applies-to ID");
    end;
}
