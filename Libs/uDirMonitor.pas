////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Модуль       : uDirMonitor.pas
//  * Назначение   : Класс для отслеживания изменений в каталоге
//  * Copyright    : 2011 © Дмитрий Муратов
//  * Дата         : 18.05.2011
//  ****************************************************************************
//


{$WARN SYMBOL_PLATFORM OFF}

unit uDirMonitor;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, uBaseMonitor;

type

  TFileNotifyOption = (
    fnoNotifyFilename,
    fnoNotifyDirname,       // Применимо только к каталогам
    fnoNotifyAttributes,
    fnoNotifySize,
    fnoNotifyLastWrite,
    fnoNotifyLastAccess,
    fnoNotifyCreation,
    fnoNotifySecurity       // Применимо только к каталогам
    );

  TFileNotifyOptions = set of TFileNotifyOption;

  TFileNotifyAction = (fnaNoAction, fnaAdded, fnaRemoved, fnaModified,
    fnaRenameOldName, fnaRenameNewName);

  TFileNotifyActions = set of TFileNotifyAction;

const

  AllFileNotifyOptions = [fnoNotifyFilename, fnoNotifyDirname,
    fnoNotifyAttributes, fnoNotifySize, fnoNotifyLastWrite, fnoNotifyLastAccess,
    fnoNotifyCreation, fnoNotifySecurity];

  NoDirectoryNotifyOptions = AllFileNotifyOptions - [fnoNotifyDirname,
    fnoNotifySecurity];

  AllFileNotifyActions = [fnaAdded, fnaRemoved, fnaModified, fnaRenameOldName,
    fnaRenameNewName];

type

  EFileNotFoundException = class(Exception);

  TFileActionEvent = procedure(Sender: TObject; FileName: string;
    FileAction: TFileNotifyAction) of object;

  TDirMonitor = class(TBaseMonitor)
  const
    BufferLength = MAXWORD + 1;
  strict private
    FIsFile: boolean;
    FBuffer: PByte;
    FDirHandle: THandle;
    FOnFileAction: TFileActionEvent;
    FWatchSubtree: Boolean;
    FOptions: TFileNotifyOptions;
    FActions: TFileNotifyActions;
    FDirectoryToWatch: string;
    FFileNameToWatch: string;
    procedure OpenDirectory;
    procedure CloseDirectory;
    procedure ProcessNotifications;
   
    procedure SetDirectoryToWatch(AValue: string);
    function GetDirectoryToWatch: string;
    procedure SetFileNameToWatch(AValue: string);
    function GetFileNameToWatch: string;
    procedure SetWatchSubtree(AValue: boolean);
    function GetWatchSubtree: boolean;
    procedure SetOptions(AValue: TFileNotifyOptions);
    function GetOptions: TFileNotifyOptions;
    procedure SetActions(AValue: TFileNotifyActions);
    function GetActions: TFileNotifyActions;
    procedure SetOnFileAction(AValue: TFileActionEvent);
    function GetOnFileAction: TFileActionEvent;
  strict protected
    procedure DoFileAction(AFileName: string; AFileAction: TFileNotifyAction); virtual;
    procedure StartReadChanges; override;
    procedure InitWatch; override;
    procedure DoneWatch; override;
  public
    class function MakeFilterFromOptions(AOptions: TFileNotifyOptions): DWORD;
    class function WindowsFileActionToFileAction(AAction: DWORD): TFileNotifyAction;
    class function FileActionToString(AAction: TFileNotifyAction): string;
    constructor Create(const ADirectoryToWatch, AFileNameToWatch: string;
      AFileActionEvent: TFileActionEvent; AErrorEvent: TMonitorErrorEvent;
      AWatchSubtree: Boolean = true;
      AOptions: TFileNotifyOptions = AllFileNotifyOptions;
      AActions: TFileNotifyActions = AllFileNotifyActions);
    destructor Destroy; override;
    property OnFileAction: TFileActionEvent read GetOnFileAction write SetOnFileAction;
    property DirectoryToWatch: string read GetDirectoryToWatch write SetDirectoryToWatch;
    property FileNameToWatch: string read GetFileNameToWatch write SetFileNameToWatch;
    property WatchSubtree: Boolean read GetWatchSubtree write SetWatchSubtree;
    property Options: TFileNotifyOptions read GetOptions write SetOptions;
    property Actions: TFileNotifyActions read GetActions write SetActions;

  end;

implementation

resourcestring

  rsFileNotFoundException = 'File "%s" not found';
  rsFileUnknownAction = 'File unknown action';
  rsFileAddedAction = 'File added';
  rsFileDeletedAction = 'File deleted';
  rsFileModifiedAction = 'File modified';
  rsFileRenamedOldNameAction = 'File renamed, old file name';
  rsFileRenamedNewNameAction = 'File renamed, new file name';

