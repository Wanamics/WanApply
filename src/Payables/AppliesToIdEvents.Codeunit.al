namespace Wanamics.Apply.Payables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 87478 "Vendor Applies-to ID Events"
{
    Permissions = TableData "Vendor Ledger Entry" = rimd;
    SingleInstance = true; // Hold TempLedgerEntry

    var
        TempLedgerEntry: Record "Vendor Ledger Entry" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeVendLedgEntryInsert, '', false, false)]
    local procedure OnBeforeVendLedgEntryInsert(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register")
    begin
        if VendorLedgerEntry.Open then
            VendorLedgerEntry."Applies-to ID" := GenJournalLine."Applies-to ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        Vendor: Record Vendor;
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if Rec."Applies-to ID" = '' then
            exit;
        if Rec."Account Type" = Rec."Account Type"::Vendor then
            Vendor.Get(Rec."Account No.")
        else if Rec."Bal. Account Type" = Rec."Bal. Account Type"::Vendor then
            Vendor.Get(Rec."Bal. Account No.")
        else
            exit;
        if Vendor."Application Method" <> Vendor."Application Method"::"Apply to Oldest" then
            exit;
        VendLedgerEntry.SetCurrentKey("Vendor No.", "Applies-to ID", Open, Positive, "Due Date");
        VendLedgerEntry.SetRange("Vendor No.", Vendor."No.");
        VendLedgerEntry.SetRange("Applies-to ID", Rec."Applies-to ID");
        VendLedgerEntry.SetRange(Open, true);
        VendLedgerEntry.SetRange("Currency Code", Rec."Currency Code");
        VendLedgerEntry.SetRange("Vendor Posting Group", Rec."Posting Group");
        if VendLedgerEntry.FindSet() then
            repeat
                TempLedgerEntry.Copy(VendLedgerEntry);
                TempLedgerEntry.Insert();
            until VendLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if TempLedgerEntry.FindSet() then
            repeat
                VendLedgerEntry.Get(TempLedgerEntry."Entry No.");
                VendLedgerEntry."Applies-to ID" := TempLedgerEntry."Applies-to ID";
                VendLedgerEntry.Modify();
            until TempLedgerEntry.Next() = 0;
        TempLedgerEntry.DeleteAll();
    end;
}
