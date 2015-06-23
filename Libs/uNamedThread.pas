////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Модуль       : uNamedThread.pas
//  * Назначение   : Расширение базового класса TThread с возможностью
//  *              : создания именованных потоков
//  * Copyright    : 2011 © Дмитрий Муратов
//  ****************************************************************************
//

unit uNamedThread;

interface

uses
  {$IFDEF MSWINDOWS}Windows, {$ENDIF}Classes, SysUtils;

type

  {$REGION 'Documentation'}
  /// <summary>
  /// Класс именованного потока
  /// </summary>
  {$ENDREGION}
  TNamedThread = class(TThread)
  private
    FThreadName: String;
    procedure SetName(const AValue: String);
  public
    {$REGION 'Documentation'}
    /// <summary>
    /// Назначает имя вызывающему потоку
    /// </summary>
    /// <param name="AThreadName">Имя потока</param>
    /// <param name="AThreadID">ID потока</param>
    /// <remarks>
    /// см. http://msdn.microsoft.com/en-us/library/xcb2z8hs(VS.71).aspx
    /// </remarks>
    {$ENDREGION}
    class procedure SetThreadName(AThreadName: String; AThreadID: LongWord = LongWord(-1));
    {$REGION 'Documentation'}
    /// <summary>
    /// Возвращает имя вызывающего потока, при условии,
    /// что к нему применялась ранее функция  SetThreadName (см.выше)
    /// Если имя потоку не назначено, то возвращается его ID в виде HEX строки
    /// </summary>
    {$ENDREGION}
    class function GetCurentThreadName: string;
    property ThreadName: String read FThreadName write SetName;
  end;

implementation

threadvar
  _InternalThreadName: String;

//------------------------------------------------------------------------------

class procedure TNamedThread.SetThreadName(AThreadName: String; AThreadID: LongWord = LongWord(-1));
{$IFDEF MSWINDOWS}
type
  TThreadNameInfo = record
    InfoType: LongWord;         // Всегда 0x1000
    Name: PChar;                // Имя потока
    ThreadID: LongWord;         // Thread ID (-1 ) для вызывающего потока)
    Reserved: LongWord;         // Зарезервировано
  end;
const
  cSetThreadNameExcep = $406D1388;
  DefaultInfoType     = $1000;
var
  ThreadNameInfo: TThreadNameInfo;
begin
  FillChar(ThreadNameInfo, SizeOf(ThreadNameInfo), 0);
  ThreadNameInfo.InfoType := DefaultInfoType;
  ThreadNameInfo.Name := PChar(AThreadName);

  if (AThreadID = Cardinal(-1)) or (AThreadID = GetCurrentThreadID) then
    _InternalThreadName := AThreadName;

  ThreadNameInfo.ThreadID := AThreadID;
  try
    RaiseException(cSetThreadNameExcep, 0, SizeOf(ThreadNameInfo) div SizeOf(LongWord),
      @ThreadNameInfo);
  except
    //
  end;
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  _InternalThreadName := AThreadName;
end;
{$ENDIF}

//------------------------------------------------------------------------------

class function TNamedThread.GetCurentThreadName: string;
begin
  Result := _InternalThreadName;
  if Length(Result) = 0 then
    Result := '0x'+ IntToHex(GetCurrentThreadID, 8);
end;

//------------------------------------------------------------------------------

procedure TNamedThread.SetName(const AValue: String);
begin
  if FThreadName <> AValue then
    begin
      FThreadName := AValue;
      SetThreadName(FThreadName, ThreadID);
    end;
end;

end.


