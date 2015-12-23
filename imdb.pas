unit IMDb;

{$mode objfpc}{$H+}

interface

uses
  Graphics;

type
  TIMDbMovieData = record
    Title: string;
    Year: string;
    Rated: string;
    Released: string;
    Runtime: string;
    Genre: string;
    Director: string;
    Writer: string;
    Actors: string;
    Plot: string;
    Language: string;
    Country: string;
    Awards: string;
    Poster: string;
    Metascore: string;
    imdbRating: string;
    imdbVotes: string;
    imdbID: string;
    _Type: string;
    Response: boolean;
  end;

  TMovieFile = record
    IMDbData: TIMDbMovieData;
    FilePath: string;
    IsMovieFile: boolean;
    PosterCache: TPicture;
  end;
  PMovieFile = ^TMovieFile;

function IMDb_movie_data_from_filename(org_filename: string): TIMDbMovieData;
function IMDb_movie_data_from_title(title: string; year: integer = 0): TIMDbMovieData;
function IMDb_movie_data_from_URL(URL: string): TIMDbMovieData;
function IMDb_movie_data_from_imdbID(imdbID: string; year: integer): TIMDbMovieData;

implementation

uses
  Classes, SysUtils, StrUtils,
  httpsend,
  fpjson;

//invalid names that will be stripped from the filename
const
  replace: array[1..104] of string = (
    '1080',
    '1080p',
    '1337x',
    '1cdrip',
    '385mb',
    '3d',
    '3li',
    '3lt0n',
    '480p',
    '4playhd',
    '500mb',
    '576p',
    '699mb',
    '700mb',
    '720p',
    '7o9',
    'a2zrg',
    'ac3',
    'amiable',
    'amx',
    'aqos',
    'archivist',
    'axxo',
    'b89',
    'badmeetsevil',
    'bdrip',
    'bestdivx',
    'bida',
    'bluray',
    'brrip',
    'cc',
    'com',
    'didee',
    'dvd',
    'dvdrip',
    'dvdscr',
    'dxva',
    'eng',
    'enghindiindonesian',
    'esub',
    'etrg',
    'extratorrent',
    'extratorrentrg',
    'fasm',
    'ftw',
    'fxg',
    'gb',
    'glowgaze',
    'goku61',
    'greenbud',
    'h264',
    'hdrip',
    'hellraz0r',
    'hindi',
    'hq',
    'hr',
    'hsbs',
    'imb',
    'jalucian',
    'line',
    'maxspeed',
    'mkv',
    'moh',
    'mp4',
    'mpg',
    'mxmg',
    'neroz',
    'nl',
    'noir',
    'phrax',
    'psig',
    'ptpower',
    'r5',
    'readnfo',
    'rel',
    'release',
    'revott',
    'rip',
    'rips',
    's4a',
    'sc0rp',
    'secretmyth',
    'stylishsalh',
    'subs',
    'taste',
    'thewretched',
    'titan',
    'tode',
    'torrentfive',
    'tots',
    'trippleaudio',
    'tv',
    'unrated',
    'usabit',
    'usabitcom',
    'v2',
    'vip3r',
    'warrlord',
    'webrip',
    'www',
    'x264',
    'xmas',
    'xvid',
    'yify');

function IMDb_movie_data_from_filename(org_filename: string): TIMDbMovieData;
var
  filename: string;
  file_ext: string;
  year: integer;
  y: integer;
  i: integer;
  fname: TStringList;
  str: string;
  index: integer;
begin
  //remove the extension from the filename and make it lower case
  file_ext := ExtractFileExt(org_filename);
  filename := ReplaceStr(LowerCase(org_filename), file_ext, ' ');

  //extract year of the movie
  year := 0;
  for y := 1900 to 2099 do
  begin
    if pos(IntToStr(y), org_filename) > 0 then
    begin
      filename := ReplaceStr(filename, IntToStr(y), ' ');
      year := y;
      break;
    end;
  end;

  //replace all non-numerical and non-alphabetical characters with whitespace
  for i := 1 to length(filename) do
  begin
    if not (filename[i] in ['a'..'z', 'A'..'Z', '0'..'9']) then
      filename[i] := ' ';
  end;

  //remove double whitespaces
  filename := ReplaceStr(Trim(filename), '  ', ' ');

  //split the filename into "words"
  fname := TStringList.Create;
  fname.Delimiter := ' ';
  fname.DelimitedText := filename;

  //remove all forbidden words
  for str in replace do
  begin
    index := fname.IndexOf(str);
    if index >= 0 then
    begin
      fname.Delete(index);
    end;
  end;

  Result := IMDb_movie_data_from_title(fname.DelimitedText, year);

  fname.Free;
