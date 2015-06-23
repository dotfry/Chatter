////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Модуль       : uTextFileMonitor.pas
//  * Назначение   : Класс для отслеживания изменений в текстовом файле
//  * Copyright    : 2011 © Дмитрий Муратов
//  * Дата         : 18.05.2011
//  ****************************************************************************
//

unit uTextFileMonitor;

interface

uses
  Windows, SysUtils, Classes, uDirMonitor, uFileContentsMonitor, uBaseMonitor;

const
  LineDelimiter = #13#10;

type

  TNewLineEvent = procedure(Sender: TObject; NewLine: string) of object;

  TTextFileMonitor = class(TFileContentsMonitor)
  strict private
    {$IFDEF UNICODE}
    FEncoding: TEncoding;
    {$ENDIF}
    FMaxLineLength: Integer;
    FData: string;
    FOnNewLine: TNewLineEvent;
    procedure SetOnNewLine(AValue: TNewLineEvent);
    function GetOnNewLine: TNewLineEvent;
  strict protected
    procedure DoNewData(Buffer: PByte; BufferSize: integer); override;
    procedure DoNewLine(NewLine: string); virtual;
  public
    {$IFDEF UNICODE}
    constructor Create(const ATextFileNameToWatch: string; AViewOnlyNewData: Boolean;
      AMaxLineLength: Integer; AEncoding: TEncoding; AErrorEvent: TMonitorErrorEvent;
      ANewLineEvent: TNewLineEvent);
    {$ELSE}
    constructor Create(const ATextFileNameToWatch: string; AViewOnlyNewData: Boolean;
      AMaxLineLength: Integer; AErrorEvent: TMonitorErrorEvent;
      ANewLineEvent: TNewLineEvent);
    {$ENDIF}
    property OnNewLine: TNewLineEvent read GetOnNewLine write SetOnNewLine;
  end;

implementation

{$IFDEF UNICODE}
constructor TTextFileMonitor.Create(const ATextFileNameToWatch: string;
  AViewOnlyNewData: Boolean;  AMaxLineLength: Integer; AEncoding: TEncoding; AErrorEvent: TMonitorErrorEvent;
  ANewLineEvent: TNewLineEvent);
begin
  FData := '';
  FEncoding := AEncoding;
  FOnNewLine := ANewLineEvent;
  FMaxLineLength := AMaxLineLength;
  inherited Create(ATextFileNameToWatch, AViewOnlyNewData, AErrorEvent, nil);
end;
{$ELSE}
constructor TTextFileMonitor.Create(const ATextFileNameToWatch: string;
  AViewOnlyNewData: Boolean;  AMaxLineLength: Integer; AErrorEvent: TMonitorErrorEvent;
  ANewLineEvent: TNewLineEvent);
begin
  FData := '';
  FOnNewLine := ANewLineEvent;
  FMaxLineLength := AMaxLineLength;
  inherited Create(ATextFileNameToWatch, AViewOnlyNewData, AErrorEvent, nil);
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TTextFileMonitor.DoNewData(Buffer: PByte; BufferSize: integer);
var
  EndOfLine: integer;
  {$IFDEF UNICODE}
  Buff: TBytes;
  Size: Integer;
  {$ELSE}
  Buff: PAnsiChar;
  {$ENDIF}
begin
  inherited DoNewData(Buffer, BufferSize);

  {$IFDEF UNICODE}

  FEncoding := TEncoding.Default;
  SetLength(Buff, BufferSize);
  Move(Buffer^, Buff[0], BufferSize);
  Size := TEncoding.GetBufferEncoding(Buff, FEncoding);
  FData := FData + FEncoding.GetString(Buff, Size, Length(Buff) - Size);

  {$ELSE}

  GetMem(Buff, BufferSize + 1);
  try
    ZeroMemory(Buff, BufferSize + 1);
    Move(Buffer^, Buff^, BufferSize);
    FData := FData + StrPas(Buff);
  finally
    FreeMem(Buff)
  end;

  {$ENDIF}

  EndOfLine := Pos(LineDelimiter, FData);
  while EndOfLine > 0 do
    begin
      DoNewLine(Copy(FData, 1, EndOfLine - 1));
      Delete(FData, 1, EndOfLine + 1);
      EndOfLine := Pos(LineDelimiter, FData);
    end;

  if Length(FData) >= FMaxLineLength then
    Delete(FData, 1, FMaxLineLength);

end;

//------------------------------------------------------------------------------

procedure TTextFileMonitor.DoNewLine(NewLine: string);
begin
  if Assigned(FOnNewLine) then
    FOnNewLine(Self, NewLine);
end;

//------------------------------------------------------------------------------

procedure TTextFileMonitor.SetOnNewLine(AValue: TNewLineEvent);
begin
  Lock;
  try
    FOnNewLine := AValue;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TTextFileMonitor.GetOnNewLine: TNewLineEvent;
begin
  Lock;
  try
    Result := FOnNewLine;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

end.
