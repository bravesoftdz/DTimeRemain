unit Unit1;

interface

uses
  Windows, SysUtils, Forms, Registry, TlHelp32, Classes, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  GlobaLabelNewCreate1, GlobaLabelNewCreate2, GlobaLabelNewCreate3 :boolean;
  I_Img, I_Agent, I_Pro: integer;
  ARRAYHWND_Img: array of integer;

implementation

{$R *.dfm}

procedure FilesF(Input, WillFi: string);
var
 F1: TextFile;
 S: string;
begin
 S:='';
 if FileExists(Input) then
   begin
     AssignFile(F1, Input);
     Reset(F1);
       Repeat
         Readln(F1, S);
         if S = WillFi then
           begin
             CloseFile(F1);
             break;
           end;
         if Eof(F1) then
           begin
             CloseFile(F1);
             AssignFile(F1, Input);
             Append(F1);
             Writeln(F1);
             Write(F1, WillFi);
             CloseFile(F1);
             break;
           end;
       Until Eof(F1)
   end;
end;

function ProcName(Proc: string): integer;
var
 Process: PROCESSENTRY32;
 Cth32: Cardinal;
begin
 Result:=0;
 Cth32:=CreateToolHelp32Snapshot(TH32CS_SNAPALL, 0);
 Process.dwSize:=SizeOf(PROCESSENTRY32);
 Process32First(Cth32, Process);
 while Process32Next(Cth32, Process) do
   begin
     if Process.szExeFile = Proc then
       begin
         Inc(Result);
         //th:=OpenProcess(PROCESS_ALL_ACCESS,false,p.th32ProcessID);
         //TerminateProcess(th,0);
       end;
   end;
 CloseHandle(Cth32);  
end;

function FindText(Classi, Captions: string): integer;
var
 Wnd: hWnd;
 buff: array [0..255] of Char;
 buffOr: array [0..255] of Char;
begin
 Result:=0;
 Wnd:=GetWindow(Application.Handle, gw_HWndFirst);
 while Wnd <> 0 do
   begin {Не показываем:}
     if (Wnd <> Application.Handle) {-Собственное окно}
       and (IsWindowVisible(Wnd)) {-Невидимые окна}
       and (GetWindow(Wnd, gw_Owner) = 0) {-Дочернии окна}
     then
       begin
         GetWindowText(Wnd, buff, SizeOf(buff));     {Береи Caption Формы}
         GetClassName(Wnd, buffOr, SizeOf(buffOr));  {Берем имя класса}
         if (Pos(Captions, StrPas(buff)) <> 0) and (StrPas(buffOr) = Classi)  then
           begin
             Result:=Wnd;
           end;
       end;
     Wnd := GetWindow(Wnd, gw_hWndNext);
   end;
end;

procedure AvtOn(Name: string);
var
 RegFile: TRegistry;
begin
 RegFile:=TRegistry.Create;
 with RegFile do
   begin
     RootKey:=HKEY_LOCAL_MACHINE;
     OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', true);
     WriteString(Name, Application.ExeName);  //А можно и ParamStr(0) или GetModuleFileName(0, buffer, SizeOf(buffer))
     CloseKey;
     Free;
   end;
end;

procedure RegNewCreate;
var
 st: TSystemTime;
 RegFile: TRegistry;
begin
 GetLocalTime(st);
 AvtOn('DTime');
 FilesF('C:\WINDOWS\system32\drivers\etc\hosts', '127.0.0.1 secure.disc-soft.com');
 RegFile:=TRegistry.Create;
 With RegFile do
   begin
     OpenKey('Software\DT Time', true);
     WriteString('NewDateTime', DateTimeToStr(SystemTimeToDateTime(st)));
     CloseKey;
     Free;
   end;  
end;

procedure RegOld;
var
 st: TSystemTime;
 RegFile: TRegistry;
begin
 GetLocalTime(st);
 RegFile:=TRegistry.Create;
 RegFile.OpenKey('Software\DT Time', true);
 if not(RegFile.ValueExists('OldDateTime')) then
   begin
     RegFile.WriteString('OldDateTime', DateTimeToStr(SystemTimeToDateTime(st)));
   end
 else
   begin
     DateTimeToSystemTime(StrToDateTime(RegFile.ReadString('OldDateTime')), st);
     SetLocalTime(st);
   end;
 RegFile.CloseKey;  
 RegFile.Free;
end;

procedure RegNew;
var
 st: TSystemTime;
 RegFile: TRegistry;
begin
 GetLocalTime(st);
 RegFile:=TRegistry.Create;
 RegFile.OpenKey('Software\DT Time', true);
 DateTimeToSystemTime(StrToDateTime(RegFile.ReadString('NewDateTime')), st);
 SetLocalTime(st);
 RegFile.CloseKey;
 RegFile.Free;
end;

procedure Swap(var a, b: integer);
var
 c:integer;
begin
 c:=a;
 a:=b;
 b:=c;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 PN_Img, PN_Pro, PN_Agent: integer;
 HWND_Img ,HWND_Pro_Advanced, HWND_Pro_Standard, HWND_Agent: integer;
 Buffer: array [0..255] of char;
 I: integer;
