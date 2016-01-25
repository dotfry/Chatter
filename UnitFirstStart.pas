unit UnitFirstStart;

{$WARNINGS OFF}
interface uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Global, FileCtrl;

const
 SetupStepCount = 3;
type

TfrmFirstStart = class(TForm)
  lblFirstStartInfo: TLabel;
  pnlStep1: TPanel;
  bBack: TButton;
  bNext: TButton;
  bExit: TButton;
  Bevel1: TBevel;
  tGamePath: TEdit;
  lblPathAutodetect: TLabel;
  bBrowsePath: TButton;
  lblStepInfo: TLabel;
  pnlStep2: TPanel;
  rbInternalSound: TRadioButton;
  rbCustomSound: TRadioButton;
  pnlStep3: TPanel;
  cbSaveHistory: TCheckBox;
  cbSaveChannels: TCheckBox;
  cbPlayWhenPoEOpen: TCheckBox;
  bSave: TButton;
  cbStep: TComboBox;
  cbAlertGuildChat: TCheckBox;
  procedure bNextClick(Sender: TObject);
  procedure bExitClick(Sender: TObject);
  procedure bBrowsePathClick(Sender: TObject);
  procedure bBackClick(Sender: TObject);
  procedure cbSaveHistoryClick(Sender: TObject);
  procedure cbStepChange(Sender: TObject);
  procedure bSaveClick(Sender: TObject);
 private
  SetupDone: boolean;
  IsSetup: boolean;
  StepId: integer;
  procedure SetupStep(Index: integer);
  procedure ModifySetupObject(var Settings: TSetupInfo);
 public
  function Setup(var Settings: TSetupInfo): boolean;
  function Configure(var Settings: TSetupInfo): boolean;
end;

var
 frmFirstStart: TfrmFirstStart;

implementation
{$R *.dfm}

procedure TfrmFirstStart.bBackClick(Sender: TObject);
begin
 if StepId > 1 then
 begin
  Dec(StepId);
  SetupStep(StepId);
 end;
end;

procedure TfrmFirstStart.bBrowsePathClick(Sender: TObject);
var
 sPath: string;
begin
 sPath := tGamePath.Text;
 if SelectDirectory('Select Path of Exile Install Directory', '', sPath, [sdNewUI, sdValidateDir]) then
 begin
  tGamePath.Text := sPath;
 end;
end;

procedure TfrmFirstStart.bExitClick(Sender: TObject);
begin
 SetupDone := false;
 Close();
end;

procedure TfrmFirstStart.bNextClick(Sender: TObject);
 function step1Validate(): boolean;
 var
  sPath: string;
 begin
  Result := false;
  sPath := IncludeTrailingPathDelimiter(tGamePath.Text);
  if not DirectoryExists(sPath) then
  begin
   adShowWinMsg(tGamePath.Handle, 'Directory doesn''t exists.', 'Error', TTI_ERROR);
   exit;
  end;
  if not FileExists(sPath + POE_EXE_NAME) then
  begin
   adShowWinMsg(tGamePath.Handle, 'Directory doesn''t looking like Path of Exile directory.', 'Error', TTI_ERROR);
   exit;
  end;
  Result := true;
 end;
 function step2Validate(): boolean;
 begin
  Result := true;
 end;
 function step3Validate(): boolean;
 begin
  Result := true;
 end;
begin
 case StepId of
  1: begin
   if step1Validate() then
   begin
    Inc(StepId);
    SetupStep(StepId);
    exit;
   end;
  end;
  2: begin
   if step2Validate() then
   begin
    Inc(StepId);
    SetupStep(StepId);
    exit;
   end;
  end;
  3: begin
   if step3Validate() then
   begin
    SetupDone := true;
    Close();
   end;
  end;
 end;
end;

procedure TfrmFirstStart.bSaveClick(Sender: TObject);
begin
 SetupDone := true;
 Close();
end;

