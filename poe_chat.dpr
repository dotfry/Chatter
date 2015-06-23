program poe_chat;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {frmMain},
  Global in 'Libs\Global.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
