namespace Wanamics.Apply;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
Codeunit 87471 "Transfer Cust. Ledger Entry"
{
    TableNo = "Cust. Ledger Entry";

    trigger OnRun()
    var
        TransferCustLedgerEntry: Page "Transfer Cust. Ledger Entry";
        ConfirmLbl: label 'Do you confirm transfer of %1 "%2"?';
        DoneLbl: label '%1 "%2" transfered in %3.';
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        lCount: Integer;
        StartDateTime: DateTime;
    begin
        Rec.SetAutoCalcFields(Amount, "Remaining Amount", "Original Amount");
        CheckEntry(Rec);
        TransferCustLedgerEntry.SetFromEntry(Rec);
        TransferCustLedgerEntry.LookupMode(true);
        if TransferCustLedgerEntry.RunModal = Action::LookupOK then begin
            if not Confirm(ConfirmLbl, false, Rec.Count, Rec.TableCaption) then
                exit;
            StartDateTime := CurrentDateTime;
            lCount := Rec.Count;
            TransferCustLedgerEntry.GetRecord(TempGenJournalLine);
            Transfer(Rec, TempGenJournalLine);
            Message(StrSubstNo(DoneLbl, lCount, Rec.TableCaption, CurrentDateTime - StartDateTime));
        end;
    end;

    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";

    local procedure CheckEntry(pRec: Record "Cust. Ledger Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        pRec.TestField(pRec.Open, true);
        pRec.TestField(pRec.Reversed, false);
        // pRec.CalcFields("Remaining Amount");
        pRec.TestField("Remaining Amount", pRec."Original Amount");
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", pRec."Document No.");
        VATEntry.SetRange("Posting Date", pRec."Posting Date");
        VATEntry.SetRange(Closed, false);
        VATEntry.SetFilter("Remaining Unrealized Amount", '<>0');
        if VATEntry.FindFirst() then
            VATEntry.TestField("Remaining Unrealized Amount", 0);
    end;

    local procedure Transfer(var pRec: Record "Cust. Ledger Entry"; pTempGenJournalLine: Record "Gen. Journal Line")
    var
        lGenJournalLine: Record "Gen. Journal Line";
        AppliesToId: Code[50];
        lRec: Record "Cust. Ledger Entry";
    begin
        pRec.LockTable; // Required for lRec.FindLast below
        if pRec.FindSet then
            repeat
                CheckEntry(pRec);
                if pRec."Customer No." = pTempGenJournalLine."Account No." then
                    pRec.FieldError("Customer No.", pTempGenJournalLine."Account No.");

                AppliesToId := pRec."Applies-to ID";
                ToGenJournalLine(pRec, lGenJournalLine, pTempGenJournalLine."Posting Date");

                Case pRec."Document Type" of
                    pRec."Document Type"::Invoice,
                    pRec."Document Type"::"Credit Memo":
                        begin
                            lGenJournalLine.Validate("Applies-to Doc. Type", pRec."Document Type");
                            lGenJournalLine.Validate("Applies-to Doc. No.", pRec."Document No.");
                        end;
                    else
                        pRec.TestField("Applies-to ID");
                        lGenJournalLine."Applies-to ID" := AppliesToId;
                end;

                case pRec."Document Type" of
                    pRec."Document Type"::Invoice:
                        lGenJournalLine.Validate("Document Type", lGenJournalLine."Document Type"::"Credit Memo");
                    pRec."Document Type"::"Credit Memo":
                        lGenJournalLine.Validate("Document Type", lGenJournalLine."Document Type"::Invoice);
                end;
                if pRec."Document Type" in [pRec."Document Type"::Invoice, pRec."Document Type"::"Credit Memo"] then
                    Append(lGenJournalLine."Document No.", '_');
                lGenJournalLine.Validate("Amount", -pRec.Amount);
                lGenJournalLine."Sales/Purch. (LCY)" := -pRec."Sales (LCY)";
                Append(lGenJournalLine.Description, '-');
                GenJnlPostLine.Run(lGenJournalLine);

                lRec.FindLast;
                lRec.Reversed := true;
                lRec."Reversed Entry No." := pRec."Entry No.";
                lRec.Modify;

                pRec.Get(pRec."Entry No.");
                pRec.Reversed := true;
                pRec."Reversed by Entry No." := lRec."Entry No.";
                pRec.Modify;

                ToGenJournalLine(pRec, lGenJournalLine, pTempGenJournalLine."Posting Date");
                if pTempGenJournalLine."Account No." <> '' then
                    lGenJournalLine.Validate("Account No.", pTempGenJournalLine."Account No.");
                lGenJournalLine."Dimension Set ID" := pRec."Dimension Set ID";
                if pTempGenJournalLine."Shortcut Dimension 1 Code" <> '' then
                    lGenJournalLine.Validate("Shortcut Dimension 1 Code", pTempGenJournalLine."Shortcut Dimension 1 Code")
                else
                    lGenJournalLine.Validate("Shortcut Dimension 1 Code", pRec."Global Dimension 1 Code");
                if pTempGenJournalLine."Shortcut Dimension 2 Code" <> '' then
                    lGenJournalLine.Validate("Shortcut Dimension 2 Code", pTempGenJournalLine."Shortcut Dimension 2 Code")
                else
                    lGenJournalLine.Validate("Shortcut Dimension 2 Code", pRec."Global Dimension 2 Code");
                lGenJournalLine.Validate("Document Type", pRec."Document Type");
                lGenJournalLine.Validate("Amount", pRec.Amount);
                lGenJournalLine."Sales/Purch. (LCY)" := pRec."Sales (LCY)";
                if pRec."Document Type" in [pRec."Document Type"::Invoice, pRec."Document Type"::"Credit Memo"] then
                    Append(lGenJournalLine."Document No.", '_');
                Append(lGenJournalLine.Description, '+');
                lGenJournalLine."Applies-to ID" := AppliesToID;
                GenJnlPostLine.Run(lGenJournalLine);

            until pRec.Next = 0;
    end;

    local procedure ToGenJournalLine(var pRec: Record "Cust. Ledger Entry"; var pGenJournalLine: Record "Gen. Journal Line"; pPostingDate: Date)
    begin
        Clear(pGenJournalLine);
        if pPostingDate <> 0D then
            pGenJournalLine."Posting Date" := pPostingDate
        else
            pGenJournalLine."Posting Date" := pRec."Posting Date";
        pGenJournalLine."Document No." := pRec."Document No.";
        pGenJournalLine.Validate("Account Type", pGenJournalLine."Account Type"::"Customer");
        pGenJournalLine.Validate("Account No.", pRec."Customer No.");
        // pGenJournalLine.Validate("Document Type", pRec."Document Type");
        // pGenJournalLine.Amount := pRec.Amount;
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

    local procedure Append(var pCode: Code[20]; pAppend: Text)
    var
        Text20: Text[20];
    begin
        Text20 := pCode;
        Append(Text20, pAppend);
        pCode := Text20;
    end;
}
