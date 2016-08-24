program DTime;

uses
  Forms,
  Windows,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

function Check: boolean;
begin
  if OpenMutex(MUTEX_ALL_ACCESS, false, 'OstapBender_DAEMONToolsPro') <> 0 then
    begin
      Result:=true;
    end
  else
    begin
      Result:=false;
      CreateMutex(nil, false, 'OstapBender_DAEMONToolsPro');
    end;  
end;

begin
  if Check then
    begin
      MessageBeep(MB_ICONEXCLAMATION);
      Application.Terminate;
    end;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.ShowMainForm:=False;
  Application.Run;
end.
