unit Alcinoe.Localization;

interface

{$I Alcinoe.inc}

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  System.SysUtils,
  System.Generics.Collections;

type

  {$IFNDEF ALCompilerVersionSupported130}
    {$MESSAGE WARN 'Check if System.SysUtils.TFormatSettings is still the same and adjust the IFDEF'}
  {$ENDIF}

  pALFormatSettingsA = ^TALFormatSettingsA;
  TALFormatSettingsA = record
  public
    type
      TEraInfo = record
        EraName: ansiString;
        EraOffset: Integer;
        EraStart: TDate;
        EraEnd: TDate;
      end;
  public
    // Important: Do not change the order of these declarations, they must
    // match the declaration order of the corresponding globals variables exactly!
    CurrencyString: AnsiString;
    CurrencyFormat: Byte;
    CurrencyDecimals: Byte;
    DateSeparator: AnsiChar;
    TimeSeparator: AnsiChar;
    ListSeparator: AnsiString;
    ShortDateFormat: AnsiString;
    LongDateFormat: AnsiString;
    TimeAMString: AnsiString;
    TimePMString: AnsiString;
    ShortTimeFormat: AnsiString;
    LongTimeFormat: AnsiString;
    ShortMonthNames: array[1..12] of AnsiString;
    LongMonthNames: array[1..12] of AnsiString;
    ShortDayNames: array[1..7] of AnsiString;
    LongDayNames: array[1..7] of AnsiString;
    EraInfo: array of TEraInfo;
    ThousandSeparator: AnsiString;
    DecimalSeparator: AnsiChar;
    TwoDigitYearCenturyWindow: Word;
    NegCurrFormat: Byte;
    // Creates a TALFormatSettingsA record with current default values provided
    // by the operating system.
    class function Create: TALFormatSettingsA; overload; static; inline;
    // Creates a TALFormatSettingsA record with values provided by the operating
    // system for the specified locale. The locale is an LCID on Windows
    // platforms, or a locale_t on Posix platforms.
    {$IF defined(MSWINDOWS)}
    class function Create(Locale: LCID): TALFormatSettingsA; overload; platform; static;
    {$ENDIF}
    // Creates a TALFormatSettingsA record with values provided by the operating
    // system for the specified locale name in the "Language-Country" format.
    // Example: 'en-US' for U.S. English settings or 'en-UK' for UK English settings.
    class function Create(const LocaleName: AnsiString): TALFormatSettingsA; overload; static;
    function GetEraYearOffset(const Name: ansistring): Integer;
  end;

  pALFormatSettingsW = ^TALFormatSettingsW;
  TALFormatSettingsW = TFormatSettings;

  function ALGetFormatSettingsID(const aFormatSettings: TALFormatSettingsA): AnsiString;
  {$IF defined(MSWINDOWS)}
  procedure ALGetLocaleFormatSettings(Locale: LCID; var AFormatSettings: TALFormatSettingsA); platform;
  {$ENDIF}

var
  ALDefaultFormatSettingsA: TALformatSettingsA;
  ALDefaultFormatSettingsW: TALformatSettingsW;

implementation

uses
  System.Math,
  System.AnsiStrings,
  Alcinoe.Common,
  Alcinoe.StringUtils;

