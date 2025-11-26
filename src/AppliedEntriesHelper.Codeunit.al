namespace Wanamics.Apply.AppliedEntries;

codeunit 87475 "Applied Entries Helper"
{
    procedure AppliedToCode(pEntryNo: Integer; pOpen: Boolean; pClosedByEntryNo: Integer): Text
    begin
        if pClosedByEntryNo <> 0 then
            exit(Base26(pClosedByEntryNo))
        else if not pOpen then
            exit(Base26(pEntryNo));
    end;

    local procedure Base26(pColumnNo: Integer) ReturnValue: Text
    var
        c: char;
    begin
        while pColumnNo >= 1 do begin
            c := pColumnNo mod 26 + 65;
            ReturnValue := c + ReturnValue;
            pColumnNo := pColumnNo div 26;
        end;
    end;
}
