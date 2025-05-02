unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, httpsend, ssl_openssl, fpjson, jsonparser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
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

function ClearCNPJ(const CNPJ: string): string;
begin
  Result := trim(CNPJ);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
  CNPJ, URL, Response: string;
  HTTP: THTTPSend;
  ResponseStream: TStringStream;
  JSON: TJSONdata;
begin
  JSON := nil;
  ResponseStream := nil;
  HTTP := nil;

  try
    CNPJ := ClearCNPJ(txtCNPJ.Text);
    if (CNPJ = '') or (Length(CNPJ) <> 14) then
      begin
        showMessage('Por favor, informe um CNPJ válido');
        exit;
      end;

    URL := 'https://receitaws.com.br/v1/cnpj/' + CNPJ;

    HTTP := THTTPSend.Create;
    ResponseStream := TStringStream.Create('', TEncoding.UTF8);

    Memo.Lines.Clear;

    try
      if HTTP.HTTPMethod('GET', URL) then
      begin
        ResponseStream.LoadFromStream(HTTP.Document);
        Response := ResponseStream.DataString;

        JSON := GetJSON(Response);

        memo.Lines.Add('Razao Social: ' + JSON.FindPath('nome').AsString);
        memo.Lines.Add('Nome Fantasia: ' + JSON.FindPath('fantasia').AsString);
        memo.Lines.Add('CNPJ: ' + JSON.FindPath('cnpj').AsString);
        memo.Lines.Add('Inscricao Estadual: ' + GetSafeJSONValue(JSON, 'ie', 'n/a'));
        memo.Lines.Add('Endereco: ' + JSON.FindPath('logradouro').AsString +
          ', ' + JSON.FindPath('numero').AsString +
          ' - ' + JSON.FindPath('bairro').AsString);
        memo.Lines.Add('Cidade/UF: ' + Json.FindPath('municipio').AsString +
          '/' + Json.FindPath('uf').AsString);
      end
      else
        ShowMessage('Erro ao conectar na API' + LineEnding + 'Código de resposta HTTP: ' + IntToStr(HTTP.ResultCode));
    except
      on e: Exception do
        ShowMessage('Erro' + e.Message);
    end;
  finally
    if Assigned(JSON) then JSON.Free;
    if Assigned(ResponseStream) then ResponseStream.Free;
    if Assigned(HTTP) then HTTP.Free;
  end;
end;

end.
