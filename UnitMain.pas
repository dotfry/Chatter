unit UnitMain;

{
 TODO:
  - Removing contacts.
  - Steam version check.
  - Did someone have log file move that 4gb? (add support?)
  - Idea for reading chatlog & recieving new msgs
  + Dont blow via PlaySound while loading big part of msgs.
  - Toast windows?
  - No automatic add to list
}
interface uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Global, mmsystem, Buttons, ImgList, SimpleXML, UnitFirstStart, UnitAbout,
  ComCtrls, Menus, Clipbrd;

type
PoELogVars = record
 LastSize, LastPos: LongWord;
 FileName, FilePath: string;
end;
PoEFlags = record
 JustInstalled, RequireFlush, MoreDataFollows, PlaySoundAfterLastData: boolean;
end;
PoESound = record
 Internal, Enabled, WhileGameOpen, Guild: boolean;
 FileName: string;
end;
PoEVars = record
 Log: PoELogVars;
 Handle: THandle;
 Config: string;
 LogPublicChannels, LogHistory, RequireFlush, Terminating: boolean;
 XML: IXmlDocument;
 Contacts: IXmlNode;
 Flags: PoEFlags;
 Sound: PoESound;
end;

TfrmMain = class(TForm)
  tDetailedInfo: TMemo;
  tmrMain: TTimer;
  lbContacts: TListBox;
  bSettings: TBitBtn;
  bSound: TBitBtn;
  il: TImageList;
  cbDebug: TCheckBox;
  bAbout: TBitBtn;
  pnlImportProgress: TPanel;
  pbImport: TProgressBar;
  lblImportProgress: TLabel;
  pmContacts: TPopupMenu;
  pmDelete: TMenuItem;
  pmWhisper: TMenuItem;
  procedure tmrMainTimer(Sender: TObject);
  procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure bSoundClick(Sender: TObject);
  procedure lbContactsClick(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure bSettingsClick(Sender: TObject);
  procedure bAboutClick(Sender: TObject);
  procedure pmWhisperClick(Sender: TObject);
  procedure pmDeleteClick(Sender: TObject);
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
  function  DeleteContact(Name: string): boolean;
  procedure CreateContact(Name: string);
  procedure PlaySoundAlert();
  procedure SetHistoryState();
  procedure ApplySettings(Settings: TSetupInfo);
end;

var
 frmMain: TfrmMain;

implementation
const
 XMLConfig = 'PathOfExileChatter';
 XMLConfiguration = 'Configuration';
 XMLContacts = 'Contacts';
 XMLC_Alert = 'alert';
 XMLC_History = 'history';
 XMLC_Log = 'logs';
 XMLC_Public = 'public';
 XMLC_Enabled = 'enabled';
 XMLC_File = 'file';
 XMLC_NonFile = 'nonfile';
 XMLC_Position = 'position';
 XMLC_Contact = 'contact';
 XMLC_Name = 'name';
 XMLC_WhileGameOpen = 'gameopen';
 XMLC_Guild = 'guild';
var
 Vars: PoEVars;
{$R *.dfm}
{$R SoundBase.res}

function  TfrmMain.DeleteContact(Name: string): boolean;
 procedure DeleteUIContact();
 var
  i: integer;
 begin
  for i := 0 to lbContacts.Count - 1 do
  begin
   if lbContacts.Items[i] = Name then
   begin
    lbContacts.Items.Delete(i);
    exit;
   end;
  end;
 end;
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
   Vars.Contacts.RemoveChild(Vars.Contacts.ChildNodes[i]);
   DeleteUIContact();
   exit;
  end;
 end;
end;

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
 end else begin
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
   Vars.Sound.Enabled := StrToBoolDef(nSub.GetAttr(XMLC_Enabled, 'true'), Vars.Sound.Enabled);
   Vars.Sound.FileName := nSub.GetAttr(XMLC_File, Vars.Sound.FileName);
   Vars.Sound.Internal := StrToBoolDef(nSub.GetAttr(XMLC_NonFile, 'true'), Vars.Sound.Internal);
   Vars.Sound.WhileGameOpen := StrToBoolDef(nSub.GetAttr(XMLC_WhileGameOpen, 'true'), Vars.Sound.WhileGameOpen);
   Vars.Sound.Guild := StrToBoolDef(nSub.GetAttr(XMLC_Guild, 'true'), Vars.Sound.Guild);
  end;
  nSub := nCfg.SelectSingleNode(XMLC_History);
  if nSub <> nil then
  begin
   Vars.LogHistory := StrToBoolDef(nSub.GetAttr(XMLC_Enabled, BoolToStr(Vars.LogHistory)), Vars.LogHistory);
   Vars.LogPublicChannels := StrToBoolDef(nSub.GetAttr(XMLC_Public, BoolToStr(Vars.LogPublicChannels)), Vars.LogPublicChannels);
  end;
  nSub := nCfg.SelectSingleNode(XMLC_Log);
  if nSub <> nil then
  begin
   Vars.Log.FilePath := nSub.GetAttr(XMLC_File, Vars.Log.FilePath);
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
 if Vars.XML = nil then exit;
 nCfg := Vars.XML.DocumentElement.SelectSingleNode(XMLConfiguration);
 if nCfg = nil then nCfg := Vars.XML.DocumentElement.AppendElement(XMLConfiguration);
 nSub := nCfg.SelectSingleNode(XMLC_Alert);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_Alert);
 nSub.SetAttr(XMLC_Enabled, BoolToStr(Vars.Sound.Enabled));
 nSub.SetAttr(XMLC_NonFile, BoolToStr(Vars.Sound.Internal));
 nSub.SetAttr(XMLC_WhileGameOpen, BoolToStr(Vars.Sound.WhileGameOpen));
 nSub.SetAttr(XMLC_Guild, BoolToStr(Vars.Sound.Guild));
 nSub.SetAttr(XMLC_File, Vars.Sound.FileName);
 nSub := nCfg.SelectSingleNode(XMLC_History);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_History);
 nSub.SetAttr(XMLC_Enabled, BoolToStr(Vars.LogHistory));
 nSub.SetAttr(XMLC_Public, BoolToStr(Vars.LogPublicChannels));
 nSub := nCfg.SelectSingleNode(XMLC_Log);
 if nSub = nil then nSub := nCfg.AppendElement(XMLC_Log);
 nSub.SetAttr(XMLC_File, Vars.Log.FilePath);
 nSub.SetAttr(XMLC_Position, IntToStr(Vars.Log.LastPos));
 Vars.XML.Save(Vars.Config);
