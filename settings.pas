unit Settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, ComCtrls, Properties;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    AddPathButton: TButton;
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MovieCollectionButton: TButton;
    MovieCollectionPathEdit: TEdit;
    MovieDatabaseButton: TButton;
    MovieDatabaseEdit: TEdit;
    MovieSearchPathsListBox: TListBox;
    OpenDialog: TOpenDialog;
    PageControl1: TPageControl;
    RemovePathButton: TButton;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure AddPathButtonClick(Sender: TObject);
    procedure RemovePathButtonClick(Sender: TObject);
    procedure MovieCollectionButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$R *.lfm}

{ TSettingsForm }

procedure TSettingsForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.MovieCollectionButtonClick(Sender: TObject);
begin
  if SelectDirectoryDialog.Execute then
    MovieCollectionPathEdit.Caption := SelectDirectoryDialog.FileName;
end;

procedure TSettingsForm.AddPathButtonClick(Sender: TObject);
begin
  if SelectDirectoryDialog.Execute then
    MovieSearchPathsListBox.Items.Add(SelectDirectoryDialog.FileName);
end;

procedure TSettingsForm.RemovePathButtonClick(Sender: TObject);
begin
  if MovieSearchPathsListBox.ItemIndex <> -1 then
    MovieSearchPathsListBox.Items.Delete(MovieSearchPathsListBox.ItemIndex);
end;

procedure TSettingsForm.FormActivate(Sender: TObject);
begin
  //read the settings
  MovieDatabaseEdit.Caption := PropertiesINIReadString('Settings', 'MovieDB', '');

  MovieSearchPathsListBox.Items.Delimiter := ';';
  MovieSearchPathsListBox.Items.DelimitedText := AppProps.ReadString('Settings', 'MovieSearchPath', '');
  MovieCollectionPathEdit.Caption := AppProps.ReadString('Settings', 'MovieCollectionPath', '');
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
begin
  //save the settings and exit
  AppProps.WriteString('Settings', 'MovieSearchPath', MovieSearchPathsListBox.Items.DelimitedText);
  AppProps.WriteString('Settings', 'MovieCollectionPath', MovieCollectionPathEdit.Caption);

  Close;
end;

end.

