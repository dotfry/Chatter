unit UnitMain;

interface uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Global, mmsystem, Buttons, ImgList, SimpleXML;

type
PoELogVars = record
 LastSize, LastPos: LongWord;
 FileName: string;
end;
PoEVars = record
 Log: PoELogVars;
 Handle: THandle;
 SoundFile, Config: string;
 Sound, LogPublicChannels, RequireFlush, Terminating: boolean;
 XML: IXmlDocument;
 Contacts: IXmlNode;
end;

TfrmMain = class(TForm)
  tDetailedInfo: TMemo;
  tmrMain: TTimer;
  lbContacts: TListBox;
  bSettings: TBitBtn;
  bSound: TBitBtn;
  il: TImageList;
  cbDebug: TCheckBox;
  cbHistory: TCheckBox;
  procedure tmrMainTimer(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure bSoundClick(Sender: TObject);
  procedure lbContactsClick(Sender: TObject);
 private
  procedure SoundState();
 public
  procedure LogStr(Str: string; DebugFlag: boolean = false);
  procedure LoadNewData();
  procedure HandleData(Str: string);
  procedure HandleLine(Str: string);
  procedure HandleMessage(Channel, Author, Msg: String; Date: TDateTime);
  procedure SaveSettings();
  procedure LoadSettings();
  function  GetContactHistory(CName: string): string;
  procedure AppendStr(F, S: string);
  function  IsContact(Name: string): boolean;
  procedure CreateContact(Name: string);
end;

var
 frmMain: TfrmMain;

implementation
const
 XMLConfig = 'PathOfExileChatter';
 XMLConfiguration = 'Configuration';
 XMLContacts = 'Contacts';
 XMLC_Alert = 'alert';
 XMLC_Public = 'public';
 XMLC_Log = 'logs';
 XMLC_Enabled = 'enabled';
 XMLC_File = 'file';
 XMLC_Position = 'position';
 XMLC_Contact = 'contact';
 XMLC_Name = 'name';
var
 Vars: PoEVars;
{$R *.dfm}

function  TfrmMain.IsContact(Name: string): boolean;
var
 i: integer;
begin
 Result := false;
 if Vars.Contacts.ChildNodes.Count = 0 then exit; 
 for i := 0 to Vars.Contacts.ChildNodes.Count - 1 do
 begin
  if Vars.Contacts.ChildNodes[i].GetAttr(XMLC_Name) = Name then
  begin
   Result := true;
   exit;
  end;
 end;
end;

procedure TfrmMain.lbContactsClick(Sender: TObject);
var
 sName: string;
begin
 if lbContacts.ItemIndex = -1 then exit;
 sName := lbContacts.Items[lbContacts.ItemIndex];
 sName := GetContactHistory(sName);
 if FileExists(sName) then
 begin
  tDetailedInfo.Lines.LoadFromFile(sName);
  Vars.RequireFlush := true;
  cbHistory.Checked := true;
 end else begin
  cbHistory.Checked := false;
  LogStr(Format('Failed open file history file %s.', [sName]));
 end;
end;

procedure TfrmMain.CreateContact(Name: string);
begin
 if IsContact(Name) then exit;
 Vars.Contacts.AppendElement(XMLC_Contact).SetAttr(XMLC_Name, Name);
 lbContacts.Items.Add(Name);
end;

function TfrmMain.GetContactHistory(CName: string): string;
begin
 Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + Format('history\%s.txt', [CName]);
 ForceDirectories(ExtractFilePath(Result));
 CreateContact(CName);
end;

procedure TfrmMain.LoadSettings();
var
 nCfg, nSub: IXmlNode;
 nlContacts: IXmlNodeList;
 i: integer;
 sContact: string;
begin
 Vars.XML := CreateXmlDocument(XMLConfig);
 if FileExists(Vars.Config) then Vars.Xml.Load(Vars.Config);
 nCfg := Vars.XML.DocumentElement.SelectSingleNode(XMLConfiguration);
 if nCfg <> nil then
 begin
  nSub := nCfg.SelectSingleNode(XMLC_Alert);
  if nSub <> nil then
  begin
   Vars.Sound := StrToBoolDef(nSub.GetAttr(XMLC_Enabled, 'true'), Vars.Sound);
   Vars.SoundFile := nSub.GetAttr(XMLC_File, Vars.SoundFile);
  end;
  nSub := nCfg.SelectSingleNode(XMLC_Public);
  if nSub <> nil then
  begin
   Vars.LogPublicChannels := StrToBoolDef(nSub.GetAttr(XMLC_Enabled, BoolToStr(Vars.LogPublicChannels)), Vars.LogPublicChannels);
  end;
  nSub := nCfg.SelectSingleNode(XMLC_Log);
  if nSub <> nil then
  begin
   Vars.Log.FileName := nSub.GetAttr(XMLC_File, Vars.Log.FileName);
   Vars.Log.LastPos := StrToIntDef(nSub.GetAttr(XMLC_Position, IntToStr(Vars.Log.LastPos)), Vars.Log.LastPos);
  end;
 end;
 Vars.Contacts := Vars.XML.DocumentElement.SelectSingleNode(XMLContacts);
 if Vars.Contacts = nil then Vars.Contacts := Vars.XML.DocumentElement.AppendElement(XMLContacts);
 nlContacts := Vars.Contacts.SelectNodes(XMLC_Contact);
 if nlContacts.Count > 0 then
 begin
  for i := 0 to nlContacts.Count - 1 do
  begin
   sContact := nlContacts.Item[i].GetAttr(XMLC_Name, '');
   lbContacts.Items.Add(sContact);
  end;
 end;
end;

procedure TfrmMain.SaveSettings();
var
 nCfg, nSub: IXmlNode;
begin
 nCfg := Vars.XML.DocumentElement.SelectSingleNode(XMLConfiguration);
 if nCfg = nil then nCfg := Vars.XML.DocumentElement.AppendElement(XMLConfiguration);
 nSub := nCfg.SelectSingleNode(XMLC_Alert);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_Alert);
 nSub.SetAttr(XMLC_Enabled, BoolToStr(Vars.Sound));
 nSub.SetAttr(XMLC_File, Vars.SoundFile);
 nSub := nCfg.SelectSingleNode(XMLC_Public);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_Public);
 nSub.SetAttr(XMLC_Enabled, BoolToStr(Vars.LogPublicChannels)); 
 nSub := nCfg.SelectSingleNode(XMLC_Log);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_Log);
 nSub.SetAttr(XMLC_File, Vars.Log.FileName);
 nSub.SetAttr(XMLC_Position, IntToStr(Vars.Log.LastPos));
 Vars.XML.Save(Vars.Config);