procedure TfrmFirstStart.cbSaveHistoryClick(Sender: TObject);
begin
 cbSaveChannels.Enabled := cbSaveHistory.Checked;
 if cbSaveHistory.Checked then
 begin
  cbSaveChannels.Checked := cbSaveChannels.HelpContext = 1;
 end else begin
  cbSaveChannels.HelpContext := 0;
  if cbSaveChannels.Checked then cbSaveChannels.HelpContext := 1;
  cbSaveChannels.Checked := false;
 end;
end;

procedure TfrmFirstStart.cbStepChange(Sender: TObject);
begin
 SetupStep(cbStep.ItemIndex + 1);
end;

procedure TfrmFirstStart.ModifySetupObject(var Settings: TSetupInfo);
begin
 Settings.Path := tGamePath.Text;
 Settings.InternalSound := rbInternalSound.Checked;
 Settings.PlayWhenGameOpen := cbPlayWhenPoEOpen.Checked;
 Settings.LogPublic := cbSaveChannels.Checked;
 Settings.LogHistory := cbSaveHistory.Checked;
 Settings.AlertGuildChat := cbAlertGuildChat.Checked;
 Settings.CustomSound := ''; // TODO: Add option for that.
end;

function TfrmFirstStart.Setup(var Settings: TSetupInfo): boolean;
begin
 StepId := 1;
 SetupStep(StepId);
 SetupDone := false;
 bExit.Caption := 'Exit';
 IsSetup := true;
 Caption := Format(HelpKeyword, ['first run']);
 ShowModal();
 Result := SetupDone;
 ModifySetupObject(Settings);
end;

function TfrmFirstStart.Configure(var Settings: TSetupInfo): boolean;
begin
 StepId := 1;
 tGamePath.HelpContext := 1;
 SetupStep(StepId);
 IsSetup := false;
 SetupDone := false;
 bExit.Caption := 'Close';
 bSave.Visible := true;
 bBack.Visible := false;
 bNext.Visible := false;
 cbStep.Items.Clear();
 cbStep.Items.Add(pnlStep1.HelpKeyword);
 cbStep.Items.Add(pnlStep2.HelpKeyword);
 cbStep.Items.Add(pnlStep3.HelpKeyword);
 cbStep.Visible := true;
 cbStep.ItemIndex := 0;
 Caption := Format(HelpKeyword, ['settings']);
 lblStepInfo.Visible := false;
 // Settings > Form
 tGamePath.Text := Settings.Path;
 // Settings.CustomSound;
 rbInternalSound.Checked := Settings.InternalSound;
 cbPlayWhenPoEOpen.Checked := Settings.PlayWhenGameOpen;
 cbSaveHistory.Checked := Settings.LogHistory;
 cbSaveHistoryClick(nil);
 cbSaveChannels.Checked := Settings.LogPublic;
 cbAlertGuildChat.Checked := Settings.AlertGuildChat;
 ShowModal();
 Result := SetupDone;
 ModifySetupObject(Settings);
end;

 procedure TfrmFirstStart.SetupStep(Index: integer);
 var
  Title: string;
 begin
  pnlStep1.Visible := false;
  pnlStep2.Visible := false;
  pnlStep3.Visible := false;
  bBack.Enabled := Index > 1;
  bNext.Enabled := Index < 4;
  case Index of
   1: begin
    pnlStep1.Visible := true;
    Title := pnlStep1.HelpKeyword;
    if tGamePath.HelpContext = 0 then
    begin
     tGamePath.HelpContext := 1;
     tGamePath.Text := poeLocateInstall();
     if tGamePath.Text = '' then
     begin
      lblPathAutodetect.Caption := 'Can''t automatically detect Path of Exile install directory.';
     end else begin
      lblPathAutodetect.Caption := 'This is automatically detected install directory, verify it please.';
     end;
     lblPathAutodetect.Visible := true;
    end;
   end;
   2: begin
    pnlStep2.Visible := true;
    Title := pnlStep2.HelpKeyword;
   end;
   3: begin
    pnlStep3.Visible := true;
    Title := pnlStep3.HelpKeyword;
   end;
  end;
  lblFirstStartInfo.Caption := Format(lblFirstStartInfo.HelpKeyword, [Title]);
  lblStepInfo.Caption := Format(lblStepInfo.HelpKeyword, [Index, SetupStepCount]);
 end;
end.
