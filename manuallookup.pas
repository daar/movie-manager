unit ManualLookup;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, StdCtrls, SysUtils,
  ButtonPanel,
  IMDb;

type

  { TManualLookupForm }

  TManualLookupForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    TitleEdit: TEdit;
    IMDbURLEdit: TEdit;
    IMDbIDEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure ButtonPanel1Click(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    Data: PMovieFile;
    { public declarations }
  end;

var
  ManualLookupForm: TManualLookupForm;

implementation

{$R *.lfm}

{ TManualLookupForm }

procedure TManualLookupForm.OKButtonClick(Sender: TObject);
var
  md: TIMDbMovieData;
begin
  //check in order of appearance

  if TitleEdit.Text <> '' then
  begin
    md := IMDb_movie_data_from_title(TitleEdit.Text);
    if md.Title <> '' then
    begin
      Data^.IMDbData := md;
      if assigned(Data^.PosterCache) then
        FreeAndNil(Data^.PosterCache);
      exit;
    end;
  end;

  if IMDbURLEdit.Text <> '' then
  begin
    md := IMDb_movie_data_from_URL(IMDbURLEdit.Text);
    begin
      Self.Data^.IMDbData := md;
      if assigned(Data^.PosterCache) then
        FreeAndNil(Data^.PosterCache);
      exit;
    end;
  end;

  if IMDbIDEdit.Text <> '' then
  begin
    md := IMDb_movie_data_from_imdbID(IMDbIDEdit.Text, 0);
    if md.Title <> '' then
    begin
      Self.Data^.IMDbData := md;
      if assigned(Data^.PosterCache) then
        FreeAndNil(Data^.PosterCache);
      exit;
    end;
  end;

  Close;
end;

procedure TManualLookupForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TManualLookupForm.ButtonPanel1Click(Sender: TObject);
begin

end;

procedure TManualLookupForm.FormActivate(Sender: TObject);
begin
  TitleEdit.Caption:= '';
  IMDbURLEdit.Caption:='';
  IMDbIDEdit.Caption:='';
end;

end.