end;

procedure TfrmMain.bAboutClick(Sender: TObject);
begin
 frmAbout.ShowModal();
end;

procedure TfrmMain.bSettingsClick(Sender: TObject);
var
 Settings: TSetupInfo;
begin
 Settings.Path := Vars.Log.FilePath;
 Settings.InternalSound := Vars.Sound.Internal;
 Settings.CustomSound := Vars.Sound.FileName;
 Settings.PlayWhenGameOpen := Vars.Sound.WhileGameOpen;
 Settings.LogPublic := Vars.LogPublicChannels;
 Settings.LogHistory := Vars.LogHistory;
 Settings.AlertGuildChat := Vars.Sound.Guild;
 //Settings.
 if frmFirstStart.Configure(Settings) then
 begin
  ApplySettings(Settings);
  SoundState();
  SetHistoryState();
 end;
end;

procedure TfrmMain.bSoundClick(Sender: TObject);
begin
 Vars.Sound.Enabled := not Vars.Sound.Enabled;
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
 il.GetBitmap(getImageId(Vars.Sound.Enabled), bTemp);
 bSound.Glyph := bTemp;
 FreeAndNil(bTemp);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 SaveSettings();
 Vars.Terminating := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
 {$IFDEF RELEASE}
 cbDebug.Visible := false;
 cbDebug.Checked := false;
 {$ENDIF}
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
 Settings: TSetupInfo;
begin
 Vars.Config := ChangeFileExt(Application.ExeName, '.xml');
 Vars.Handle := INVALID_HANDLE_VALUE;
 Vars.Sound.Enabled := true;
 Vars.Sound.Internal := true;
 Vars.Sound.FileName := '';
 LoadSettings(); // Required for future "save" settings.
 if not FileExists(Vars.Config) then
 begin
  if not frmFirstStart.Setup(Settings) then
  begin
   Close();
   exit;
  end;
  Vars.Log.LastPos := 0;
  Vars.Log.LastSize := 0;
  Vars.Flags.JustInstalled := true;
  ApplySettings(Settings);
  SoundState();
  SetHistoryState();
  tmrMain.Enabled := true;
  exit;
 end;
 LoadSettings();
 Vars.Flags.JustInstalled := false;
 SoundState();
 SetHistoryState();
 tmrMain.Enabled := true;
