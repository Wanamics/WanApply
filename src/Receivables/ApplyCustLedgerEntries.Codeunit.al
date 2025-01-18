namespace Wanamics.Apply;

using Microsoft.Sales.Customer;
using System.Security.User;
using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.ReceivablesPayables;
codeunit 87472 "Apply Cust. Ledger Entries"
{
    TableNo = Customer;
    Trigger OnRun()
    var
        ConfirmLbl: Label 'Do you want to apply Applies-to ID for %1 %2 %3?', Comment = '%1:TableCaption, %2:No., %3, Name';
        ApplyLedgerEntryQuery: Query OutstCustLedgerEntries;
        UserSetup: Record "User Setup";
        Applied: Integer;
        DoneLbl: Label '%1 Applied-to ID applied', Comment = '%1:Count Applied';
    begin
        Rec.TestField("Application Method", Rec."Application Method"::"Apply to Oldest");
        if not Confirm(ConfirmLbl, false, Rec.TableCaption, Rec."No.", Rec.Name) then
            exit;

        GLSetup.Get();
        if UserSetup.Get(UserId) and
            (UserSetup."Allow Posting From" < GLSetup."Allow Posting From") and
            (UserSetup."Allow Posting From" <> 0D) then
            GLSetup."Allow Posting From" := UserSetup."Allow Posting From";

        ApplyLedgerEntryQuery.SetRange(CustomerNo, Rec."No.");
        ApplyLedgerEntryQuery.SetRange(RemainingAmount, 0);
        ApplyLedgerEntryQuery.Open();
        Process(ApplyLedgerEntryQuery, Applied);
        ApplyLedgerEntryQuery.Close();
        Message(DoneLbl, Applied);
    end;

    local procedure Process(pApplyLedgerEntryQuery: Query OutstCustLedgerEntries; pApplied: Integer)
    var
        ProgressDialog: Codeunit "Progress Dialog";
    begin
        ProgressDialog.OpenCopyCountMax('', pApplyLedgerEntryQuery.TopNumberOfRows);
        while pApplyLedgerEntryQuery.Read() do begin
            ProgressDialog.UpdateCopyCount();
            Apply(pApplyLedgerEntryQuery, GLSetup);
            pApplied += 1;
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";

    local procedure Apply(pQuery: Query OutstCustLedgerEntries; GLSetup: Record "General Ledger Setup");
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplicationDate: Date;
        xCustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", "Applies-to ID");
        CustLedgerEntry.SetRange("Customer No.", pQuery.CustomerNo);
        CustLedgerEntry.SetRange("Applies-to ID", pQuery.AppliestoID);
        CustLedgerEntry.SetRange(Open, True);
        CustLedgerEntry.SetRange("Currency Code", pQuery.CurrencyCode);
        CustLedgerEntry.SetRange("Customer Posting Group", pQuery.CustomerPostingGroup);
        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");

        if CustLedgerEntry.FindSet() then
            repeat
                xCustLedgerEntry := CustLedgerEntry;
                CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                CustLedgerEntry."Accepted Payment Tolerance" := 0;
                CustLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                if (CustLedgerEntry."Amount to Apply" <> xCustLedgerEntry."Amount to Apply") or
                    (CustLedgerEntry."Accepted Payment Tolerance" <> xCustLedgerEntry."Accepted Payment Tolerance") or
                    (CustLedgerEntry."Accepted Pmt. Disc. Tolerance" <> xCustLedgerEntry."Accepted Pmt. Disc. Tolerance") then
                    Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry);
                if CustLedgerEntry."Posting Date" > ApplicationDate then
                    ApplicationDate := CustLedgerEntry."Posting Date";
            until CustLedgerEntry.Next() = 0;

        ApplyUnapplyParameters.CopyFromCustLedgEntry(CustLedgerEntry);
        ApplyUnapplyParameters."Posting Date" := ApplicationDate;
        if GLSetup."Journal Templ. Name Mandatory" then begin
            ApplyUnapplyParameters."Journal Template Name" := GLSetup."Apply Jnl. Template Name";
            ApplyUnapplyParameters."Journal Batch Name" := GLSetup."Apply Jnl. Batch Name";
        end;
        if ApplyUnapplyParameters."Posting Date" < GLSetup."Allow Posting From" then
            ApplyUnapplyParameters."Posting Date" := GLSetup."Allow Posting From";
        CustEntryApplyPostedEntries.Apply(CustLedgerEntry, ApplyUnapplyParameters);
    end;
}