{**********************}
{$IF defined(MSWINDOWS)}
class function TALFormatSettingsA.Create(Locale: LCID): TALFormatSettingsA;
var LFormatSettings: TformatSettings;
    I: integer;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  LFormatSettings:= TformatSettings.Create(Locale);
  {$WARN SYMBOL_PLATFORM ON}
  with result do begin
    CurrencyString := AnsiString(LFormatSettings.CurrencyString);
    CurrencyFormat := LFormatSettings.CurrencyFormat;
    CurrencyDecimals := LFormatSettings.CurrencyDecimals;
    DateSeparator := AnsiChar(LFormatSettings.DateSeparator);
    TimeSeparator := AnsiChar(LFormatSettings.TimeSeparator);
    ListSeparator := AnsiString(LFormatSettings.ListSeparator);
    ShortDateFormat := AnsiString(LFormatSettings.ShortDateFormat);
    LongDateFormat := AnsiString(LFormatSettings.LongDateFormat);
    TimeAMString := AnsiString(LFormatSettings.TimeAMString);
    TimePMString := AnsiString(LFormatSettings.TimePMString);
    ShortTimeFormat := AnsiString(LFormatSettings.ShortTimeFormat);
    LongTimeFormat := AnsiString(LFormatSettings.LongTimeFormat);
    for I := Low(ShortMonthNames) to High(ShortMonthNames) do
      ShortMonthNames[i] := AnsiString(LFormatSettings.ShortMonthNames[i]);
    for I := Low(LongMonthNames) to High(LongMonthNames) do
      LongMonthNames[i] := AnsiString(LFormatSettings.LongMonthNames[i]);
    for I := Low(ShortDayNames) to High(ShortDayNames) do
      ShortDayNames[i] := AnsiString(LFormatSettings.ShortDayNames[i]);
    for I := Low(LongDayNames) to High(LongDayNames) do
      LongDayNames[i] := AnsiString(LFormatSettings.LongDayNames[i]);
    setlength(EraInfo, length(LFormatSettings.EraInfo));
    for I := Low(LFormatSettings.EraInfo) to High(LFormatSettings.EraInfo) do begin
      EraInfo[i].EraName := ansiString(LFormatSettings.EraInfo[i].EraName);
      EraInfo[i].EraOffset := LFormatSettings.EraInfo[i].EraOffset;
      EraInfo[i].EraStart := LFormatSettings.EraInfo[i].EraStart;
      EraInfo[i].EraEnd := LFormatSettings.EraInfo[i].EraEnd;
    end;
    ThousandSeparator := AnsiString(LFormatSettings.ThousandSeparator);
    DecimalSeparator := AnsiChar(LFormatSettings.DecimalSeparator);
    TwoDigitYearCenturyWindow := LFormatSettings.TwoDigitYearCenturyWindow;
    NegCurrFormat := LFormatSettings.NegCurrFormat;
  end;
end;
{$ENDIF}

{*****************************************************************************************}
class function TALFormatSettingsA.Create(const LocaleName: AnsiString): TALFormatSettingsA;
var LFormatSettings: TformatSettings;
    I: integer;
begin
  LFormatSettings:= TformatSettings.Create(String(LocaleName));
  with result do begin
    CurrencyString := AnsiString(LFormatSettings.CurrencyString);
    CurrencyFormat := LFormatSettings.CurrencyFormat;
    CurrencyDecimals := LFormatSettings.CurrencyDecimals;
    DateSeparator := AnsiChar(LFormatSettings.DateSeparator);
    TimeSeparator := AnsiChar(LFormatSettings.TimeSeparator);
    ListSeparator := AnsiString(LFormatSettings.ListSeparator);
    ShortDateFormat := AnsiString(LFormatSettings.ShortDateFormat);
    LongDateFormat := AnsiString(LFormatSettings.LongDateFormat);
    TimeAMString := AnsiString(LFormatSettings.TimeAMString);
    TimePMString := AnsiString(LFormatSettings.TimePMString);
    ShortTimeFormat := AnsiString(LFormatSettings.ShortTimeFormat);
    LongTimeFormat := AnsiString(LFormatSettings.LongTimeFormat);
    for I := Low(ShortMonthNames) to High(ShortMonthNames) do
      ShortMonthNames[i] := AnsiString(LFormatSettings.ShortMonthNames[i]);
    for I := Low(LongMonthNames) to High(LongMonthNames) do
      LongMonthNames[i] := AnsiString(LFormatSettings.LongMonthNames[i]);
    for I := Low(ShortDayNames) to High(ShortDayNames) do
      ShortDayNames[i] := AnsiString(LFormatSettings.ShortDayNames[i]);
    for I := Low(LongDayNames) to High(LongDayNames) do
      LongDayNames[i] := AnsiString(LFormatSettings.LongDayNames[i]);
    setlength(EraInfo, length(LFormatSettings.EraInfo));
    for I := Low(LFormatSettings.EraInfo) to High(LFormatSettings.EraInfo) do begin
      EraInfo[i].EraName := ansiString(LFormatSettings.EraInfo[i].EraName);
      EraInfo[i].EraOffset := LFormatSettings.EraInfo[i].EraOffset;
      EraInfo[i].EraStart := LFormatSettings.EraInfo[i].EraStart;
      EraInfo[i].EraEnd := LFormatSettings.EraInfo[i].EraEnd;
    end;
    ThousandSeparator := AnsiString(LFormatSettings.ThousandSeparator);
    DecimalSeparator := AnsiChar(LFormatSettings.DecimalSeparator);
    TwoDigitYearCenturyWindow := LFormatSettings.TwoDigitYearCenturyWindow;
    NegCurrFormat := LFormatSettings.NegCurrFormat;
  end;
