program MegaGRAPHBuilder;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {SheduleForm},
  uLexicalAnalyzer in 'uLexicalAnalyzer.pas',
  uSyntaxAnalyzer in 'uSyntaxAnalyzer.pas',
  uExtremaFinder in 'uExtremaFinder.pas',
  uBLFinder in 'uBLFinder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSheduleForm, uShedule);
  Application.Run;
end.
