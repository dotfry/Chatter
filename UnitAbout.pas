unit UnitAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi;

type
  TfrmAbout = class(TForm)
    logo: TImage;
    lbl6dreams: TLabel;
    bClose: TButton;
    lblChatterAboutText: TLabel;
    procedure lbl6dreamsMouseEnter(Sender: TObject);
    procedure lbl6dreamsMouseLeave(Sender: TObject);
    procedure lbl6dreamsClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation
{$R *.dfm}

procedure TfrmAbout.bCloseClick(Sender: TObject);
begin
 Close();
end;

procedure TfrmAbout.lbl6dreamsClick(Sender: TObject);
begin
 ShellExecute(Handle, 'open', 'https://6dreams.net/', nil, nil, 5);
end;

procedure TfrmAbout.lbl6dreamsMouseEnter(Sender: TObject);
begin
 lbl6dreams.Font.Style := [fsBold, fsUnderline];
end;

procedure TfrmAbout.lbl6dreamsMouseLeave(Sender: TObject);
begin
 lbl6dreams.Font.Style := [fsBold];
end;

end.