end;

function IMDb_get_json_result(const url: string): TIMDbMovieData;
var
  jsonvalues: TJSONData;
  l: TStringList;
  HTTP: THTTPSend;
begin
  try
    HTTP := THTTPSend.Create;
    if not HTTP.HTTPMethod('GET', url) then
    begin
      //writeln('ERROR');
      //writeln(HTTP.Resultcode);
    end
    else
    begin
      //writeln(HTTP.Resultcode, ' ', HTTP.Resultstring);
      //writeln;
      //writeln(HTTP.Headers.Text);
      //writeln;
      l := TStringList.Create;
      l.loadfromstream(HTTP.Document);
      //writeln(l.Text);

      jsonvalues := GetJSON(l.Text);

      if jsonvalues.FindPath('Response').AsBoolean = True then
      begin
        Result.Title:=jsonvalues.FindPath('Title').AsString;
        Result.Year:=jsonvalues.FindPath('Year').AsString;
        Result.Rated:=jsonvalues.FindPath('Rated').AsString;
        Result.Released:=jsonvalues.FindPath('Released').AsString;
        Result.Runtime:=jsonvalues.FindPath('Runtime').AsString;
        Result.Genre:=jsonvalues.FindPath('Genre').AsString;
        Result.Director:=jsonvalues.FindPath('Director').AsString;
        Result.Writer:=jsonvalues.FindPath('Writer').AsString;
        Result.Actors:=jsonvalues.FindPath('Actors').AsString;
        Result.Plot:=jsonvalues.FindPath('Plot').AsString;
        Result.Language:=jsonvalues.FindPath('Language').AsString;
        Result.Country:=jsonvalues.FindPath('Country').AsString;
        Result.Awards:=jsonvalues.FindPath('Awards').AsString;
        Result.Poster:=jsonvalues.FindPath('Poster').AsString;
        Result.Metascore:=jsonvalues.FindPath('Metascore').AsString;
        Result.imdbRating:=jsonvalues.FindPath('imdbRating').AsString;
        Result.imdbVotes:=jsonvalues.FindPath('imdbVotes').AsString;
        Result.imdbID:=jsonvalues.FindPath('imdbID').AsString;
        Result._Type:=jsonvalues.FindPath('Type').AsString;
        Result.Response:= true;
      end
      else
        Result.Response:= false;
    end;
  finally
    HTTP.Free;
    l.Free;
  end;
end;

function IMDb_movie_data_from_title(title: string; year: integer = 0): TIMDbMovieData;
var
  url: string;
  stitle: string;
begin
  //format the IMDb url

  stitle := ReplaceStr(title, ' ', '+');

  if year <> 0 then
    url := 'http://www.omdbapi.com/?t=' + stitle + '&y=' + IntToStr(year) + '&r=json'
  else
    url := 'http://www.omdbapi.com/?t=' + stitle + '&r=json';
  //writeln(url);

  Result := IMDb_get_json_result(url);
end;

function IMDb_movie_data_from_URL(URL: string): TIMDbMovieData;
var
  imdbID: String;
begin
  //http://www.imdb.com/title/tt1230194/?ref_=nv_sr_1

  //strip the URL until the IMDbID is found
  imdbID := copy(URL, 27, 9);
  Result := IMDb_movie_data_from_imdbID(imdbID, 0);
end;

function IMDb_movie_data_from_imdbID(imdbID: string; year: integer): TIMDbMovieData;
var
  url: string;

begin
  //format the IMDb url
  if year <> 0 then
    url := 'http://www.omdbapi.com/?i=' + imdbID + '&y=' + IntToStr(year) + '&r=json'
  else
    url := 'http://www.omdbapi.com/?i=' + imdbID + '&r=json';
  //writeln(url);

  Result := IMDb_get_json_result(url);
end;

end.

