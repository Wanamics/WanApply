namespace Wanamics.Apply.Receivables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Sales.Customer;

codeunit 87477 "Customer Applies-to ID Events"
{
    Permissions = TableData "Cust. Ledger Entry" = rimd;
    SingleInstance = true; // Hold TempLedgerEntry

    var
        TempLedgerEntry: Record "Cust. Ledger Entry" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeCustLedgEntryInsert, '', false, false)]
    local procedure OnBeforeCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register")
    begin
        if CustLedgerEntry.Open then
            CustLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if Rec."Applies-to ID" = '' then
            exit;
        if Rec."Account Type" = Rec."Account Type"::Customer then
            Customer.Get(Rec."Account No.")
        else if Rec."Bal. Account Type" = Rec."Bal. Account Type"::Customer then
            Customer.Get(Rec."Bal. Account No.")
        else
            exit;
        if Customer."Application Method" <> Customer."Application Method"::"Apply to Oldest" then
            exit;
        CustLedgerEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open, Positive, "Due Date");
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange("Applies-to ID", Rec."Applies-to ID");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Currency Code", Rec."Currency Code");
        CustLedgerEntry.SetRange("Customer Posting Group", Rec."Posting Group");
        if CustLedgerEntry.FindSet() then
            repeat
                TempLedgerEntry.Copy(CustLedgerEntry);
                TempLedgerEntry.Insert();
            until CustLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if TempLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.Get(TempLedgerEntry."Entry No.");
                CustLedgerEntry."Applies-to ID" := TempLedgerEntry."Applies-to ID";
                CustLedgerEntry.Modify();
            until TempLedgerEntry.Next() = 0;
        TempLedgerEntry.DeleteAll();
    end;
}
