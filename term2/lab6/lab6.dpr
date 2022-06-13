program aisd_11;

uses
  Vcl.Forms,
  multik in 'multik.pas' {Form1},
  Animation in 'Animation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
