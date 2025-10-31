namespace Wanamics.Apply;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Customer;
Codeunit 87474 "Close as Lost"
{
    TableNo = "Cust. Ledger Entry";

    trigger OnRun()
    var
        ConfirmLbl: label 'Do you want to close %1 "%2" as lost on %3?', Comment = '%1:Count, %2:TableCaption, %3:PostingDate';
        DoneLbl: label '%1 "%2" closed as lost in %3.';
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        lCount: Integer;
        StartDateTime: DateTime;
    begin
        CheckEntry(Rec);
        if not Confirm(ConfirmLbl, false, Rec.Count, Rec.TableCaption, WorkDate()) then
            exit;
        StartDateTime := CurrentDateTime;
        lCount := Rec.Count;
        CloseAslost(Rec); //, TempGenJournalLine);
        Message(StrSubstNo(DoneLbl, lCount, Rec.TableCaption, CurrentDateTime - StartDateTime));
    end;

    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CustomerPostingGroup: Record "Customer Posting Group";

    local procedure CheckEntry(var pRec: Record "Cust. Ledger Entry")
    var
        AlreadyClosedErr: Label '%1 "%2" are already closed', Comment = '%1:Count, %2:TableCaption';
    begin
        pRec.SetRange(Open, false);
        if not pRec.IsEmpty() then
            Error(AlreadyClosedErr, pRec.Count, pRec.TableCaption);
        pRec.SetRange(Open, true);
    end;

    local procedure CLoseAsLost(var pRec: Record "Cust. Ledger Entry"); //; pTempGenJournalLine: Record "Gen. Journal Line")
    var
        lGenJournalLine: Record "Gen. Journal Line";
    // AppliesToId: Code[50];
    begin
        pRec.CalcFields("Remaining Amount");
        if pRec.FindSet then
            repeat
                // AppliesToId := pRec."Applies-to ID";
                ToGenJournalLine(pRec, lGenJournalLine);//, pTempGenJournalLine."Posting Date");
                lGenJournalLine.Validate("Applies-to Doc. Type", pRec."Document Type");
                lGenJournalLine.Validate("Applies-to Doc. No.", pRec."Document No.");
                lGenJournalLine.Validate("Amount", -pRec."Remaining Amt. (LCY)"); //-pRec.Amount);
                lGenJournalLine."Sales/Purch. (LCY)" := 0; //-pRec."Sales (LCY)";
                if pRec."Customer Posting Group" <> CustomerPostingGroup.Code then
                    CustomerPostingGroup.Get(pRec."Customer Posting Group");
                if lGenJournalLine.Amount < 0 then
                    // lGenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Debit Acc.")
                    lGenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."wan Close Entry Debit Acc.")
                else
                    // lGenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."Payment Tolerance Credit Acc.");
                    lGenJournalLine.Validate("Bal. Account No.", CustomerPostingGroup."wan Close Entry Credit Acc.");
                Append(lGenJournalLine.Description, '/' + lGenJournalLine."Bal. Account No.");
                GenJnlPostLine.Run(lGenJournalLine);

            until pRec.Next = 0;
    end;

    local procedure ToGenJournalLine(var pRec: Record "Cust. Ledger Entry"; var pGenJournalLine: Record "Gen. Journal Line"); //; pPostingDate: Date)
    begin
        Clear(pGenJournalLine);
        pGenJournalLine."Posting Date" := WorkDate();
        pGenJournalLine."Document No." := pRec."Document No.";
        pGenJournalLine.Validate("Account Type", pGenJournalLine."Account Type"::"Customer");
        pGenJournalLine.Validate("Account No.", pRec."Customer No.");
        pGenJournalLine.Description := pRec.Description;
        pGenJournalLine."Document Date" := pRec."Document Date";
        pGenJournalLine."Due Date" := pRec."Due Date";
        pGenJournalLine."External Document No." := pRec."External Document No.";
        pGenJournalLine."Source Code" := pRec."Source Code";
        pGenJournalLine."Shortcut Dimension 1 Code" := pRec."Global Dimension 1 Code";
        pGenJournalLine."Shortcut Dimension 2 Code" := pRec."Global Dimension 2 Code";
        pGenJournalLine."Dimension Set ID" := pRec."Dimension Set ID";
        pGenJournalLine."Salespers./Purch. Code" := pRec."Salesperson Code";
    end;

    local procedure Append(var pDescription: Text; pAppend: Text)
    begin
        if StrLen(pDescription) + 1 + StrLen(pAppend) > MaxStrLen(pDescription) then
            pDescription := pDescription.Substring(1, MaxStrLen(pDescription) - StrLen(pAppend) - 1);
        pDescription += /*' ' +*/ pAppend;
    end;

    // local procedure Append(var pCode: Code[20]; pAppend: Text)
    // var
    //     Text20: Text[20];
    // begin
    //     Text20 := pCode;
    //     Append(Text20, pAppend);
    //     pCode := Text20;
    // end;
}
