unit Settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, INIFiles;

type

  { TSettingsForm }

  TSettingsForm = class(TForm)
    AddPathButton: TButton;
    MovieSearchPathsListBox: TListBox;
    RemovePathButton: TButton;
    MovieCollectionButton: TButton;
    ButtonPanel1: TButtonPanel;
    MovieCollectionPathEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure AddPathButtonClick(Sender: TObject);
    procedure RemovePathButtonClick(Sender: TObject);
    procedure MovieCollectionButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    AppProps: TINIFile;
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
  if SelectDirectoryDialog1.Execute then
    MovieCollectionPathEdit.Caption := SelectDirectoryDialog1.FileName;
end;

procedure TSettingsForm.AddPathButtonClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    MovieSearchPathsListBox.Items.Add(SelectDirectoryDialog1.FileName);
end;

procedure TSettingsForm.RemovePathButtonClick(Sender: TObject);
begin
  if MovieSearchPathsListBox.ItemIndex <> -1 then
    MovieSearchPathsListBox.Items.Delete(MovieSearchPathsListBox.ItemIndex);
end;

procedure TSettingsForm.FormActivate(Sender: TObject);
begin
  //read the settings
  MovieSearchPathsListBox.Items.Delimiter := ';';
  MovieSearchPathsListBox.Items.DelimitedText := AppProps.ReadString('Settings', 'MovieSearchPath', '');
  MovieCollectionPathEdit.Caption := AppProps.ReadString('Settings', 'MovieCollectionPath', '');
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  AppProps := TINIFile.Create(GetAppConfigFile(False));
end;

procedure TSettingsForm.OKButtonClick(Sender: TObject);
begin
  //save the settings and exit
  AppProps.WriteString('Settings', 'MovieSearchPath', MovieSearchPathsListBox.Items.DelimitedText);
  AppProps.WriteString('Settings', 'MovieCollectionPath', MovieCollectionPathEdit.Caption);
  AppProps.UpdateFile;

  Close;
end;

end.

