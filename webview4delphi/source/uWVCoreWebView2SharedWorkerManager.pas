unit uWVCoreWebView2SharedWorkerManager;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

{$I webview2.inc}

interface

uses
  {$IFDEF DELPHI16_UP}
  System.Classes, Winapi.ActiveX,
  {$ELSE}
  Classes, ActiveX,
  {$ENDIF}
  uWVTypeLibrary, uWVTypes;

type
  /// <summary>
  /// This class manages shared workers in WebView2.
  /// </summary>
  /// <remarks>
  /// <para><see href="https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2sharedworkermanager">See the ICoreWebView2SharedWorkerManager article.</see></para>
  /// </remarks>
  TCoreWebView2SharedWorkerManager = class
    protected
      FBaseIntf                   : ICoreWebView2SharedWorkerManager;
      FSharedWorkerCreatedToken   : EventRegistrationToken;

      function GetInitialized : boolean;

      procedure InitializeFields;
      procedure InitializeTokens;
      procedure RemoveAllEvents;
      function  AddSharedWorkerCreatedEvent(const aBrowserComponent : TComponent) : boolean;

    public
      /// <summary>
      /// Constructor of the ICoreWebView2SharedWorkerManager wrapper.
      /// </summary>
      /// <param name="aBaseIntf">The ICoreWebView2SharedWorkerManager instance.</param>
      constructor Create(const aBaseIntf : ICoreWebView2SharedWorkerManager); reintroduce;
      destructor  Destroy; override;
      /// <summary>
      /// Adds all the events of this class to an existing TWVBrowserBase instance.
      /// </summary>
      /// <param name="aBrowserComponent">The TWVBrowserBase instance.</param>
      function    AddAllBrowserEvents(const aBrowserComponent : TComponent) : boolean;
      /// <summary>
      /// Gets a list of the shared workers created under the same profile. It triggers the TWVBrowser.OnGetSharedWorkersCompleted event.
      /// </summary>
      function    GetSharedWorkers(const aBrowserComponent : TComponent): boolean;
      /// <summary>
      /// Returns true when the interface implemented by this class is fully initialized.
      /// </summary>
      property Initialized         : boolean                                read GetInitialized;
      /// <summary>
      /// Returns the interface implemented by this class.
      /// </summary>
      property BaseIntf            : ICoreWebView2SharedWorkerManager       read FBaseIntf;
  end;

implementation

uses
  uWVMiscFunctions, uWVBrowserBase, uWVCoreWebView2Delegates, uWVConstants;

constructor TCoreWebView2SharedWorkerManager.Create(const aBaseIntf: ICoreWebView2SharedWorkerManager);
begin
  inherited Create;

  InitializeFields;

  FBaseIntf := aBaseIntf;
end;

destructor TCoreWebView2SharedWorkerManager.Destroy;
begin
  try
    RemoveAllEvents;
    InitializeFields;
  finally
    inherited Destroy;
  end;
end;

procedure TCoreWebView2SharedWorkerManager.InitializeFields;
begin
  FBaseIntf := nil;

  InitializeTokens;
end;

procedure TCoreWebView2SharedWorkerManager.InitializeTokens;
begin
  FSharedWorkerCreatedToken.value := 0;
end;

procedure TCoreWebView2SharedWorkerManager.RemoveAllEvents;
begin
  if Initialized then
    begin
      if (FSharedWorkerCreatedToken.value <> 0) then
        FBaseIntf.remove_SharedWorkerCreated(FSharedWorkerCreatedToken);

      InitializeTokens;
    end;
end;

function TCoreWebView2SharedWorkerManager.AddSharedWorkerCreatedEvent(const aBrowserComponent : TComponent) : boolean;
var
  TempHandler : ICoreWebView2SharedWorkerCreatedEventHandler;
begin
  Result := False;

  if Initialized and (FSharedWorkerCreatedToken.value = 0) then
    try
      TempHandler := TCoreWebView2SharedWorkerCreatedEventHandler.Create(TWVBrowserBase(aBrowserComponent));
      Result      := succeeded(FBaseIntf.add_SharedWorkerCreated(TempHandler, FSharedWorkerCreatedToken));
    finally
      TempHandler := nil;
    end;
end;

function TCoreWebView2SharedWorkerManager.AddAllBrowserEvents(const aBrowserComponent : TComponent) : boolean;
begin
  Result := AddSharedWorkerCreatedEvent(aBrowserComponent);
end;

function TCoreWebView2SharedWorkerManager.GetInitialized : boolean;
begin
  Result := assigned(FBaseIntf);
end;

function TCoreWebView2SharedWorkerManager.GetSharedWorkers(const aBrowserComponent : TComponent): boolean;
var
  TempHandler : ICoreWebView2GetSharedWorkersCompletedHandler;
begin
  Result := False;

  if Initialized then
    try
      TempHandler := TCoreWebView2GetSharedWorkersCompletedHandler.Create(TWVBrowserBase(aBrowserComponent));
      Result      := succeeded(FBaseIntf.GetSharedWorkers(TempHandler));
    finally
      TempHandler := nil;
    end;
end;

end.
