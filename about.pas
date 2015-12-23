unit About;

{$mode objfpc}{$H+}

interface

uses
  Classes, Forms, ExtCtrls,
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
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
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

procedure TAboutForm.Button2Click(Sender: TObject);
begin
  LicenseForm.Show;
end;

end.