end;

{$IFNDEF ALCompilerVersionSupported130}
  {$MESSAGE WARN 'Check if System.SysUtils.TFormatSettings.GetEraYearOffset is still the same and adjust the IFDEF'}
{$ENDIF}
function TALFormatSettingsA.GetEraYearOffset(const Name: ansistring): Integer;
var
  I: Integer;
begin
  Result := -MaxInt;
  for I := High(EraInfo) downto Low(EraInfo) do
  begin
    if EraInfo[I].EraName = '' then Break;
    if ALPosA(EraInfo[I].EraName, Name) > 0 then
    begin
      Result := EraInfo[I].EraOffset - 1;
      Exit;
    end;
  end;
end;

{***********************************************************}
class function TALFormatSettingsA.Create: TALFormatSettingsA;
begin
  Result := TALFormatSettingsA.Create('');
end;

{************************************************************************************}
function ALGetFormatSettingsID(const aFormatSettings: TALFormatSettingsA): AnsiString;
begin
  With aFormatSettings do begin
    Result := ALIntToStrA(CurrencyFormat) + '#' +
              ALIntToStrA(CurrencyDecimals) + '#' +
              DateSeparator + '#' +
              TimeSeparator + '#' +
              ListSeparator + '#' +
              ShortDateFormat + '#' +
              LongDateFormat + '#' +
              ShortTimeFormat + '#' +
              LongTimeFormat + '#' +
              ThousandSeparator + '#' +
              DecimalSeparator + '#' +
              ALIntToStrA(TwoDigitYearCenturyWindow) + '#' +
              ALIntToStrA(NegCurrFormat);
  end;
end;

{**********************}
{$IF defined(MSWINDOWS)}
procedure ALGetLocaleFormatSettings(Locale: LCID; var AFormatSettings: TALFormatSettingsA);
begin
  AFormatSettings := TALFormatSettingsA.Create(Locale);
end;
{$ENDIF}

