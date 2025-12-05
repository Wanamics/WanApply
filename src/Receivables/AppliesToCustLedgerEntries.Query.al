namespace Wanamics.Apply.Receivables;

using Microsoft.Sales.Receivables;

query 87472 "AppliesToCustLedgerEntries"
{
    APIGroup = 'wanapply';
    APIPublisher = 'wanamics';
    APIVersion = 'v1.0';
    EntityName = 'applyToCustLedgerEntry';
    EntitySetName = 'applyToCustLedgerEntries';
    QueryType = API;

    elements
    {
        dataitem(detailedCustLedgEntry; "Detailed Cust. Ledg. Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Application), "Initial Document Type" = filter(Invoice | "Credit Memo"); //, "Applied Cust. Ledger Entry No." <> field(Cust. Ledger Entry No. ) //=filter('<>0');

            column(entryNo; "Entry No.")
            {
                Caption = 'entryNo', Locked = true;
            }
            /*
            column(postingDate; "Posting Date")
            {
            }
            */
            column(customerNo; "Customer No.")
            {
                Caption = 'customerNo', Locked = true;
            }
            column(custLedgerEntryNo; "Cust. Ledger Entry No.")
            {
                Caption = 'custLedgerEntryNo', Locked = true;
            }
            column(appliedCustLedgerEntryNo; "Applied Cust. Ledger Entry No.")
            {
                Caption = 'appliedCustLedgerEntryNo', Locked = true;
            }
            column(amount; Amount)
            {
                Caption = 'appliedAmount', Locked = true;
            }

            /*
            column(appliedAmount; Amount)
            {
            }
            column(applicationNo; "Application No.")
            {
            }
            column(custLedgerEntryNo; "Cust. Ledger Entry No.")
            {
            }
            column(entryType; "Entry Type")
            {
            }
            column(initialDocumentType; "Initial Document Type")
            {
            }
            column(unapplied; Unapplied)
            {
            }
            column(unappliedByEntryNo; "Unapplied by Entry No.")
            {
            }
            */
            dataitem(custLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Entry No." = detailedCustLedgEntry."Cust. Ledger Entry No.";

                /*
                column(amount; Amount)
                {
                }
                column(entryNo; "Entry No.")
                {
                }
                */
                column(postingDate; "Posting Date")
                {
                    Caption = 'postingDate', Locked = true;
                }
                column(documentType; "Document Type")
                {
                    Caption = 'documentType', Locked = true;
                }
                column(documentNo; "Document No.")
                {
                    Caption = 'documentNo', Locked = true;
                }
                column(externalDocumentNo; "External Document No.")
                {
                    Caption = 'externalDocumentNo', Locked = true;
                }
                /*
                column(originalAmount; "Original Amount")
                {
                    Caption = 'originalAmount', Locked = true;
                }
                */
                column(open; Open)
                {
                    Caption = 'open', Locked = true;
                }
                column(remainingAmount; "Remaining Amount")
                {
                    Caption = 'remainingAmount', Locked = true;
                }
                column(closedAtDate; "Closed at Date")
                {
                    Caption = 'closedAtDate', Locked = true;
                }
            }
        }
    }
}
