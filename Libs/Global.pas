unit Global;

interface uses Windows, SysUtils;

type
 PEditBallonTip = ^TEditBallonTip;
 TEditBallonTip = packed record
  cbStruct: DWORD;
  pszTitle: PWideChar;
  pszText: PWideChar;
  ttiIcon: Integer;
 end;

const
 ECM_FIRST = $1500;
 EM_SHOWBALLOONTIP = (ECM_FIRST + 3);
 TTI_NONE = 0;
 TTI_INFO = 1;
 TTI_WARNING = 2;
 TTI_ERROR = 3;
 
const
 INVALID_SET_FILE_POINTER = INVALID_HANDLE_VALUE;

 POE_EXE_NAME = 'PathOfExile.exe';
type
 TSetupInfo = record
  Done: boolean;
  Path, CustomSound: string;
  InternalSound, PlayWhenGameOpen: boolean;
  LogPublic, LogHistory, AlertGuildChat, NoNewContacts: boolean;
 end;

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

 function StrToWChar(Source: string; var Dest: PWideChar): Integer;
 procedure adShowWinMsg(EditCtl: HWnd; Text: string; Caption: string; Icon: Integer; Balloon: Boolean = True);

 function StrRPos(const SubStr, Str: string): Integer;
implementation

 function StrRPos(const SubStr, Str: string): Integer;
 var
  i, SubStrLen: Integer;
 begin
  Result := -1;

  SubStrLen := Length(SubStr);
  if SubStrLen = 0 then Exit;

  for i := Succ(Length(Str)-SubStrLen) downto 1 do
  begin
   if (SubStr[1] = Str[i]) then
   begin
    if Copy(Str,i,SubStrLen) = SubStr then
    begin
     Result := i;
     Exit;
    end;
   end;
  end;

 end;

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
  //fSize: LongWord;
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


function StrToWChar(Source: string; var Dest: PWideChar): Integer;
begin
 Result := (Length(Source) * SizeOf(WideChar)) + 1;
 GetMem(Dest, Result);
 Dest := StringToWideChar(Source, Dest, Result);
end;

procedure adShowWinMsg(EditCtl: HWnd; Text: string; Caption: string; Icon: Integer; Balloon: Boolean = True);
var
 ebt: TEditBallonTip;
 btn: Integer;
 l1, l2: Integer;
begin
 //if not adIsWinXP then Balloon := False;
 if Balloon then
 begin
  FillChar(ebt, sizeof(ebt), 0);
  l1 := StrToWChar(Caption, ebt.pszTitle);
  l2 := StrToWChar(Text, ebt.pszText);
  ebt.ttiIcon := Icon;
  ebt.cbStruct := sizeof(ebt);
  SendMessage(EditCtl, EM_SHOWBALLOONTIP, 0, LongInt(@ebt));
  FreeMem(ebt.pszTitle, l1);
  FreeMem(ebt.pszText, l2);
 end else begin
  case Icon of
   TTI_INFO: btn := MB_ICONINFORMATION;
   TTI_WARNING: btn := MB_ICONWARNING;
   TTI_ERROR: btn := MB_ICONERROR;
  else
   btn := 0;
  end;
  MessageBox(EditCtl, PChar(Text), PChar(Caption), btn);
 end;
end;
end.
