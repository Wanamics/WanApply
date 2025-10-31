namespace Wanamics.Apply.AppliedEntries;

using Microsoft.Sales.Reports;
reportextension 87474 "wan Customer - Balance to Date" extends "Customer - Balance to Date"
{
    dataset
    {
        add(CustLedgEntry3)
        {
            column(ExternalDocumentNo; "External Document No.") { }
            column(AppliedToCode; AppliedHelper.AppliedToCode("Entry No.", Open, "Closed by Entry No.")) { }
        }
    }
    var
        AppliedHelper: Codeunit "wan Applied Entries Helper";
}
