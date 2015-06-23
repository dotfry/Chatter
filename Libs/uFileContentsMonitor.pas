////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Модуль       : uFileContentsMonitor.pas
//  * Назначение   : Класс для отслеживания изменений в файле
//  * Copyright    : 2011 © Дмитрий Муратов
//  * Дата         : 18.05.2011
//  ****************************************************************************
//

unit uFileContentsMonitor;

interface

uses
  Windows, SysUtils, Classes, Math, uDirMonitor, uBaseMonitor;

type

  TNewDataEvent = procedure(Sender: TObject; Buffer: PByte; BufferSize: integer) of object;

  TFileContentsMonitor = class(TDirMonitor)
  const
    MaxBytesToRead = 1024;
  strict private
    FViewOnlyNewData: Boolean;
    FLastReadPos: Int64;
    FOnNewData: TNewDataEvent;
    procedure SetViewOnlyNewData(AValue: boolean);
    function GetViewOnlyNewData: Boolean;
    procedure SetOnNewData(AValue: TNewDataEvent);
    function GetOnNewData: TNewDataEvent;
  strict protected
    procedure DoNewData(Buffer: PByte; BufferSize: integer); virtual;
    procedure DoFileAction(AFileName: string; AFileAction: TFileNotifyAction); override;
    procedure DoReadFromPos(var APos: Int64);
    procedure InitWatch; override;
    procedure DoError(E: Exception); override;
  public
    constructor Create(const AFileNameToWatch: string; AViewOnlyNewData: Boolean;
      AErrorEvent: TMonitorErrorEvent; ANewDataEvent: TNewDataEvent);
    destructor Destroy; override;
    class function GetFileSize(const FileName: String): Int64;
    property OnNewData: TNewDataEvent read GetOnNewData write SetOnNewData;
    property ViewOnlyNewData: Boolean read GetViewOnlyNewData write SetViewOnlyNewData;
  end;

implementation

//------------------------------------------------------------------------------

class function TFileContentsMonitor.GetFileSize(const FileName: String): Int64;
var
  FD : TWin32FindData;
  FH : THandle;
begin
  Result := 0;
  FH := FindFirstFile(PChar(FileName), FD);
  if FH = INVALID_HANDLE_VALUE then exit;
  Result := FD.nFileSizeHigh * 4294967296 + FD.nFileSizeLow;
  Windows.FindClose(FH);
end;

//------------------------------------------------------------------------------

constructor TFileContentsMonitor.Create(const AFileNameToWatch: string;
  AViewOnlyNewData: Boolean; AErrorEvent: TMonitorErrorEvent;
  ANewDataEvent: TNewDataEvent);
begin
  FViewOnlyNewData := AViewOnlyNewData;
  FOnNewData := ANewDataEvent;
  FLastReadPos := 0;
  inherited Create('', AFileNameToWatch, nil, AErrorEvent,
    False, [fnoNotifySize], [fnaModified]);
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.DoError(E: Exception);
begin
  Lock;
  try
    FViewOnlyNewData := False;
  finally
    Unlock;
  end;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.InitWatch;
begin
  if not ViewOnlyNewData then
    begin
      FLastReadPos := 0;
      DoReadFromPos(FLastReadPos);
    end
  else
    FLastReadPos := GetFileSize(FileNameToWatch);
  inherited InitWatch;
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.DoNewData(Buffer: PByte; BufferSize: integer);
begin
  if Assigned(OnNewData) then
    OnNewData(Self, Buffer, BufferSize);
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.DoReadFromPos(var APos: Int64);

var
  FileStream: TFileStream;
  BufSize: integer;
  Buffer: PByte;
begin
  FileStream := TFileStream.Create(FileNameToWatch, fmOpenRead or fmShareDenyNone);
  try
    while APos < FileStream.Size  do
      begin
        FileStream.Position := APos;
        BufSize := Min(FileStream.Size - APos, MaxBytesToRead);
        if BufSize > 0 then
          begin
            GetMem(Buffer, BufSize);
            try
              ZeroMemory(Buffer, BufSize);
              APos := APos + FileStream.Read(Buffer^, BufSize);
              DoNewData(Buffer, BufSize);
            finally
              FreeMem(Buffer)
            end;
          end;
      end;
  finally
    FileStream.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.DoFileAction(AFileName: string; AFileAction: TFileNotifyAction);
var
  NewSize: Int64;
begin
  inherited DoFileAction(AFileName, AFileAction);
  NewSize := GetFileSize(AFileName);
  if NewSize > FLastReadPos then
    begin
      // размер файла увеличился, добавлены новые строки
      // здесь прочитаем эти строки
      DoReadFromPos(FLastReadPos);
      FLastReadPos := NewSize;
    end
  else
    if NewSize < FLastReadPos then
      begin
        // размер файла уменьшился, вероятно файл перезаписан,
        // считаем что изменился весь, читаем сначала
        FLastReadPos := 0;
        // здесь прочитаем эти строки
        DoReadFromPos(FLastReadPos);
      end;
end;

//------------------------------------------------------------------------------

destructor TFileContentsMonitor.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.SetViewOnlyNewData(AValue: boolean);
begin
  Lock;
  try
    FViewOnlyNewData := AValue;
    ResetWatch;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TFileContentsMonitor.GetViewOnlyNewData: Boolean;
begin
  Lock;
  try
    Result := FViewOnlyNewData;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TFileContentsMonitor.SetOnNewData(AValue: TNewDataEvent);
begin
  Lock;
  try
    FOnNewData := AValue;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TFileContentsMonitor.GetOnNewData: TNewDataEvent;
begin
  Lock;
  try
    Result := FOnNewData;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

end.
