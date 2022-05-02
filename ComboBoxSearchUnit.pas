unit ComboBoxSearchUnit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Dialogs,
  Winapi.Messages, System.Messaging, Winapi.Windows, System.StrUtils;

type
  TComboBoxSearch = class(TComboBox)
  private
    FStoredItems: TStringList;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
    procedure FilterItems;
    procedure StoredItemsChange(Sender: TObject);
    procedure SetStoredItems(const Value: TStringList);
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property StoredItems: TStringList read FStoredItems write SetStoredItems;

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('GozimSoft', [TComboBoxSearch]);
end;

{ TComboBoxSearch }

procedure TComboBoxSearch.CNCommand(var AMessage: TWMCommand);
begin
  inherited;
  // if we received the CBN_EDITUPDATE notification
  if AMessage.NotifyCode = CBN_EDITUPDATE then
    // fill the items with the matches
    FilterItems;
end;

constructor TComboBoxSearch.Create(AOwner: TComponent);
begin
  inherited;
  AutoComplete := False;
  FStoredItems := TStringList.Create;
  FStoredItems.OnChange := StoredItemsChange;
end;

destructor TComboBoxSearch.Destroy;
begin
  FStoredItems.Free;
  inherited;
end;

procedure TComboBoxSearch.FilterItems;
var
  i: Integer;
  Selection: TSelection;
begin
  // store the current combo edit selection
  SendMessage(Handle, CB_GETEDITSEL, WPARAM(@Selection.StartPos),
    LPARAM(@Selection.EndPos));
  // begin with the items update
  Items.BeginUpdate;
  try
    // if the combo edit is not empty, then clear the items
    // and search through the FStoredItems
    if Text <> '' then
    begin
      // clear all items
      Items.Clear;
      // iterate through all of them
      for i := 0 to FStoredItems.Count - 1 do
        if ContainsText(FStoredItems[i], Text) then
        begin
          if Assigned(FStoredItems.Objects[i]) then
            Items.AddObject(FStoredItems[i], FStoredItems.Objects[i])
          else
            Items.Add(FStoredItems[i]);
        end;
    end
    else
    // so then we'll use all what we have in the FStoredItems
    begin
      Items.Clear;
      Items.Assign(FStoredItems);
    end;

    if Items.Count > 0 then
      if Text <> EmptyStr then
        DroppedDown := True

  finally
    // finish the items update
    Items.EndUpdate;
  end;
  // and restore the last combo edit selection
  SendMessage(Handle, CB_SETEDITSEL, 0, MakeLParam(Selection.StartPos,
    Selection.EndPos));

end;

procedure TComboBoxSearch.SetStoredItems(const Value: TStringList);
begin
  if Assigned(FStoredItems) then
    FStoredItems.Assign(Value)
  else
    FStoredItems := Value;
end;

procedure TComboBoxSearch.StoredItemsChange(Sender: TObject);
begin
  if Assigned(FStoredItems) then
    FilterItems;
end;

end.