end;

procedure TfrmMain.bSoundClick(Sender: TObject);
begin
 Vars.Sound := not Vars.Sound;
 SoundState();
end;

procedure TfrmMain.SoundState();
 function getImageId(Flag: boolean): integer;
 begin
  Result := 0;
  if Flag then Result := 1;
 end;
var
 bTemp: TBitmap;
begin
 bTemp := TBitmap.Create();
 il.GetBitmap(getImageId(Vars.Sound), bTemp);
 bSound.Glyph := bTemp;
 FreeAndNil(bTemp);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 SaveSettings();
 Vars.Terminating := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
const
 FILE_LIST_DIRECTORY = FILE_SHARE_READ;
begin
 Vars.Config := ChangeFileExt(Application.ExeName, '.xml');
 Vars.Handle := INVALID_HANDLE_VALUE;
 Vars.Sound := true;
 Vars.Log.FileName := IncludeTrailingPathDelimiter(poeLocateInstall()) + 'logs\Client.txt';
 Vars.Log.LastSize := poeFileSize(Vars.Log.FileName);
 Vars.Log.LastPos := poeFileSize(Vars.Log.FileName);
 LoadSettings();
 if not FileExists(Vars.Log.FileName) then Vars.Log.FileName := IncludeTrailingPathDelimiter(poeLocateInstall()) + 'logs\Client.txt';
 if not FileExists(Vars.SoundFile) then Vars.SoundFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'incoming.wav';
 SoundState();
 if not FileExists(Vars.Log.FileName) then
 begin
  MessageBox(Handle, 'Cannot find Path of Exile installation.', 'Error', MB_ICONERROR);
  exit;
 end;
 tmrMain.Enabled := true;
 LogStr(Format('Loaded. "%s".baseSize=%d.', [Vars.Log.FileName, Vars.Log.LastSize]));
end;


procedure TfrmMain.tmrMainTimer(Sender: TObject);
var
 fSize: LongWord;
begin
 // FUCKING YES. I tryed ReadDirectoryChangesW. It didn't work.
 // TODO: Move all vars to int64.
 fSize := poeFileSize(Vars.Log.FileName);
 if Vars.Handle = INVALID_HANDLE_VALUE then Vars.Handle := FindWindow('Direct3DWindowClass', 'Path of Exile');
 LogStr(Format('DBG: FileSizes: %d-%d. ~%dmb', [Vars.Log.LastSize, fSize, fSize div 1024 div 1024]), true);
 if (Vars.Log.LastSize <> fSize) {or (Vars.Log.LastPos < fSize)} then
 begin
  LogStr(Format('DBG: FileUpdated.', []), true);
  Vars.Log.LastSize := fSize;
  Vars.Log.LastPos := fSize;
  tmrMain.Enabled := false;
  LoadNewData();
  tmrMain.Enabled := true;
 end;
end;