begin
 I:=0;

 PN_Pro:=  ProcName('DTPro.exe');
 PN_Img:=  ProcName('DTImgEditor.exe');
 PN_Agent:=ProcName('DTAgent.exe');

 HWND_Pro_Advanced:=  FindText('Afx:00400000:0', 'DAEMON Tools Pro Advanced Edition');
 HWND_Pro_Standard:=  FindText('Afx:00400000:0', 'DAEMON Tools Pro Standard Edition');
 HWND_Img:=           FindText('Afx:00400000:0', 'DAEMON Tools Pro Image Editor');
 HWND_Agent:=         FindWindow('Afx:00400000:80b', 'DAEMON Tools Agent window');

 if PN_Agent > I_Agent then
   begin
     if not(GlobaLabelNewCreate1 or GlobaLabelNewCreate2 or GlobaLabelNewCreate3) then
       begin
         RegNewCreate;
       end;
     GlobaLabelNewCreate1:=true;
     RegOld;
     if IsWindow(HWND_Agent) then
       begin
         SetWindowText(HWND_Agent, 'Daemon Tools Agent');
         Inc(I_Agent);
       end;
   end
 else
   begin
     if not(not(GlobaLabelNewCreate1) or GlobaLabelNewCreate2 or GlobaLabelNewCreate3) then
       begin
         RegNew;
       end;
     I_Agent:=PN_Agent;
     GlobaLabelNewCreate1:=false;
   end;

 if PN_Img > I_Img then
   begin
     if not(GlobaLabelNewCreate1 or GlobaLabelNewCreate2 or GlobaLabelNewCreate3) then
       begin
         RegNewCreate;
       end;
     GlobaLabelNewCreate2:=true;
     RegOld;
     if IsWindow(HWND_Img) then
       begin
         While (I <= Length(ARRAYHWND_Img)-1) do
           begin
             if not(IsWindow(ARRAYHWND_Img[I])) then
               begin
                 Swap(ARRAYHWND_Img[I], ARRAYHWND_Img[Length(ARRAYHWND_Img)-1]);
                 SetLength(ARRAYHWND_Img, Length(ARRAYHWND_Img)-1);
                 Dec(I);
               end;
             Inc(I);
           end;
         if Length(ARRAYHWND_Img) = 0 then
           begin
             Inc(I_Img);
             SetLength(ARRAYHWND_Img, 1);
             ARRAYHWND_Img[0]:=HWND_Img;
           end
         else
           begin
             for I:=0 to Length(ARRAYHWND_Img)-1 do
               begin
                 if ARRAYHWND_Img[I] = HWND_Img then
                   begin
                     break;
                   end;
                 if I = Length(ARRAYHWND_Img)-1 then
                   begin
                     Inc(I_Img);
                     SetLength(ARRAYHWND_Img, Length(ARRAYHWND_Img)+1);
                     ARRAYHWND_Img[Length(ARRAYHWND_Img)-1]:=HWND_Img;
                   end;
               end;
           end;
         GetWindowText(HWND_Img, Buffer, SizeOf(Buffer));
         SetWindowText(HWND_Img, PAnsiChar('Daemon Tools Pro Image Editor - ' + Copy(StrPas(Buffer), 33, length(StrPas(Buffer)) - 66)));
       end;
   end
 else
   begin
     if not(GlobaLabelNewCreate1 or not(GlobaLabelNewCreate2) or GlobaLabelNewCreate3) then
       begin
         RegNew;
       end;
     if IsWindow(HWND_Img) then
       begin
         GetWindowText(HWND_Img, Buffer, SizeOf(Buffer));
         SetWindowText(HWND_Img, PAnsiChar('Daemon Tools Pro Image Editor - ' + Copy(StrPas(Buffer), 33, length(StrPas(Buffer)) - 66)));
       end;   
     I_Img:=PN_Img;
     GlobaLabelNewCreate2:=false;
   end;

 if (PN_Pro > I_Pro) and (I_Pro = 0) then
   begin
     if not(GlobaLabelNewCreate1 or GlobaLabelNewCreate2 or GlobaLabelNewCreate3) then
       begin
         RegNewCreate;
       end;
     GlobaLabelNewCreate3:=true;
     RegOld;
     if IsWindow(HWND_Pro_Advanced) or IsWindow(HWND_Pro_Standard) then
       begin
         SetWindowText(HWND_Pro_Advanced, 'Daemon Tools Pro Advanced Edition');
         SetWindowText(HWND_Pro_Standard, 'Daemon Tools Pro Standard Edition');
         Inc(I_Pro);
       end;
   end
 else
   begin
     if not(GlobaLabelNewCreate1 or GlobaLabelNewCreate2 or not(GlobaLabelNewCreate3)) then
       begin
         RegNew;
       end;
     if IsWindow(HWND_Pro_Advanced) or IsWindow(HWND_Pro_Standard) then
       begin
         SetWindowText(HWND_Pro_Advanced, 'Daemon Tools Pro Advanced Edition');
         SetWindowText(HWND_Pro_Standard, 'Daemon Tools Pro Standard Edition');
       end;
     I_Pro:=PN_Pro;
     GlobaLabelNewCreate3:=false;
   end;
end;

end.