type

  PFileNotifyInformation = ^TFileNotifyInformation;
  TFileNotifyInformation = record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: array[0..0] of WideChar;
  end;

const

  FileNotifyFlags: array[TFileNotifyOption] of DWORD = (
    FILE_NOTIFY_CHANGE_FILE_NAME,
    FILE_NOTIFY_CHANGE_DIR_NAME,
    FILE_NOTIFY_CHANGE_ATTRIBUTES,
    FILE_NOTIFY_CHANGE_SIZE,
    FILE_NOTIFY_CHANGE_LAST_WRITE,
    FILE_NOTIFY_CHANGE_LAST_ACCESS,
    FILE_NOTIFY_CHANGE_CREATION,
    FILE_NOTIFY_CHANGE_SECURITY
  );

  FileNotifyActions: array[TFileNotifyAction] of DWORD = (
    0,
    FILE_ACTION_ADDED,
    FILE_ACTION_REMOVED,
    FILE_ACTION_MODIFIED,
    FILE_ACTION_RENAMED_OLD_NAME,
    FILE_ACTION_RENAMED_NEW_NAME
  );

  FileNotifyActionStrings: array[Low(TFileNotifyAction)..High(TFileNotifyAction)] of string =
    (rsFileUnknownAction,
     rsFileAddedAction,
     rsFileDeletedAction,
     rsFileModifiedAction,
     rsFileRenamedOldNameAction,
     rsFileRenamedNewNameAction);

//------------------------------------------------------------------------------

class function TDirMonitor.WindowsFileActionToFileAction(AAction: DWORD): TFileNotifyAction;
begin     
  case AAction of
    FILE_ACTION_ADDED: Result := fnaAdded;
    FILE_ACTION_REMOVED: Result := fnaRemoved;
    FILE_ACTION_MODIFIED: Result := fnaModified;
    FILE_ACTION_RENAMED_OLD_NAME: Result := fnaRenameOldName;
    FILE_ACTION_RENAMED_NEW_NAME: Result := fnaRenameNewName;
  else
    Result := fnaNoAction;  
  end;
end;

//------------------------------------------------------------------------------

class function TDirMonitor.FileActionToString(AAction: TFileNotifyAction): string;
begin
  Result := FileNotifyActionStrings[AAction];
end;

//------------------------------------------------------------------------------

constructor TDirMonitor.Create(const ADirectoryToWatch, AFileNameToWatch: string;
  AFileActionEvent: TFileActionEvent; AErrorEvent: TMonitorErrorEvent;
  AWatchSubtree: Boolean = true;
  AOptions: TFileNotifyOptions = AllFileNotifyOptions;
  AActions: TFileNotifyActions = AllFileNotifyActions);
begin
  FOptions := AOptions;
  FActions := AActions;

  FOnFileAction := AFileActionEvent;

  FWatchSubtree := AWatchSubtree;
  FFileNameToWatch := AFileNameToWatch;
  FDirectoryToWatch := IncludeTrailingPathDelimiter(ADirectoryToWatch);

  GetMem(FBuffer, BufferLength);
  inherited Create(AErrorEvent);
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.InitWatch;
begin
  if Length(FFileNameToWatch) > 0 then
    begin
      if not FileExists(FFileNameToWatch) then
        raise EFileNotFoundException.CreateFmt(rsFileNotFoundException, [FFileNameToWatch]);
      FDirectoryToWatch := ExtractFilePath(FFileNameToWatch);
      FWatchSubtree := false;
      FOptions := FOptions - [fnoNotifyDirname, fnoNotifySecurity];
      FIsFile := True;
    end
  else
    begin
      FIsFile := False;
    end;
  OpenDirectory;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.DoneWatch;
begin
  CloseDirectory;
end;

//------------------------------------------------------------------------------

class function TDirMonitor.MakeFilterFromOptions(AOptions: TFileNotifyOptions): DWORD;
var
  Option: TFileNotifyOption;
begin
  result := 0;
  for Option := Low(TFileNotifyOption) to High(TFileNotifyOption) do
    if Option in AOptions then
      Inc(Result, FileNotifyFlags[Option]);
end;

//------------------------------------------------------------------------------

destructor TDirMonitor.Destroy;
begin
  FreeMem(FBuffer, BufferLength);
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.DoFileAction(AFileName: string; AFileAction: TFileNotifyAction);
begin
  if Assigned(OnFileAction) then
    OnFileAction(Self, AFileName, AFileAction);

end;

//------------------------------------------------------------------------------

procedure TDirMonitor.OpenDirectory;
const
  FILE_LIST_DIRECTORY = 1;
