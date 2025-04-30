unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, httpsend, ssl_openssl, fpjson, jsonparser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    lbTitle: TLabel;
    lbCNPJ: TLabel;
    txtCNPJ: TEdit;
    btnSearch: TButton;
    memo: TMemo;
    procedure btnSearchClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

function GetSafeJSONValue(JSON: TJSONData; const Path, Default: string): string;
var
  Node: TJSONData;
begin
  Node := JSON.FindPath(Path);
  if Assigned(Node) then
    Result := Node.AsString
  else
    Result := Default;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
  CNPJ, URL, Response : String;
  HTTP : THTTPSend;
  ResponseStream : TStringStream;
  JSON : TJSONdata;

begin
  try
    CNPJ := txtCNPJ.Text;
    URL := 'https://receitaws.com.br/v1/cnpj/' + CNPJ;
    JSON := nil;

    Memo.Lines.Clear;

    HTTP := THTTPSend.Create;
    ResponseStream := TStringStream.Create('');

    try
      if HTTP.HTTPMethod('GET', URL) then
        begin
          ResponseStream.LoadFromStream(HTTP.Document);
          Response := ResponseStream.DataString;

          JSON := GetJSON(Response);

          memo.Lines.Add('Razão Social: ' + JSON.FindPath('nome').AsString);
          memo.Lines.Add('Nome Fantasia: ' +  JSON.FindPath('fantasia').AsString);
          memo.Lines.Add('CNPJ: ' + JSON.FindPath('cnpj').AsString);
          memo.Lines.Add('Inscrição Estadual: ' + GetSafeJSONValue(JSON, 'ie', '[N/A]'));
          memo.Lines.Add('Endereço: ' + JSON.FindPath('logradouro').AsString + ', '
                        + JSON.FindPath('numero').AsString + ' - '
                        + JSON.FindPath('bairro').AsString + ' - '
                        + JSON.FindPath('municipio').AsString + ' - '
                        + JSON.FindPath('uf').AsString);
        end
      else
        ShowMessage('Erro ao conectar na API');
    except
      on e: Exception do
        ShowMessage('Erro' + e.Message);
    end;
  finally
    JSON.Free;
    ResponseStream.Free;
    HTTP.Free;
  end;
end;
end.
