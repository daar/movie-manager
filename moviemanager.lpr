program MovieManager;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  cmem,
  {$IFDEF UseCThreads}
    cthreads,
  {$ENDIF}
{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,

  Main, Settings, About, License, ManualLookup,

  //WinFF
  Unit1, Unit2, Unit3, Unit4, Unit5, Unit6, defaulttranslator, potranslator;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;

  //MovieManager
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TLicenseForm, LicenseForm);
  Application.CreateForm(TManualLookupForm, ManualLookupForm);

  //WinFF
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmEditPresets, frmEditPresets);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmScript, frmScript);
  Application.CreateForm(TfrmExport, frmExport);

  Application.Run;
end.
