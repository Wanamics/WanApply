namespace Wanamics.Apply.HRPayables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.HumanResources.Payables;
using Microsoft.HumanResources.Employee;

codeunit 87479 "Employee Applies-to ID Events"
{
    Permissions = TableData "Employee Ledger Entry" = rimd;
    SingleInstance = true; // Hold TempLedgerEntry

    var
        TempLedgerEntry: Record "Employee Ledger Entry" temporary;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostEmployeeOnBeforeEmployeeLedgerEntryInsert, '', false, false)]
    local procedure OnPostEmployeeOnBeforeEmployeeLedgerEntryInsert(var GenJnlLine: Record "Gen. Journal Line"; var EmployeeLedgerEntry: Record "Employee Ledger Entry"; GLRegister: Record "G/L Register")
    begin
        if EmployeeLedgerEntry.Open then
            EmployeeLedgerEntry."Applies-to ID" := GenJnlLine."Applies-to ID";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeDeleteEvent, '', false, false)]
    local procedure OnBeforeDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        Employee: Record Employee;
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
    begin
        if Rec."Applies-to ID" = '' then
            exit;
        if Rec."Account Type" = Rec."Account Type"::Employee then
            Employee.Get(Rec."Account No.")
        else if Rec."Bal. Account Type" = Rec."Bal. Account Type"::Employee then
            Employee.Get(Rec."Bal. Account No.")
        else
            exit;
        if Employee."Application Method" <> Employee."Application Method"::"Apply to Oldest" then
            exit;
        EmployeeLedgerEntry.SetCurrentKey("Employee No.", "Applies-to ID", Open, Positive); //, "Due Date"
        EmployeeLedgerEntry.SetRange("Employee No.", Employee."No.");
        EmployeeLedgerEntry.SetRange("Applies-to ID", Rec."Applies-to ID");
        EmployeeLedgerEntry.SetRange(Open, true);
        EmployeeLedgerEntry.SetRange("Currency Code", Rec."Currency Code");
        EmployeeLedgerEntry.SetRange("Employee Posting Group", Rec."Posting Group");
        if EmployeeLedgerEntry.FindSet() then
            repeat
                TempLedgerEntry.Copy(EmployeeLedgerEntry);
                TempLedgerEntry.Insert();
            until EmployeeLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterDeleteGenJournalLine(Rec: Record "Gen. Journal Line")
    var
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
    begin
        if TempLedgerEntry.FindSet() then
            repeat
                EmployeeLedgerEntry.Get(TempLedgerEntry."Entry No.");
                EmployeeLedgerEntry."Applies-to ID" := TempLedgerEntry."Applies-to ID";
                EmployeeLedgerEntry.Modify();
            until TempLedgerEntry.Next() = 0;
        TempLedgerEntry.DeleteAll();
    end;
}
