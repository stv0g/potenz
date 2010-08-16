unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ShellApi;

type
  TForm3 = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    RichEdit1: TRichEdit;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
  end;

var
  Form3: TForm3;

implementation

uses Unit2;

{$R *.DFM}

procedure TForm3.Button2Click(Sender: TObject);
begin
     ShellExecute(Form2.Handle,'open','http://www.fsf.org/licensing/licenses/gpl.html',nil,nil,SW_SHOWNORMAL);
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
     Close
end;

end.
