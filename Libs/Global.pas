unit Global;

interface uses Windows, SysUtils;

const
 INVALID_SET_FILE_POINTER = INVALID_HANDLE_VALUE;

type

 TStringArr = array of string;

 {$EXTERNALSYM GetFileSizeEx}
 function GetFileSizeEx(hFile: THandle; var lpFileSize: Int64): dword; stdcall;
 function GetFileSizeEx; external kernel32 name 'GetFileSizeEx';

 function poeFileSize(FileName: string): Int64;
 function poeOpenFile(FileName: string; IsWrite: boolean = false): THandle;
 function poeCloseFile(Handle: THandle): Boolean;
 function poeFormatDate(Str: string): string;
 function explode(cDelimiter, sValue :string; iCount: integer = 0): TStringArr;
 function poeLocateInstall(): string;
 function poeReadRegKey(Path, Key: string): string;
implementation

 function poeReadRegKey(Path, Key: string): string;
 var
  hReg: HKey;
  Buffer: array[0..255] of Char;
  Size: Cardinal;
 begin
  Result := '';
  Size := SizeOf(Buffer);
  if RegOpenKeyEx(HKEY_CURRENT_USER, PChar(Path), 0, KEY_READ, hReg) <> ERROR_SUCCESS then exit;
  if RegQueryValueEx(hReg, PChar(Key), nil, nil, @Buffer, @Size) = ERROR_SUCCESS then Result := Buffer;
  RegCloseKey(hReg);
 end;

 function poeLocateInstall(): string;
 begin
  Result := poeReadRegKey('Software\GrindingGearGames\Path of Exile', 'InstallLocation');
 end;

 // 2015/06/13 15:52:28
 function poeFormatDate(Str: string): string;
 var
  aBase, aDate: TStringArr;
  sTime: string;
 begin
  aBase := explode(' ', Str, 2);
  if Length(aBase) <> 2 then exit;
  sTime := aBase[1];
  aDate := explode('/', aBase[0]);
  if Length(aDate) <> 3 then exit; // date fail.
  if Length(aDate[0]) <> 4 then exit; // year fail.
  Result := Format('%s.%s.%s %s', [aDate[2], aDate[1], aDate[0], sTime]);
 end;

 function poeOpenFile(FileName: string; IsWrite: boolean = false): THandle;
 var
  flag: cardinal;
 begin
  if IsWrite then flag := GENERIC_WRITE else flag := GENERIC_READ;
  Result := CreateFile(PChar(FileName), flag, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
 end;

 function poeCloseFile(Handle: THandle): Boolean;
 begin
  Result := CloseHandle(Handle);
 end;

 function poeFileSize(FileName: string): Int64;
 var
  fHandle: THandle;
  fSize: LongWord;
  pSize: Int64;
 begin
  //Result := GetCompressedFileSize(PChar(FileName), nil);
 // exit;
  fHandle := poeOpenFile(PChar(FileName));
  if fHandle = INVALID_HANDLE_VALUE then
  begin
   Result := LongWord(-1);
   exit;
  end;

  if GetFileSizeEx(fHandle, pSize) = 0 then
  begin
   Result := -1;
  end else begin
   Result := pSize;
  end;
  poeCloseFile(fHandle);
 end;

 function explode(cDelimiter, sValue :string; iCount: integer = 0): TStringArr;
 var
  s: string;
  i, p: integer;
 begin
  s := sValue; i := 0;
  while Length(s) > 0 do
  begin
   Inc(i);
   SetLength(Result, i);
   p := Pos(cDelimiter, s);
   if (p > 0 ) and (( i < iCount ) or (iCount = 0)) then
    begin
    Result[i - 1] := copy(s, 0, p - 1);
    s := Copy(s, p + Length(cDelimiter), Length(s));
   end else begin
    Result[i - 1] := s;
    s :=  '';
   end;
  end;
 end;


end.