end;

procedure TfrmMain.tmrMainTimer(Sender: TObject);
var
 fSize: LongWord;
begin
 // FUCKING YES. I tryed ReadDirectoryChangesW. It didn't work.
 if Vars.Log.FileName = '' then
 begin
  Vars.Log.FileName := IncludeTrailingPathDelimiter(Vars.Log.FilePath) + 'logs\Client.txt';
 end;
 fSize := poeFileSize(Vars.Log.FileName);
 // TODO: Move all vars to int64.
 // TODO: Check steam version.
 // TODO: Add more checks?
 if Vars.Handle = INVALID_HANDLE_VALUE then Vars.Handle := FindWindow('Direct3DWindowClass', 'Path of Exile');
 LogStr(Format('DBG: FileSizes: %d-%d. ~%dmb', [Vars.Log.LastSize, fSize, fSize div 1024 div 1024]), true);
 if (Vars.Log.LastSize <> fSize) {or (Vars.Log.LastPos < fSize)} then
 begin
  tmrMain.Enabled := false;
  LogStr(Format('DBG: FileUpdated.', []), true);
  if Vars.Flags.JustInstalled then
  begin
   if MessageBox(Handle, 'Chatter just installed. Import ALL history?', 'History', MB_YESNO + MB_ICONQUESTION) <> IDYES then
   begin
    Vars.Log.LastSize := fSize;
    Vars.Log.LastPos := fSize;
    exit;
   end else begin
    pnlImportProgress.Visible := true;
   end;
  end;
  Vars.Log.LastSize := fSize;
  LoadNewData();
  Vars.Log.LastPos := fSize;
  Vars.Flags.JustInstalled := false;
  pnlImportProgress.Visible := false;
  tmrMain.Enabled := true;
 end;
end;

procedure TfrmMain.LoadNewData();
const
 MaxBufferSize = 10240;
var
 fHandle: THandle;
 pText: PChar;
 sNewData: widestring;
 iBuffSize, iTmpBuffSize: DWord;
 function ReadRawData(BuffSize: integer): string;
 begin
  GetMem(pText, BuffSize);
  LogStr(Format('DBG: Reading buffer: %d.', [BuffSize]), true);
  if FileRead(fHandle, pText[0], BuffSize) = -1 then
  begin
   LogStr('BN: Read failed.', true);
   FreeMem(pText);
   exit;
  end;
  Result := pText;
  FreeMem(pText);
 end;
var
 iLastCr, i: integer;