procedure TfrmMain.LoadNewData();
var
 fHandle: THandle;
 pText: PChar;
 sNewData: widestring;
 iBuffSize: DWord;
begin
 fHandle := poeOpenFile(Vars.Log.FileName);
 if SetFilePointer(fHandle, Vars.Log.LastPos, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
 begin
  LogStr('BN: Seek failed.', true);
  exit;
 end;
 iBuffSize := Vars.Log.LastSize - Vars.Log.LastPos - 1;
 Vars.Log.LastPos := Vars.Log.LastSize;
 GetMem(pText, iBuffSize);
 LogStr(Format('DBG: Reading buffer: %d.', [iBuffSize]), true);
 if FileRead(fHandle, pText[0], iBuffSize) = -1 then
 begin
  LogStr('BN: Read failed.', true);
  exit;
 end;
 sNewData := pText;
 FreeMem(pText);
 HandleData(sNewData);
 LogStr(Format('DBG: Readed: %d; "%s".', [Length(sNewData), sNewData]), true);
end;

procedure TfrmMain.HandleData(Str: string);
var
 slTemp: TStringList;
 i: integer;
begin
 slTemp := TStringList.Create();
 slTemp.Text := Str;
 for i := 0 to slTemp.Count - 1 do
 begin
  HandleLine(slTemp[i]);
 end;  
end;

// 2015/06/13 15:52:28 18251336 22d [INFO Client 3084] TopSkill: qq
procedure TfrmMain.HandleLine(Str: string);
const
 aChannels: array[0..4] of string = ('#', '^', '$', '@', '%');
var
 iPos, i: integer;
 sShortInfo, sAvgTime: string;
 sChannel, sTmpChannel, sAuthor: string;
 aInfo: TStringArr;
 dtInfo: TDateTime;
begin
 iPos := AnsiPos(']', Str);
 if iPos = -1 then exit; // unknown log string
 sShortInfo := Copy(Str, iPos + 2, Length(Str) - iPos - 1);
 sAvgTime := poeFormatDate(Copy(Str, 1, 19));
 if sAvgTime = '' then
 begin
  dtInfo := Now();
 end else begin
  dtInfo := StrToDateTimeDef(sAvgTime, Now());
 end;
 aInfo := explode(':', sShortInfo, 2);
 if Length(aInfo) <> 2 then exit; // no message..
 if aInfo[0] = 'Object' then exit; // some trash message.
 if Length(explode(' ', aInfo[0])) > 1 then exit; // not valid player name.
 sTmpChannel := Copy(aInfo[0], 1, 1);
 sAuthor := aInfo[0];
 sShortInfo := aInfo[1];
 for i := Low(aChannels) to High(aChannels) do
 begin
  if sTmpChannel = aChannels[i] then
  begin
   sChannel := sTmpChannel;
   sAuthor := Copy(sAuthor, 2, Length(sAuthor));
  end;
 end;
 HandleMessage(sChannel, sAuthor, sShortInfo, dtInfo);
end;

procedure TfrmMain.HandleMessage(Channel, Author, Msg: String; Date: TDateTime);
var
 sLogFile: string;
 Hist: string;
begin
 LogStr(Format('[%s] %s %s: %s', [DateTimeToStr(Date), Channel, Author, Msg]));
 if (Channel = '@') and Vars.Sound then
 begin
  if GetForegroundWindow() <> Vars.Handle then
  begin
   if FileExists(Vars.SoundFile) then
   begin
    PlaySound(PChar(Vars.SoundFile), 0, SND_ASYNC);
   end;
  end
 end;
 if Channel = '@' then
 begin
  sLogFile := GetContactHistory(Author);
  Hist := format('[%s] %s', [DateTimeToStr(Date), Msg]);
  AppendStr(sLogFile, Hist);
 end;
 if (((Channel = '#') or (Channel = '$') or (Channel = '^')) and Vars.LogPublicChannels) or (Channel = '%') or (Channel = '') then
 begin
  sLogFile := GetContactHistory(Channel);
  Hist := format('[%s] %s: %s', [DateTimeToStr(Date), Author, Msg]);
  AppendStr(sLogFile, Hist);
 end;
end;

procedure TfrmMain.LogStr(Str: string; DebugFlag: boolean = false);
begin
 if DebugFlag and not cbDebug.Checked then exit;
 if cbHistory.Checked then exit;
 if Vars.RequireFlush then tDetailedInfo.Lines.Clear();
 Vars.RequireFlush := false;
 tDetailedInfo.Lines.Add(Str);
end;

procedure TfrmMain.AppendStr(F, S: string);
var
 fh: Textfile;
begin
 AssignFile(fh, F);
 if FileExists(F) then
  Append(fh)
 else
  ReWrite(fh);
 WriteLn(fh, S);
 CloseFile(fh);
end;
end.
