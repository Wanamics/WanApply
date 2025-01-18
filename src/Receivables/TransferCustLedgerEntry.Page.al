namespace Wanamics.Apply;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.Dimension;
Page 87470 "Transfer Cust. Ledger Entry"
{
    Caption = 'Transfer Cust. Ledger Entry';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    MultipleNewLines = false;
    PageType = Card;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Gen. Journal Line";
    SourceTableTemporary = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = false;
                field(No; FromEntry."Document No.")
                {
                    Caption = 'No.';
                }
                field(Description; FromEntry.Description)
                {
                    Caption = 'Description';
                }
                field(Amount; FromEntry.Amount)
                {
                    Caption = 'Amount';
                }
            }
            grid(Transfer)
            {
                Caption = 'Transfer';
                GridLayout = Columns;
                group(OldValue)
                {
                    Caption = 'Old Value';
                    Editable = false;
                    field(FromEntryPostingDate; FromEntry."Posting Date")
                    {
                        CaptionClass = Rec.FieldCaption(Rec."Posting Date");
                    }
                    field(FromEntryAccountNo; FromEntry."Customer No.")
                    {
                        CaptionClass = Rec.FieldCaption(Rec."Account No.");
                    }
                    field(FromEntryGlobalDimension1Code; FromEntry."Global Dimension 1 Code")
                    {
                        CaptionClass = '1,2,1';
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                                      "Dimension Value Type" = const(Standard),
                                                                      Blocked = const(false));
                        ToolTip = 'Specifies the dimension value code that the item journal line is linked to.';
                        Visible = Dim1Visible;
                    }
                    field(FromEntryGlobalDimension2Code; FromEntry."Global Dimension 2 Code")
                    {
                        CaptionClass = '1,2,2';
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                                      "Dimension Value Type" = const(Standard),
                                                                      Blocked = const(false));
                        ToolTip = 'Specifies the dimension value code that the item journal line is linked to.';
                        Visible = Dim2Visible;
                    }
                    // field(ShortcutDimCode3; ShortcutDimCode[3])
                    // {
                    //     CaptionClass = '1,2,3';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim3Visible;
                    // }
                    // field(ShortcutDimCode4; ShortcutDimCode[4])
                    // {
                    //     CaptionClass = '1,2,4';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim4Visible;
                    // }
                    // field(ShortcutDimCode5; ShortcutDimCode[5])
                    // {
                    //     CaptionClass = '1,2,5';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim5Visible;
                    // }
                    // field(ShortcutDimCode6; ShortcutDimCode[6])
                    // {
                    //     CaptionClass = '1,2,6';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim6Visible;
                    // }
                    // field(ShortcutDimCode7; ShortcutDimCode[7])
                    // {
                    //     CaptionClass = '1,2,7';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim7Visible;
                    // }
                    // field(ShortcutDimCode8; ShortcutDimCode[8])
                    // {
                    //     CaptionClass = '1,2,8';
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim8Visible;
                    // }
                }
                group(NewValue)
                {
                    Caption = 'New Value';
                    field(PostingDate; Rec."Posting Date")
                    {
                        ShowCaption = false;
                    }
                    field(AccountNo; Rec."Account No.")
                    {
                        ShowCaption = false;
                    }
                    field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies the new dimension value code that will link to the items on the journal line.';
                        Visible = Dim1Visible;
                    }
                    field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies the new dimension value code that will link to the items on the journal line.';
                        Visible = Dim2Visible;
                    }
                    // field(Dim3; NewShortcutDimCode[3])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim3Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(3, NewShortcutDimCode[3]);
                    //     end;
                    // }
                    // field(Dim4; NewShortcutDimCode[4])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim4Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(4, NewShortcutDimCode[4]);
                    //     end;
                    // }
                    // field(Dim5; NewShortcutDimCode[5])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim5Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(5, NewShortcutDimCode[5]);
                    //     end;
                    // }
                    // field(Dim6; NewShortcutDimCode[6])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim6Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(6, NewShortcutDimCode[6]);
                    //     end;
                    // }
                    // field(Dim7; NewShortcutDimCode[7])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim7Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(7, NewShortcutDimCode[7]);
                    //     end;
                    // }
                    // field(Dim8; NewShortcutDimCode[8])
                    // {
                    //     ShowCaption = false;
                    //     TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                    //                                                   "Dimension Value Type" = const(Standard),
                    //                                                   Blocked = const(false));
                    //     Visible = Dim8Visible;
                    //     trigger OnValidate()
                    //     begin
                    //         Rec.ValidateShortcutDimCode(8, NewShortcutDimCode[8]);
                    //     end;
                    // }
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(NewDimensions)
            {
                AccessByPermission = TableData Dimension = R;
                Caption = 'New Dimensions';
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                trigger OnAction()
                begin
                    ShowReclasDimensions;
                    CurrPage.SaveRecord;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", NewShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get;
        Dim1Visible := GLSetup."Global Dimension 1 Code" <> '';
        Dim2Visible := GLSetup."Global Dimension 2 Code" <> '';
        // Dim3Visible := GLSetup."Shortcut Dimension 3 Code" <> '';
        // Dim4Visible := GLSetup."Shortcut Dimension 4 Code" <> '';
        // Dim5Visible := GLSetup."Shortcut Dimension 5 Code" <> '';
        // Dim6Visible := GLSetup."Shortcut Dimension 6 Code" <> '';
        // Dim7Visible := GLSetup."Shortcut Dimension 7 Code" <> '';
        // Dim8Visible := GLSetup."Shortcut Dimension 8 Code" <> '';
    end;

    var
        FromEntry: Record "Cust. Ledger Entry";
        DimMgt: Codeunit DimensionManagement;
        ShortcutDimCode: array[8] of Code[20];
        NewShortcutDimCode: array[8] of Code[20];
        Dim1Visible: Boolean;
        Dim2Visible: Boolean;
    // Dim3Visible: Boolean;
    // Dim4Visible: Boolean;
    // Dim5Visible: Boolean;
    // Dim6Visible: Boolean;
    // Dim7Visible: Boolean;
    // Dim8Visible: Boolean;

    procedure SetFromEntry(pFromEntry: Record "Cust. Ledger Entry")
    begin
        FromEntry := pFromEntry;
        Rec."Document No." := FromEntry."Document No.";
        // Rec."Posting Date" := FromEntry."Posting Date";
        // Rec."Shortcut Dimension 1 Code" := FromEntry."Global Dimension 1 Code";
        // Rec."Shortcut Dimension 2 Code" := FromEntry."Global Dimension 2 Code";
        // Rec."Dimension Set ID" := FromEntry."Dimension Set ID";
        Rec."Account Type" := Rec."Account Type"::"Customer";
        Rec.Insert;
    end;

    local procedure ShowReclasDimensions()
    var
        Dummy: Record "Gen. Journal Line";
    begin
        DimMgt.EditReclasDimensionSet(
            FromEntry."Dimension Set ID", Rec."Dimension Set ID", '',
            Dummy."Shortcut Dimension 1 Code",
            Dummy."Shortcut Dimension 2 Code",
            Rec."Shortcut Dimension 1 Code",
            Rec."Shortcut Dimension 2 Code");
    end;
}
