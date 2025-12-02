namespace WanApply.WanApply;

using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;

tableextension 87470 "Customer Posting Group" extends "Customer Posting Group"
{
    fields
    {
        field(87470; "wan Close Entry Debit Acc."; Code[20])
        {
            Caption = 'Close Entry Debit Acc.';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the general ledger account to use when you close an entry as lost.';
            trigger OnLookup()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.LookupGLAccountWithoutCategory("wan Close Entry Debit Acc.")
                else
                    LookupGLAccount(
                      "wan Close Entry Debit Acc.", GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInterestExpense());

                Validate("wan Close Entry Debit Acc.");
            end;

            trigger OnValidate()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("wan Close Entry Debit Acc.", false, false)
                else
                    CheckGLAccount(
                      FieldNo("wan Close Entry Debit Acc."), "wan Close Entry Debit Acc.", false, false,
                      GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInterestExpense());
            end;
        }
        field(87471; "wan Close Entry Credit Acc."; Code[20])
        {
            Caption = 'Close Entry Credit';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the general ledger account to use when you close an entry as lost.';
            trigger OnLookup()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.LookupGLAccountWithoutCategory("wan Close Entry Credit Acc.")
                else
                    LookupGLAccount(
                      "wan Close Entry Credit Acc.", GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInterestExpense());

                Validate("wan Close Entry Credit Acc.");
            end;

            trigger OnValidate()
            begin
                if "View All Accounts on Lookup" then
                    GLAccountCategoryMgt.CheckGLAccountWithoutCategory("wan Close Entry Credit Acc.", false, false)
                else
                    CheckGLAccount(
                      FieldNo("wan Close Entry Credit Acc."), "wan Close Entry Credit Acc.", false, false,
                      GLAccountCategory."Account Category"::Expense, GLAccountCategoryMgt.GetInterestExpense());
            end;
        }
    }
    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";

    local procedure CheckGLAccount(ChangedFieldNo: Integer; AccNo: Code[20]; CheckProdPostingGroup: Boolean; CheckDirectPosting: Boolean; AccountCategory: Option; AccountSubcategory: Text)
    begin
        GLAccountCategoryMgt.CheckGLAccount(Database::"Customer Posting Group", ChangedFieldNo, AccNo, CheckProdPostingGroup, CheckDirectPosting, AccountCategory, AccountSubcategory);
    end;

    local procedure LookupGLAccount(var AccountNo: Code[20]; AccountCategory: Option; AccountSubcategoryFilter: Text)
    begin
        GLAccountCategoryMgt.LookupGLAccount(Database::"Customer Posting Group", CurrFieldNo, AccountNo, AccountCategory, AccountSubcategoryFilter);
    end;

}
