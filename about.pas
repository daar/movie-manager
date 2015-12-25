unit About;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, ExtCtrls, LCLIntf, Controls,
  StdCtrls, License;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GitHubLabel: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure GitHubLabelClick(Sender: TObject);
    procedure GitHubLabelMouseEnter(Sender: TObject);
    procedure GitHubLabelMouseLeave(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.GitHubLabelClick(Sender: TObject);
begin
  OpenURL('https://github.com/daar/movie-manager');
end;

procedure TAboutForm.GitHubLabelMouseEnter(Sender: TObject);
begin
  GitHubLabel.Cursor := crHandPoint;
  GitHubLabel.Font.Underline := True;
end;

procedure TAboutForm.GitHubLabelMouseLeave(Sender: TObject);
begin
  GitHubLabel.Cursor := crDefault;
  GitHubLabel.Font.Underline := False;
end;

procedure TAboutForm.Button2Click(Sender: TObject);
begin
  LicenseForm.Show;
end;

end.