begin
 fHandle := poeOpenFile(Vars.Log.FileName);
 if SetFilePointer(fHandle, Vars.Log.LastPos, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
 begin
  LogStr('BN: Seek failed.', true);
  exit;
 end;
 iBuffSize := Vars.Log.LastSize - Vars.Log.LastPos;
 if iBuffSize > MaxBufferSize then
 begin
  // All | Remain.
  if pnlImportProgress.Visible then
  begin
   pbImport.Max := iBuffSize div MaxBufferSize;
   pbImport.Min := 0;
   i := 0;
   pbImport.Position := i;
  end;
  while iBuffSize > 0 do
  begin
   if pnlImportProgress.Visible then
   begin
    Inc(i);
    pbImport.Position := i;
    lblImportProgress.Caption := Format(lblImportProgress.HelpKeyword, [i, pbImport.Max]);
    Application.ProcessMessages();
   end;
   iTmpBuffSize := iBuffSize;
   if iTmpBuffSize > MaxBufferSize then
   begin
    iTmpBuffSize := MaxBufferSize;
   end;
   Dec(iBuffSize, iTmpBuffSize);
   sNewData := ReadRawData(MaxBufferSize);
   iLastCr := StrRPos(#13, sNewData);
   if (iLastCr < Length(sNewData) - 2) and (iLastCr <> -1) then
   begin
    // Usially only first seek can fail.
    SetFilePointer(fHandle, iLastCr - Length(sNewData) - 1, nil, FILE_CURRENT);
    sNewData := Copy(sNewData, 0, iLastCr);
   end;
   Vars.Flags.MoreDataFollows := true;
   HandleData(sNewData);
  end;
 end else begin
  sNewData := ReadRawData(iBuffSize);
  Vars.Log.LastPos := Vars.Log.LastSize;
  HandleData(sNewData);
 end;
 if Vars.Flags.PlaySoundAfterLastData then
 begin
  Vars.Flags.MoreDataFollows := false;
  Vars.Flags.PlaySoundAfterLastData := false;
  PlaySoundAlert();
 end;
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
 slTemp.Free();
end;

// 2015/06/13 15:52:28 18251336 22d [INFO Client 3084] TopSkill: qq
procedure TfrmMain.HandleLine(Str: string);
const
 aChannels: array[0..5] of string = ('#', '^', '$', '@', '%', '&');
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

procedure TfrmMain.PlaySoundAlert();
begin
 // Dont blow things up due import. //
 if Vars.Flags.MoreDataFollows then
 begin
  Vars.Flags.PlaySoundAfterLastData := true;
  exit;
 end;
 if Vars.Flags.JustInstalled then
 begin                 
  exit;
 end;
 if (GetForegroundWindow() <> Vars.Handle) or (Vars.Sound.WhileGameOpen) then
 begin
  if Vars.Sound.Internal then
  begin
   PlaySound('Incoming', Application.Handle, SND_ASYNC and SND_RESOURCE);
  end else begin
   if FileExists(Vars.Sound.FileName) then
   begin
    PlaySound(PChar(Vars.Sound.FileName), 0, SND_ASYNC);
   end else begin
    // Playing "internal" (because user file broken).
    PlaySound(PChar(Name), Application.Handle, SND_ASYNC and SND_RESOURCE);
   end;
  end;
 end;
 //
end;

procedure TfrmMain.pmDeleteClick(Sender: TObject);
//var
// sTemp: string;
begin
 if lbContacts.ItemIndex >= 0 then
 begin
  DeleteContact(lbContacts.Items[lbContacts.ItemIndex]);
 end;
end;

procedure TfrmMain.pmWhisperClick(Sender: TObject);
var
 sTemp: string;
begin
 if lbContacts.ItemIndex >= 0 then
 begin
  sTemp := lbContacts.Items[lbContacts.ItemIndex];
  if Length(sTemp) > 1 then
  begin
   Clipboard.AsText := '@' + sTemp + ' ';
  end;
 end;
end;

procedure TfrmMain.SetHistoryState();
begin
 lbContacts.Visible := Vars.LogHistory;
 if Vars.LogHistory then
 begin
  tDetailedInfo.Width := ClientWidth - tDetailedInfo.Left * 3 - lbContacts.Width;
 end else begin
  tDetailedInfo.Width := ClientWidth - tDetailedInfo.Left * 2;
 end;
end;

procedure TfrmMain.ApplySettings(Settings: TSetupInfo);
begin
 Vars.Log.FilePath := Settings.Path;
 Vars.Log.FileName := IncludeTrailingPathDelimiter(Settings.Path) + 'logs\Client.txt';
 Vars.Sound.Internal := Settings.InternalSound;
 Vars.Sound.FileName := Settings.CustomSound;
 Vars.Sound.Guild := Settings.AlertGuildChat;
 Vars.Sound.WhileGameOpen := Settings.PlayWhenGameOpen;
 Vars.LogPublicChannels := Settings.LogPublic;
 Vars.LogHistory := Settings.LogHistory;
end;

procedure TfrmMain.HandleMessage(Channel, Author, Msg: String; Date: TDateTime);
var
 sLogFile: string;
 Hist: string;
begin
 LogStr(Format('[%s] %s %s: %s', [DateTimeToStr(Date), Channel, Author, Msg]));
 if (Channel = '@') and Vars.Sound.Enabled then
 begin
  PlaySoundAlert();
 end;
 if (Channel = '&') and Vars.Sound.Enabled and Vars.Sound.Guild then
 begin
  PlaySoundAlert();
 end;
 if not Vars.LogHistory then
 begin
  exit;
 end;
 if Channel = '@' then
 begin
  sLogFile := GetContactHistory(Author);
  Hist := format('[%s] %s', [DateTimeToStr(Date), Msg]);
  AppendStr(sLogFile, Hist);
 end;
 if (((Channel = '#') or (Channel = '$') or (Channel = '^')) and Vars.LogPublicChannels) or (Channel = '%') or (Channel = '') or (Channel = '&') then
 begin
  sLogFile := GetContactHistory(Channel);
  Hist := format('[%s] %s: %s', [DateTimeToStr(Date), Author, Msg]);
  AppendStr(sLogFile, Hist);
 end;
end;

procedure TfrmMain.LogStr(Str: string; DebugFlag: boolean = false);
begin
 if DebugFlag and not cbDebug.Checked then exit;
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
