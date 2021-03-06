unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, WinAPI.Windows,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Media, FMX.Objects,
  WinAPI.Tlhelp32, FMX.ScrollBox, FMX.Memo;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    CameraComponent1: TCameraComponent;
    Image1: TImage;
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure FormShow(Sender: TObject);
  private
    procedure GetImage;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

var
  Pass: Boolean = false;
  Click: Boolean = false;
  wndTaskbar: HWND;
  i: integer = 0;

procedure TForm1.GetImage;
begin
  CameraComponent1.SampleBufferToBitmap(Image1.Bitmap, True);
end;

function LowLevelKeyboardProc(nCode: integer; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;

  TKBDLLHOOKSTRUCT = record
    vkCode: cardinal;
    scanCode: cardinal;
    flags: cardinal;
    time: cardinal;
    dwExtraInfo: cardinal;
  end;

  PKeyboardLowLevelHookStruct = ^TKeyboardLowLevelHookStruct;
  TKeyboardLowLevelHookStruct = TKBDLLHOOKSTRUCT;
const
  LLKHF_ALTDOWN = $20;
var
  hs: PKeyboardLowLevelHookStruct;
  // ctrlDown: boolean;
begin

  if nCode = HC_ACTION then
  begin

    hs := PKeyboardLowLevelHookStruct(lParam);
    // ctrlDown := GetAsyncKeyState(VK_CONTROL) and $8000 <> 0;
    if (hs^.vkCode = VK_tab) then
      Exit(1);
    // if (hs^.vkCode = VK_CONTROL) then
    // Exit(1);

  end;

  result := CallNextHookEx(0, nCode, wParam, lParam);

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Click then
  begin
    if (Edit1.Text = 'vugichugi') then
    begin

      Pass := True;
      EnableWindow(wndTaskbar, True);
      ShowWindow(wndTaskbar, SW_SHOW);
      Application.ProcessMessages;
      CameraComponent1.Active := false;
      Application.ProcessMessages;
      Form1.Close;
    end
    else
    begin
      i := i + 1;
      Application.ProcessMessages;
      Showmessage('Wrong Password. Please try again');
      CameraComponent1SampleBufferReady(Sender, MediaTimeScale);
      Image1.Bitmap.SaveToFile('Image' + inttostr(i) + '.jpg');
      Edit1.Visible := True;
      Label3.Visible := True;
      Application.ProcessMessages;
      CameraComponent1.Active := True;
      Application.ProcessMessages;
      Click := True;
    end;
  end
  else
  begin
    Edit1.Visible := True;
    Label3.Visible := True;
    Application.ProcessMessages;
    CameraComponent1.Active := True;
    Application.ProcessMessages;
    Click := True;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  // Edit1.Password := True;
  Form1.FormStyle := TFormStyle.StayOnTop;
  BorderStyle := TFmxFormBorderStyle.None;
  WindowState := TWindowstate.wsMaximized;
  wndTaskbar := FindWindow('Shell_TrayWnd', nil);
  if wndTaskbar <> 0 then
  begin
    EnableWindow(wndTaskbar, false);
    ShowWindow(wndTaskbar, SW_HIDE);
  end;
  Click := false;
  Pass := false;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
  begin
    Button1.OnClick(Sender);
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Form1.FormStyle := TFormStyle.StayOnTop;
  WindowState := TWindowstate.wsMaximized;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Edit1.Visible := false;
  Label3.Visible := false;
  SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc, 0, 0);
end;

procedure TForm1.CameraComponent1SampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Pass then
    CanClose := True
  else
    CanClose := false;
end;

end.
