unit uBaseMonitor;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Classes, Windows, Messages, SysUtils, SyncObjs, ActiveX, uNamedThread;

type

  TMonitorErrorEvent = procedure(Sender: TObject; E: Exception) of object;

  TBaseMonitor = class(TNamedThread)
  const
    DefErrorTimeOut = 5000;
  strict private
    FCS: TCriticalSection;
    FOnError: TMonitorErrorEvent;
  strict protected
    FNoCoInit: Boolean;
    FErrorTimeOut: Integer;
    FShutdownEventHandle: THandle;
    FChangeHandle: THandle;
    procedure Lock;
    procedure Unlock;
    procedure InitWatch; virtual; abstract;
    procedure DoneWatch; virtual; abstract;
    procedure StartReadChanges; virtual; abstract;
    procedure ResetWatch; virtual;
    procedure DoStartThread; virtual;
    procedure Execute; override;
    procedure DoError(E: Exception); virtual;
    procedure SetOnError(AValue: TMonitorErrorEvent);
    function GetOnError: TMonitorErrorEvent;
  public
    procedure Restart;
    constructor Create(AErrorEvent: TMonitorErrorEvent);
    destructor Destroy; override;
    procedure Shutdown(AWaitFor: boolean = true); virtual;
    property OnError: TMonitorErrorEvent read GetOnError write SetOnError;
  end;

implementation

//------------------------------------------------------------------------------

procedure TBaseMonitor.Lock;
begin
  FCS.Enter;
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.Unlock;
begin
  FCS.Leave;
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.Restart;
begin
  ResetWatch;
end;

//------------------------------------------------------------------------------

constructor TBaseMonitor.Create(AErrorEvent: TMonitorErrorEvent);
begin
  FNoCoInit := False;
  FCS := TCriticalSection.Create;
  FChangeHandle := CreateEvent(nil, false, false, nil);
  FShutdownEventHandle := CreateEvent(nil, false, false, nil);
  FOnError := AErrorEvent;
  FErrorTimeOut := DefErrorTimeOut;
  inherited Create(false);
end;

//------------------------------------------------------------------------------

destructor TBaseMonitor.Destroy;
begin
  if FChangeHandle <> 0 then
    CloseHandle(FChangeHandle);
  if FShutdownEventHandle <> 0 then
    CloseHandle(FShutdownEventHandle);
  FCS.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.DoStartThread;
begin
  //
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.Shutdown(AWaitFor: boolean = true);
begin
  Terminate;
  ResetWatch;
  if AWaitFor then
    WaitFor;
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.ResetWatch;
begin
  if FShutdownEventHandle <> 0 then
    Win32Check(SetEvent(FShutdownEventHandle));
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.Execute;
begin
  DoStartThread;
  if not FNoCoInit then
    CoInitialize(nil);
  while not Terminated do
  begin
    try
      InitWatch;
      try
        // Возврат из этой процедуры будет только при ошибке в ней или
        // при остановке мониторинга
        StartReadChanges;
      finally
        DoneWatch;
      end;
    except
      On E: Exception do
        begin
          DoError(E);
          // Делаем паузу перед новой попыткой в случае ошибки
          WaitForSingleObject(FShutdownEventHandle, FErrorTimeOut);
        end;
    end;
  end;
  if not FNoCoInit then
    CoUninitialize;
  ThreadName := '';
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.DoError(E: Exception);
begin
  if Assigned(OnError) then
    OnError(Self, E);
end;

//------------------------------------------------------------------------------

procedure TBaseMonitor.SetOnError(AValue: TMonitorErrorEvent);
begin
  Lock;
  try
    FOnError := AValue;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TBaseMonitor.GetOnError: TMonitorErrorEvent;
begin
  Lock;
  try
    Result := FOnError;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

end.
