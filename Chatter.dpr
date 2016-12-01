program Chatter;

uses
  Forms,
  UnitMain in 'UnitMain.pas' {frmMain},
  Global in 'Libs\Global.pas',
  UnitFirstStart in 'UnitFirstStart.pas' {frmFirstStart},
  UnitAbout in 'UnitAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmFirstStart, frmFirstStart);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