begin
  FDirHandle := CreateFile(PChar(DirectoryToWatch),
    FILE_LIST_DIRECTORY or GENERIC_READ,
    FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
    nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
  Win32Check(FDirHandle <> INVALID_HANDLE_VALUE);
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.CloseDirectory;
begin
  CloseHandle(FDirHandle);
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.ProcessNotifications;
var
  FileName: string;
  FileNameBuff: PWideChar;
  Action: TFileNotifyAction;
  NextOffset: DWORD;
  InfoPointer: PFileNotifyInformation;
begin
  InfoPointer := PFileNotifyInformation(FBuffer);
  repeat
    NextOffset := InfoPointer.NextEntryOffset;

    // Все эти манипуляции требуются из-за того, что в InfoPointer.FileName
    // лежит PWideChar строка, без завершающего нулевого символа, перегоняем
    // в string в 2 этапа, сначала добавляем завершающий ноль, потом
    // преобразовываем к string
    GetMem(FileNameBuff, InfoPointer.FileNameLength + SizeOf(WideChar));
    try
      FillChar(FileNameBuff^, InfoPointer.FileNameLength + SizeOf(WideChar), 0);
      lstrcpynW(FileNameBuff, @InfoPointer.FileName,
        InfoPointer.FileNameLength div SizeOf(WideChar) + 1);
      FileName := WideCharToString(FileNameBuff);
    finally
      FreeMem(FileNameBuff);
    end;

    Action := WindowsFileActionToFileAction(InfoPointer.Action);
    if Action in Actions then
      begin
        if FIsFile then
          begin
            if AnsiLowerCase(FileNameToWatch) =
              AnsiLowerCase(DirectoryToWatch + FileName) then
              DoFileAction(FileNameToWatch,
                WindowsFileActionToFileAction(InfoPointer.Action));
          end
        else
          begin
            DoFileAction(DirectoryToWatch + FileName,
              WindowsFileActionToFileAction(InfoPointer.Action));
          end;
      end;

    PByte(InfoPointer) := PByte(NativeUInt(InfoPointer) + NextOffset);

  until (NextOffset = 0) or Terminated;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.StartReadChanges;
var
  BytesRead: DWORD;
  Overlap: TOverlapped;
  Events: array[0..1] of THandle;
  WaitResult: DWORD;
begin
  FillChar(Overlap, SizeOf(TOverlapped), 0);
  Overlap.hEvent := FChangeHandle;
  Events[0] := FChangeHandle;
  Events[1] := FShutdownEventHandle;
  while not Terminated do
    begin
      FillChar(FBuffer^, BufferLength, 0);
      Win32Check(ReadDirectoryChangesW(FDirHandle, FBuffer, BufferLength, WatchSubtree,
        MakeFilterFromOptions(Options), @BytesRead, @Overlap, nil));
      WaitResult := WaitForMultipleObjects(2, @Events[0], False, INFINITE);
      case WaitResult of
        WAIT_OBJECT_0:
          // Есть изменения
          ProcessNotifications;
        WAIT_OBJECT_0 + 1:
          // Мониторинг прерывают
          begin
            // Сбрасываем событие
            Win32Check(ResetEvent(FShutdownEventHandle));
            Break;
          end;
        WAIT_FAILED:
          // Ошибка
          RaiseLastOSError;
      end;
    end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetDirectoryToWatch(AValue: string);
begin
  Lock;
  try
    if AValue <> FDirectoryToWatch then
      begin
        FDirectoryToWatch := IncludeTrailingPathDelimiter(AValue);
        ResetWatch;
      end;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetDirectoryToWatch: string;
begin
  Lock;
  try
    Result := FDirectoryToWatch;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetFileNameToWatch(AValue: string);
begin
  Lock;
  try
    if AValue <> FFileNameToWatch then
      begin
        FFileNameToWatch := AValue;
        ResetWatch;
      end;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetFileNameToWatch: string;
begin
  Lock;
  try
    Result := FFileNameToWatch;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetWatchSubtree(AValue: boolean);
begin
  Lock;
  try
    if AValue <> FWatchSubtree then
      begin
        FWatchSubtree := AValue;
        ResetWatch;
      end;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetWatchSubtree: boolean;
begin
  Lock;
  try
    Result := FWatchSubtree;
  finally
    Unlock
  end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetOptions(AValue: TFileNotifyOptions);
begin
  Lock;
  try
    if AValue <> FOptions then
      begin
        FOptions := AValue;
        ResetWatch;
      end;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetOptions: TFileNotifyOptions;
begin
  Lock;
  try
    Result := FOptions;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetActions(AValue: TFileNotifyActions);
begin
  Lock;
  try
    if AValue <> FActions then
      begin
        FActions := AValue;
        ResetWatch;
      end;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetActions: TFileNotifyActions;
begin
  Lock;
  try
    Result := FActions;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

procedure TDirMonitor.SetOnFileAction(AValue: TFileActionEvent);
begin
  Lock;
  try
    FOnFileAction := AValue;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

function TDirMonitor.GetOnFileAction: TFileActionEvent;
begin
  Lock;
  try
    Result := FOnFileAction;
  finally
    Unlock;
  end;
end;

//------------------------------------------------------------------------------

end.
