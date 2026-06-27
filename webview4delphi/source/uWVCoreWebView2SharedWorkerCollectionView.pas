unit uWVCoreWebView2SharedWorkerCollectionView;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

{$I webview2.inc}

interface

uses
  uWVTypeLibrary;

type
  /// <summary>
  /// A collection of ICoreWebView2SharedWorker.
  /// </summary>
  /// <remarks>
  /// <para><see href="https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2sharedworkercollectionview">See the ICoreWebView2SharedWorkerCollectionView article.</see></para>
  /// </remarks>
  TCoreWebView2SharedWorkerCollectionView = class
    protected
      FBaseIntf : ICoreWebView2SharedWorkerCollectionView;

      function GetInitialized : boolean;
      function GetCount : cardinal;
      function GetValueAtIndex(index : cardinal) : ICoreWebView2SharedWorker;

    public
      constructor Create(const aBaseIntf : ICoreWebView2SharedWorkerCollectionView); reintroduce;
      destructor  Destroy; override;

      /// <summary>
      /// Returns true when the interface implemented by this class is fully initialized.
      /// </summary>
      property Initialized           : boolean                                                  read GetInitialized;
      /// <summary>
      /// Returns the interface implemented by this class.
      /// </summary>
      property BaseIntf              : ICoreWebView2SharedWorkerCollectionView                  read FBaseIntf;
      /// <summary>
      /// The number of elements contained in the collection.
      /// </summary>
      property Count                 : cardinal                                                 read GetCount;
      /// <summary>
      /// Gets the element at the given index.
      /// </summary>
      property Items[idx : cardinal] : ICoreWebView2SharedWorker                                read GetValueAtIndex;
  end;

implementation

uses
  {$IFDEF DELPHI16_UP}
  Winapi.ActiveX;
  {$ELSE}
  ActiveX;
  {$ENDIF}

constructor TCoreWebView2SharedWorkerCollectionView.Create(const aBaseIntf: ICoreWebView2SharedWorkerCollectionView);
begin
  inherited Create;

  FBaseIntf := aBaseIntf;
end;

destructor TCoreWebView2SharedWorkerCollectionView.Destroy;
begin
  FBaseIntf := nil;

  inherited Destroy;
end;

function TCoreWebView2SharedWorkerCollectionView.GetInitialized : boolean;
begin
  Result := assigned(FBaseIntf);
end;

function TCoreWebView2SharedWorkerCollectionView.GetCount : cardinal;
var
  TempResult : SYSUINT;
begin
  Result     := 0;
  TempResult := 0;

  if Initialized and
     succeeded(FBaseIntf.Get_Count(TempResult)) then
    Result := TempResult;
end;

function TCoreWebView2SharedWorkerCollectionView.GetValueAtIndex(index : cardinal) : ICoreWebView2SharedWorker;
var
  TempResult : ICoreWebView2SharedWorker;
begin
  Result     := nil;
  TempResult := nil;

  if Initialized and
     succeeded(FBaseIntf.GetValueAtIndex(index, TempResult)) and
     assigned(TempResult) then
    Result := TempResult;
end;

end.
