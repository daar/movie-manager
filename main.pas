unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics,
  Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls,
  httpsend,
  IMDb, Process, Settings, About, sqlite3conn, sqldb, db,
  ManualLookup,
  //WinFF
  Unit1;

type

  { TMainForm }

  TMainForm = class(TForm)
    DataSource: TDataSource;
    OpenDBMenuItem: TMenuItem;
    NewDBMenuItem: TMenuItem;
    OpenDialog: TOpenDialog;
    PlayButton: TButton;
    ManualLookupButton: TButton;
    RenameFileButton: TButton;
    Splitter2: TSplitter;
    SQLQuery: TSQLQuery;
    TranscodeFileButton: TButton;
    Image1: TImage;
    MenuImageList: TImageList;
    Label1: TLabel;
    SQLite3Connection: TSQLite3Connection;
    TitleLabel: TLabel;
    MainMenu: TMainMenu;
    FileMenuItem: TMenuItem;
    QuitMenuItem: TMenuItem;
    HelpMenuItem: TMenuItem;
    AboutMenuItem: TMenuItem;
    MovieDetailPanel: TPanel;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    IndexFilesToolButton: TToolButton;
    MovieInfoToolButton: TToolButton;
    SettingsToolButton: TToolButton;
    SeparatorToolButton: TToolButton;
    MovieTreeView: TTreeView;
    procedure ManualLookupButtonClick(Sender: TObject);
    procedure MovieTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure NewDBMenuItemClick(Sender: TObject);
    procedure OpenDBMenuItemClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure RenameFileButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure QuitMenuItemClick(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
    procedure IndexFilesToolButtonClick(Sender: TObject);
    procedure MovieInfoToolButtonClick(Sender: TObject);
    procedure SettingsToolButtonClick(Sender: TObject);
    procedure TranscodeFileButtonClick(Sender: TObject);
  private
    { private declarations }
    MovieList: TList;
    procedure FileSearch(const PathName, FileName: string; const InDir: boolean);
    function CheckIfMovieIsValid(FilePath: string): boolean;
    function CheckIfImageIsValid(FilePath: string): boolean;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FileSearch(const PathName, FileName: string; const InDir: boolean);
var
  Rec: TSearchRec;
  Path: string;
  MovieFile: PMovieFile;
begin
  Path := IncludeTrailingBackslash(PathName);
  if FindFirst(Path + FileName, faAnyFile - faDirectory, Rec) = 0 then
    try
      repeat
        New(MovieFile);
        FillChar(MovieFile^, sizeof(TMovieFile), 0);

        MovieFile^.FilePath := Path + Rec.Name;
        MovieList.Add(MovieFile);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;

  if not InDir then
    Exit;

  if FindFirst(Path + '*', faDirectory, Rec) = 0 then
    try
      repeat
        if ((Rec.Attr and faDirectory) <> 0) and (Rec.Name <> '.') and
          (Rec.Name <> '..') then
          FileSearch(Path + Rec.Name, FileName, True);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
end;

function TMainForm.CheckIfMovieIsValid(FilePath: string): boolean;
const
  extList: array[1..36] of string = (
    '.3g2',
    '.3gp',
    '.asf',
    '.avi',
    '.drc',
    '.f4a',
    '.f4b',
    '.f4p',
    '.f4v',
    '.flv',
    '.gif',
    '.gifv',
    '.m2v',
    '.m4p',
    '.m4v',
    '.mkv',
    '.mng',
    '.mov',
    '.mp2',
    '.mp4',
    '.mpe',
    '.mpeg',
    '.mpg',
    '.mpv',
    '.mxf',
    '.nsv',
    '.ogg',
    '.ogv',
    '.qt',
    '.rm',
    '.rmvb',
    '.roq',
    '.svi',
//    '.vob',  //need to implement volume detection before we can support this extension
    '.webm',
    '.wmv',
    '.yuv');

var
  s: string = '';
  ext: string;
  Found: boolean;
begin
  Result := False;

  //check for valid filename extension
  ext := ExtractFileExt(filepath);
  Found := False;
  for s in extList do
  begin
    if s = ext then
      Found := True;
  end;

  //check with ffprobe if the file is a valid movie file
  if Found then
    if RunCommand('ffprobe', ['-i', filepath], s) then
      if Pos('Invalid data found when processing input', s) = 0 then
        Result := True;
end;

function TMainForm.CheckIfImageIsValid(FilePath: string): boolean;
const
  extList: array[1..4] of string = (
    '.png',
    '.jpg',
    '.jpeg',
    '.bmp');

var
  s: string = '';
  ext: string;
begin
  Result := False;

  //check for valid filename extension
  ext := ExtractFileExt(LowerCase(filepath));

  for s in extList do
  begin
    if s = ext then
      Result := True;
  end;
end;

procedure TMainForm.IndexFilesToolButtonClick(Sender: TObject);
var
  i: integer;
  li: TTreeNode;
  SearchPaths: TStrings;
  j: integer;
  mf: PMovieFile;
begin
  //Clear all items from the movie list!
  for i := 0 to MovieList.Count - 1 do
  begin
    mf := PMovieFile(MovieList.Items[i]);

    //free the poster cache
    if assigned(mf^.PosterCache) then
      FreeAndNil(mf^.PosterCache);

    //free the movie file record
    Dispose(mf);
  end;
  //clear the list
  MovieList.Clear;

  SearchPaths := TStringList.Create;
  SearchPaths.Delimiter := ';';
  SearchPaths.DelimitedText :=
    SettingsForm.AppProps.ReadString('Settings', 'MovieSearchPath', '');

  for j := 0 to SearchPaths.Count - 1 do
  begin
    //recursively search all files in folder
    FileSearch(SearchPaths[j], '*', True);
  end;

  //go through each file to check if it's a valid movie file
  for i := 0 to MovieList.Count - 1 do
  begin
    TMovieFile(MovieList.Items[i]^).IsMovieFile :=
      CheckIfMovieIsValid(TMovieFile(MovieList.Items[i]^).FilePath);
  end;

  //fill the listview with the results
  MovieTreeView.Items.Clear;
  for i := 0 to MovieList.Count - 1 do
  begin
    if TMovieFile(MovieList.Items[i]^).IsMovieFile then
    begin
      li := MovieTreeView.Items.Add(nil, ExtractFileName(TMovieFile(MovieList.Items[i]^).FilePath));
      li.Data := MovieList.Items[i];
    end;
  end;
  StatusBar1.Panels[0].Text := Format('%d movies', [MovieTreeView.Items.Count]);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MovieList := TList.Create;
end;

procedure TMainForm.ManualLookupButtonClick(Sender: TObject);
begin
  if Assigned(MovieTreeView.Selected) then
  begin
    ManualLookupForm.Data := MovieTreeView.Selected.Data;
    ManualLookupForm.ShowModal;

    //update the movie detail panel
    MovieTreeViewChange(Sender, MovieTreeView.Selected);
  end;
end;

procedure TMainForm.MovieTreeViewChange(Sender: TObject; Node: TTreeNode);
var
  mf: PMovieFile;
  response: TMemoryStream;
begin
  if Assigned(MovieTreeView.Selected) then
  begin
    mf := MovieTreeView.Selected.Data;

    if mf = nil then
      exit;

    if mf^.IMDbData.Title <> '' then
    begin
      if not Assigned(mf^.PosterCache) and CheckIfImageIsValid(mf^.IMDbData.Poster) then
      begin
        mf^.PosterCache := TPicture.Create;

        response := TMemoryStream.Create;
        try
          HttpGetBinary(mf^.IMDbData.Poster, response);
          response.Seek(0, soFromBeginning);
          mf^.PosterCache.LoadFromStream(response);
        finally
          response.Free;
        end;
      end;

      //show image if any was loaded
      if Assigned(mf^.PosterCache) then
        Image1.Picture := mf^.PosterCache
      else
        Image1.Picture.Clear;
    end
    else
      Image1.Picture.Clear;

    TitleLabel.Caption := mf^.IMDbData.Title;
    Label1.Caption := 'Year: ' + mf^.IMDbData.Year;
    Label1.Caption := Label1.Caption + sLineBreak + 'Rated: ' + mf^.IMDbData.Rated;
    Label1.Caption := Label1.Caption + sLineBreak + 'Released: ' +
      mf^.IMDbData.Released;
    Label1.Caption := Label1.Caption + sLineBreak + 'Runtime: ' + mf^.IMDbData.Runtime;
    Label1.Caption := Label1.Caption + sLineBreak + 'Genre: ' + mf^.IMDbData.Genre;
    Label1.Caption := Label1.Caption + sLineBreak + 'Director: ' +
      mf^.IMDbData.Director;
    Label1.Caption := Label1.Caption + sLineBreak + 'Writer: ' + mf^.IMDbData.Writer;
    Label1.Caption := Label1.Caption + sLineBreak + 'Actors: ' + mf^.IMDbData.Actors;
    Label1.Caption := Label1.Caption + sLineBreak + 'Plot: ' + mf^.IMDbData.Plot;
    Label1.Caption := Label1.Caption + sLineBreak + 'Language: ' +
      mf^.IMDbData.Language;
    Label1.Caption := Label1.Caption + sLineBreak + 'Country: ' + mf^.IMDbData.Country;
    Label1.Caption := Label1.Caption + sLineBreak + 'Awards: ' + mf^.IMDbData.Awards;
    Label1.Caption := Label1.Caption + sLineBreak + 'Metascore: ' +
      mf^.IMDbData.Metascore;
    Label1.Caption := Label1.Caption + sLineBreak + 'imdbRating: ' +
      mf^.IMDbData.imdbRating;
    Label1.Caption := Label1.Caption + sLineBreak + 'imdbVotes: ' +
      mf^.IMDbData.imdbVotes;
    Label1.Caption := Label1.Caption + sLineBreak + 'imdbID: ' + mf^.IMDbData.imdbID;
    Label1.Caption := Label1.Caption + sLineBreak + 'Type: ' + mf^.IMDbData._Type;
  end;
end;

procedure TMainForm.NewDBMenuItemClick(Sender: TObject);
begin
  //create a new movie database
  if OpenDialog.Execute then
  begin
    if FileExists(OpenDialog.FileName) then
    begin
      ShowMessage('File already exists, please select a new filename!');
      exit;
    end;


  end;
end;

procedure TMainForm.OpenDBMenuItemClick(Sender: TObject);
begin
  //open an existing database
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
var
  i: integer;
  filenametoplay: string;
  PlayProcess: TProcess;
  mf: PMovieFile;
begin
  if Assigned(MovieTreeView.Selected) then
  begin
    mf := MovieTreeView.Selected.Data;

    playprocess := TProcess.Create(nil);

    if not fileexists(ffplay) then
    begin
      ShowMessage(rsCouldNotFindFFplay);
      exit;
    end;

    filenametoplay := mf^.FilePath;
    if not fileexists(filenametoplay) then
    begin
      ShowMessage(rsCouldNotFindFile);
      exit;
    end;

    PlayProcess.Executable := ffplay;
    PlayProcess.Parameters.Add(filenametoplay);
    PlayProcess.Execute;
    PlayProcess.Free;
  end;
end;

procedure TMainForm.RenameFileButtonClick(Sender: TObject);
var
  mf: PMovieFile;
  new_filename: string;
begin
  if Assigned(MovieTreeView.Selected) then
  begin
    mf := MovieTreeView.Selected.Data;
    new_filename := Format('%s%s (%s)%s', [ExtractFilePath(mf^.FilePath),
      mf^.IMDbData.Title, mf^.IMDbData.Year, ExtractFileExt(mf^.FilePath)]);
    if MessageDlg('Rename file', 'File: ' + mf^.FilePath + ' wil be renamed to: ' +
      new_filename, mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
    begin
      //rename the moviefile
      RenameFile(mf^.FilePath, new_filename);

      //update the moviefile data structure
      mf^.FilePath := new_filename;

      //update the listview text
      MovieTreeView.Selected.Text := ExtractFileName(new_filename);
    end;
  end;
end;

procedure TMainForm.QuitMenuItemClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.MovieInfoToolButtonClick(Sender: TObject);
var
  li: TTreeNode;
  filepath: string;
  i: integer;
  j: integer = 0;
begin
  for i := 0 to MovieList.Count - 1 do
  begin
    if TMovieFile(MovieList.Items[i]^).IsMovieFile then
    begin
      filepath := TMovieFile(MovieList.Items[i]^).FilePath;

      TMovieFile(MovieList.Items[i]^).IMDbData :=
        IMDb_movie_data_from_filename(ExtractFileName(filepath));

      li := MovieTreeView.Items[j];
      li.Text := ExtractFileName(filepath);
      //li.SubItems.Add(TMovieFile(MovieList.Items[i]^).IMDbData.Title);
      //li.SubItems.Add(TMovieFile(MovieList.Items[i]^).IMDbData.Year);
      li.Data := MovieList.Items[i];

      Inc(j);
    end;
  end;
end;

procedure TMainForm.SettingsToolButtonClick(Sender: TObject);
begin
  SettingsForm.Show;
end;

procedure TMainForm.TranscodeFileButtonClick(Sender: TObject);
var
  mf: PMovieFile;
  fl: TStrings;
begin
  if Assigned(MovieTreeView.Selected) then
  begin
    mf := MovieTreeView.Selected.Data;

    //setup the WinFF application properly

    //ouput is the same as the source
    frmMain.cbOutputPath.Checked := True;

    //add the filepath to be processed
    fl := TStringList.Create;
    fl.Text := mf^.FilePath;
    frmMain.AddFilesToList(ExtractFilePath(mf^.FilePath), fl);
    fl.Free;

    //show the app
    frmMain.Show;
  end;
end;

end.