initialization
  ALDefaultFormatSettingsA := TALFormatSettingsA.Create('en-US'); // 1033 {en-US}
  ALDefaultFormatSettingsA.CurrencyString := '$';
  ALDefaultFormatSettingsA.CurrencyFormat := 0;
  ALDefaultFormatSettingsA.CurrencyDecimals := 2;
  ALDefaultFormatSettingsA.DateSeparator := '/';
  ALDefaultFormatSettingsA.TimeSeparator := ':';
  ALDefaultFormatSettingsA.ListSeparator := ';';
  ALDefaultFormatSettingsA.ShortDateFormat := 'M/d/yyyy';
  ALDefaultFormatSettingsA.LongDateFormat := 'dddd, MMMM d, yyyy';
  ALDefaultFormatSettingsA.TimeAMString := 'AM';
  ALDefaultFormatSettingsA.TimePMString := 'PM';
  ALDefaultFormatSettingsA.ShortTimeFormat := 'h:mm AMPM';
  ALDefaultFormatSettingsA.LongTimeFormat := 'h:mm:ss AMPM';
  ALDefaultFormatSettingsA.ShortMonthNames[1] := 'Jan';
  ALDefaultFormatSettingsA.LongMonthNames [1] := 'January';
  ALDefaultFormatSettingsA.ShortMonthNames[2] := 'Feb';
  ALDefaultFormatSettingsA.LongMonthNames [2] := 'February';
  ALDefaultFormatSettingsA.ShortMonthNames[3] := 'Mar';
  ALDefaultFormatSettingsA.LongMonthNames [3] := 'March';
  ALDefaultFormatSettingsA.ShortMonthNames[4] := 'Apr';
  ALDefaultFormatSettingsA.LongMonthNames [4] := 'April';
  ALDefaultFormatSettingsA.ShortMonthNames[5] := 'May';
  ALDefaultFormatSettingsA.LongMonthNames [5] := 'May';
  ALDefaultFormatSettingsA.ShortMonthNames[6] := 'Jun';
  ALDefaultFormatSettingsA.LongMonthNames [6] := 'June';
  ALDefaultFormatSettingsA.ShortMonthNames[7] := 'Jul';
  ALDefaultFormatSettingsA.LongMonthNames [7] := 'July';
  ALDefaultFormatSettingsA.ShortMonthNames[8] := 'Aug';
  ALDefaultFormatSettingsA.LongMonthNames [8] := 'August';
  ALDefaultFormatSettingsA.ShortMonthNames[9] := 'Sep';
  ALDefaultFormatSettingsA.LongMonthNames [9] := 'September';
  ALDefaultFormatSettingsA.ShortMonthNames[10] := 'Oct';
  ALDefaultFormatSettingsA.LongMonthNames [10] := 'October';
  ALDefaultFormatSettingsA.ShortMonthNames[11] := 'Nov';
  ALDefaultFormatSettingsA.LongMonthNames [11] := 'November';
  ALDefaultFormatSettingsA.ShortMonthNames[12] := 'Dec';
  ALDefaultFormatSettingsA.LongMonthNames [12] := 'December';
  ALDefaultFormatSettingsA.ShortDayNames[1] := 'Sun';
  ALDefaultFormatSettingsA.LongDayNames [1] := 'Sunday';
  ALDefaultFormatSettingsA.ShortDayNames[2] := 'Mon';
  ALDefaultFormatSettingsA.LongDayNames [2] := 'Monday';
  ALDefaultFormatSettingsA.ShortDayNames[3] := 'Tue';
  ALDefaultFormatSettingsA.LongDayNames [3] := 'Tuesday';
  ALDefaultFormatSettingsA.ShortDayNames[4] := 'Wed';
  ALDefaultFormatSettingsA.LongDayNames [4] := 'Wednesday';
  ALDefaultFormatSettingsA.ShortDayNames[5] := 'Thu';
  ALDefaultFormatSettingsA.LongDayNames [5] := 'Thursday';
  ALDefaultFormatSettingsA.ShortDayNames[6] := 'Fri';
  ALDefaultFormatSettingsA.LongDayNames [6] := 'Friday';
  ALDefaultFormatSettingsA.ShortDayNames[7] := 'Sat';
  ALDefaultFormatSettingsA.LongDayNames [7] := 'Saturday';
  ALDefaultFormatSettingsA.ThousandSeparator := ',';
  ALDefaultFormatSettingsA.DecimalSeparator := '.';
  ALDefaultFormatSettingsA.TwoDigitYearCenturyWindow := 50;
  ALDefaultFormatSettingsA.NegCurrFormat := 0;

  ALDefaultFormatSettingsW := TALFormatSettingsW.Create('en-US'); // 1033 {en-US}
  ALDefaultFormatSettingsW.CurrencyString := '$';
  ALDefaultFormatSettingsW.CurrencyFormat := 0;
  ALDefaultFormatSettingsW.CurrencyDecimals := 2;
  ALDefaultFormatSettingsW.DateSeparator := '/';
  ALDefaultFormatSettingsW.TimeSeparator := ':';
  ALDefaultFormatSettingsW.ListSeparator := ';';
  ALDefaultFormatSettingsW.ShortDateFormat := 'M/d/yyyy';
  ALDefaultFormatSettingsW.LongDateFormat := 'dddd, MMMM d, yyyy';
  ALDefaultFormatSettingsW.TimeAMString := 'AM';
  ALDefaultFormatSettingsW.TimePMString := 'PM';
  ALDefaultFormatSettingsW.ShortTimeFormat := 'h:mm AMPM';
  ALDefaultFormatSettingsW.LongTimeFormat := 'h:mm:ss AMPM';
  ALDefaultFormatSettingsW.ShortMonthNames[1] := 'Jan';
  ALDefaultFormatSettingsW.LongMonthNames [1] := 'January';
  ALDefaultFormatSettingsW.ShortMonthNames[2] := 'Feb';
  ALDefaultFormatSettingsW.LongMonthNames [2] := 'February';
  ALDefaultFormatSettingsW.ShortMonthNames[3] := 'Mar';
  ALDefaultFormatSettingsW.LongMonthNames [3] := 'March';
  ALDefaultFormatSettingsW.ShortMonthNames[4] := 'Apr';
  ALDefaultFormatSettingsW.LongMonthNames [4] := 'April';
  ALDefaultFormatSettingsW.ShortMonthNames[5] := 'May';
  ALDefaultFormatSettingsW.LongMonthNames [5] := 'May';
  ALDefaultFormatSettingsW.ShortMonthNames[6] := 'Jun';
  ALDefaultFormatSettingsW.LongMonthNames [6] := 'June';
  ALDefaultFormatSettingsW.ShortMonthNames[7] := 'Jul';
  ALDefaultFormatSettingsW.LongMonthNames [7] := 'July';
  ALDefaultFormatSettingsW.ShortMonthNames[8] := 'Aug';
  ALDefaultFormatSettingsW.LongMonthNames [8] := 'August';
  ALDefaultFormatSettingsW.ShortMonthNames[9] := 'Sep';
  ALDefaultFormatSettingsW.LongMonthNames [9] := 'September';
  ALDefaultFormatSettingsW.ShortMonthNames[10] := 'Oct';
  ALDefaultFormatSettingsW.LongMonthNames [10] := 'October';
  ALDefaultFormatSettingsW.ShortMonthNames[11] := 'Nov';
  ALDefaultFormatSettingsW.LongMonthNames [11] := 'November';
  ALDefaultFormatSettingsW.ShortMonthNames[12] := 'Dec';
  ALDefaultFormatSettingsW.LongMonthNames [12] := 'December';
  ALDefaultFormatSettingsW.ShortDayNames[1] := 'Sun';
  ALDefaultFormatSettingsW.LongDayNames [1] := 'Sunday';
  ALDefaultFormatSettingsW.ShortDayNames[2] := 'Mon';
  ALDefaultFormatSettingsW.LongDayNames [2] := 'Monday';
  ALDefaultFormatSettingsW.ShortDayNames[3] := 'Tue';
  ALDefaultFormatSettingsW.LongDayNames [3] := 'Tuesday';
  ALDefaultFormatSettingsW.ShortDayNames[4] := 'Wed';
  ALDefaultFormatSettingsW.LongDayNames [4] := 'Wednesday';
  ALDefaultFormatSettingsW.ShortDayNames[5] := 'Thu';
  ALDefaultFormatSettingsW.LongDayNames [5] := 'Thursday';
  ALDefaultFormatSettingsW.ShortDayNames[6] := 'Fri';
  ALDefaultFormatSettingsW.LongDayNames [6] := 'Friday';
  ALDefaultFormatSettingsW.ShortDayNames[7] := 'Sat';
  ALDefaultFormatSettingsW.LongDayNames [7] := 'Saturday';
  ALDefaultFormatSettingsW.ThousandSeparator := ',';
  ALDefaultFormatSettingsW.DecimalSeparator := '.';
  ALDefaultFormatSettingsW.TwoDigitYearCenturyWindow := 50;
  ALDefaultFormatSettingsW.NegCurrFormat := 0;
end.
