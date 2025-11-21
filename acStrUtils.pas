unit acStrUtils;

interface


uses
  classes, StrUtils, SysUtils, Vcl.ComCTrls;

Type
  TInfoPalavra = class
    public
      frequencia: integer;
  end;

function getStrField(str: string; delimiter: char; index: integer): string;
function getStrField2(str: string; delimiter: char; index: integer): string;
function getintField2(str: string; delimiter: char; index: integer): integer;
function getfloatField2(str: string; delimiter: char; index: integer): integer;
function retiraEspacosDuplicados(str: String): String;
function removeEspacos(str: String): String;
function tiraPontos(str: String): String;
function removeAcento(str: String): String;
function RemoveSimbolo(str: String): String;
function extraiPalavras(texto: string): TStringList;
function achaPalavra(texto, palavra: string): integer;
procedure RTFsubstText(rtf: TRichEdit; fromText, toText: string);
//procedure wwRTFsubstText(rtf: TwwDBRichEdit; fromText, toText: string);
function strip(value: string; delimiter: string = ' '): TStringList;
function numeroIncluidoNaRegra(numero: integer; regra: string): boolean;
function strVezes(str: string; vezes: integer): string;
procedure stringListSubstText(strl: TStringList; fromText, toText: string);
function simpleCrypt(str: string): string;
function simpleDecrypt(str: string): string;
function rToTxtField(value: string; size: integer): string;
function toTxtField(value: string; size: integer): string; overload;
function toTxtField(value: integer; size: integer): string; overload;
function currencyToTxtField(value: double; size: integer): string;
function encodeFileToUTF8(fileName: string): string;
function substituiCaracterInvalido(texto: string; strConst: char = '_'): string;
function prepareIdsForIn(strIds: string): TStringList;
function EnsureTrailingSlash(const path: string): string;
function dasherize(const str: string): string;
function underscorize(const str: string): string;
procedure writeTextFile(fileName, text: string);
function readTextFile(fileName: string): string;
function fillSpaces(str: string; size: integer): string;
function parseRailsDate(str: string): TDateTime;
function Mod10(Num : String) : Integer;
function valorPorExtenso(vlr: real): string;
function EscapeTextToJSON(const aValue: string): string;

implementation

function strVezes(str: string; vezes: integer): string;
var
  i: integer;
begin
  result := '';
  for i := 1 to vezes do
  begin
    result := result + str;
  end;
end;

function getStrField(str: string; delimiter: char; index: integer): string;
var
  strL: TStringList;
begin
  strL := TStringList.Create;
  try
    str := AnsiReplaceStr(str, ';', '"|"');
    str := '"' + AnsiReplaceStr(str, '|', '"|"') + '"';
    strL.Delimiter := delimiter;
    strL.DelimitedText := str;
    if index>strL.Count then
      result := ''
    else
      result := strL[index-1];
  finally
    FreeAndNil(strL);
  end;
end;

function getIntField2(str: string; delimiter: char; index: integer): integer;
var
  strValue: string;
begin
  strValue := getStrfield2(str, delimiter, index);
  if Trim(strValue) = '' then
    result := 0
  else
    try
      result := strToInt(strValue);
    except
      result := 0;
    end;
end;

function getFloatField2(str: string; delimiter: char; index: integer): integer;
var
  strValue: string;
  fl: double;
  fs: TFormatSettings;
begin
  strValue := getStrfield2(str, delimiter, index);
  try
    fs.DecimalSeparator := '.';
    fl := StrToFloat(strValue, fs);
    result := Trunc(fl);
  except
    result := 0;
  end;
end;

function getStrField2(str: string; delimiter: char; index: integer): string;
var
  ultimoIndice: integer;
  strl: array of string;
  arrLength: integer;
begin
  arrLength := 0;
  ultimoIndice := pos(delimiter, str);
  while (ultimoIndice > 0) do
  begin
    inc(arrLength);
    SetLength(strl, arrLength);
    strl[arrLength-1] := copy(str, 0, ultimoIndice-1);
    str := copy(str, ultimoIndice+1, length(str));
    ultimoIndice := pos(delimiter, str);
    if (ultimoIndice = 0) and (str <> '') then
    begin
      inc(arrLength);
      SetLength(strl, arrLength);
      strl[arrLength-1] := str;
    end;
  end;

  if (index > 0) and (index <= arrLength) then
    result := strl[index-1]
  else
    result := '';
end;


function tiraPontos(str: String): String;
var
  i: integer;
begin
  result := '';
  for i := 1 to length(str) do
    if (str[i]<>'.') then
      result := result + str[i];
end;


function removeEspacos(str: String): String;
var
  i: integer;
begin
  result := '';
  for i := 1 to length(str) do
  begin
    if (str[i]<>' ') and (str[i]<> #13) and (str[i]<> #10) then
      result := result + str[i];
  end;
end;

function retiraEspacosDuplicados(str: string): String;
var
  i: integer;
  adicionouEspaco: boolean;
begin
  result := '';
  adicionouEspaco := false;
  for i := 1 to length(str) do
  begin
    if (str[i]<>' ') and (str[i]<> #13) and (str[i]<> #10) then
    begin
      result := result + str[i];
      adicionouEspaco := False;
    end
    else
    begin
      if not adicionouEspaco then
      begin
        adicionouEspaco := true;
        result := result + ' ';
      end;
    end;
  end;
end;

function RemoveAcento(Str:String): String;
Const
  ComAcento = '‡‚ÍÙ˚„ı·ÈÌÛ˙Á¸‰¿¬ ‘€√’¡…Õ”⁄«‹ƒ';
  SemAcento = 'aaeouaoaeioucuaAAEOUAOAEIOUCUA';
Var
  x : Integer;
Begin
  For x := 1 to Length(Str) do
    if Pos(Str[x],ComAcento)<>0 Then
      Str[x] := SemAcento[Pos(Str[x],ComAcento)];
  Result := Str;
end;

function RemoveSimbolo(str: string): String;
const
  simbolo = '''"!@#$%.®&*()_-+=ß¨π¥`~^;:/\|<>][{}?!';
var
  i: integer;
begin
  result := '';
  for i:= 1 to length(str) do
  begin
     if Pos(str[i],simbolo)=0 Then
      result := result + str[i];
     if Pos(str[i],simbolo)<>0 Then
       result := result + '';
  end;
end;

function achaPalavra(texto, palavra: string): integer;
begin
  result := pos(palavra, texto);
end;

function extraiPalavras(texto: string): TStringList;
var
  strL: TStringList;
  i, posicao: integer;
  palavra: string;
  info: TInfoPalavra;
begin
  palavra := '';
  strL := TStringList.Create;
  for i := 1 to length(texto) do
  begin
    //se È uma palavra nova e n„o foi inserida
    if texto[i]=' ' then
    begin
      posicao := strL.add(palavra);
      info := TInfoPalavra.Create;
      info.frequencia := 1;
      strL.Objects[posicao] := info;
      palavra := '';
    end
    else
      palavra := palavra+texto[i];
   end;
  //se sobrou uma ultima palavra adiciona
  if palavra <> '' then
    strL.add(palavra);
  result := strL;
end;

procedure RTFsubstText(rtf: TRichEdit; fromText, toText: string);
var
  index: integer;
begin
  index := rtf.FindText(fromText, 0, length(rtf.Lines.GetText), []);
  while index<>-1 do
  begin
    rtf.SelStart := index;
    rtf.SelLength := length(fromText);
    rtf.SelText := toText;

    index := rtf.FindText(fromText, index+1, length(rtf.Lines.GetText), []);
  end;
end;

{procedure wwRTFsubstText(rtf: TwwDBRichEdit; fromText, toText: string);
var
  index: integer;
begin
  index := rtf.FindText(fromText, 0, length(rtf.Lines.GetText), []);
  while index<>-1 do
  begin
    rtf.SelStart := index;
    rtf.SelLength := length(fromText);
    rtf.SelText := toText;

    index := rtf.FindText(fromText, index+1, length(rtf.Lines.GetText), []);
  end;
end;}

procedure stringListSubstText(strl: TStringList; fromText, toText: string);
begin
//  strl.Text := FastReplace(strl.Text, fromText, toText);
end;

function strip(value: string; delimiter: string = ' '): TStringList;
var
  tmpStrList: TStringList;
begin
  value := '"' + AnsiReplaceStr(value, delimiter, '"' + delimiter + '"') + '"';
  tmpStrList := TStringList.Create;
  tmpStrList.Delimiter := delimiter[1];
  tmpStrList.DelimitedText := value;
  result := tmpStrList;
end;

function numeroIncluidoNaRegra(numero: integer; regra: string): boolean;
var
  faixas, intervalos: TStringList;
  j: integer;
  baseFaixa, topoFaixa: integer;
begin
  result := false;
  faixas := strip(regra, ',');
  try
    for j := 0 to faixas.Count - 1 do
    begin
      if Pos('-', faixas[j]) <> 0 then
      begin
        intervalos := strip(faixas[j], '-');
        try
          baseFaixa := StrToInt(intervalos[0]);
          topoFaixa := StrToInt(intervalos[1]);
          if ((numero >= baseFaixa) or (numero <= topoFaixa)) then
            result := true;
        finally
          intervalos.Free;
        end;
      end
      else
      begin
        baseFaixa := strToInt(faixas[j]);
        if numero = baseFaixa then
          result := true;
      end;
    end;
  finally
    Faixas.Free;
  end;
end;

//simpleCrypt e deCrypt sÛ devem ser chamados para strings
//simples e pequenas e È uma criptografia extremamente fraca
//apenas para proteger informaÁıes n„o muito sensÌveis e de usu·rios leigos
function simpleCrypt(str: string): string;
var
  i: integer;
begin
  result := '';
  for i := 1 to length(str) do
    result := result + FormatFloat('0000', ord(str[i]) + i);
end;

function simpleDecrypt(str: string): string;
var
  i, num, posInicial: integer;
begin
  result := '';
  for i := 1 to (length(str) div 4) do
  begin
    posInicial := (i-1)*4+1;
    num := strToInt(copy(str, posInicial, 4));
    num := num - i;
    result := result + char(num);
  end;
end;

function toTxtField(value: string; size: integer): string;
var
  tam: integer;
begin
  tam := length(value);
  if tam < size then
    result := strVezes(' ', size - tam) + value;
  if tam >= size then
    result := copy(value, 1, size);
end;

function rToTxtField(value: string; size: integer): string;
var
  tam: integer;
begin
  tam := length(value);
  if tam < size then
    result := value + strVezes(' ', size - tam);
  if tam >= size then
    result := copy(value, 1, size);
end;

function toTxtField(value: integer; size: integer): string;
begin
  result := FormatFloat(strVezes('0', size), value);
end;

function currencyToTxtField(value: double; size: integer): string;
begin
  result := FormatFloat(strVezes('0', size), value*100);
end;

function encodeFileToUTF8(fileName: string): string;
var
  fc: TStringList;
begin
  try
    fc := TstringList.Create;
    fc.LoadFromFile(fileName);
    {$WARNINGS OFF}
    fc.Text := UTF8Encode(fc.Text);
    {$WARNINGS ON}
    fc.SaveToFile(fileName);
    result := fileName;
  finally
    FreeAndNil(fc);
  end;
end;

function substituiCaracterInvalido(texto: string; strConst: Char = '_'): string;
const
  CaracteresInvalidos = ' \ / : * ? " < > | #';
var
  i: Integer;
  str: string;
begin
  for i:=1 to Length(texto) do
  begin
    if Pos(texto[i], CaracteresInvalidos) > 0 then
      str := str + strConst
    else
      str := str + texto[i];
  end;
  Result := str;
end;

function prepareIdsForIn(strIds: string): TStringList;
var
  IDsStringList: TStringList;
  listaIds: string;
  contador: Integer;
begin
  try
    listaIds := '-1';
    IDsStringList := TStringList.Create;
    IDsStringList.Duplicates := dupIgnore;
    IDsStringList.Sorted := True;
    ExtractStrings([','], [' '], PChar(strIds), IDsStringList);

    Result := TStringList.Create;
    for contador := 1 to (IDsStringList.Count) do
    begin
      listaIds := listaIds + ',' + IDsStringList.Strings[contador - 1];
      if ((contador mod 1495) = 0) or (contador = IDsStringList.Count) then
      begin
        Result.Add(listaIds);
        listaIds := '-1';
      end;
    end;
  finally
    FreeAndNil(IDsStringList);
  end;
end;

function EnsureTrailingSlash(const path: string): string;
begin
  result := path;
  if result[Length(result)] <> '/' then
    result := result + '/';
end;

function dasherize(const str: string): string;
begin
  {$IFDEF VER150}
    result := FastReplace(str, '_', '-');
  {$ELSE}
    result := ReplaceStr(str, '_', '-');
  {$ENDIF}
end;

function underscorize(const str: string): string;
begin
  {$IFDEF VER150}
    result := FastReplace(str, '-', '_');
  {$ELSE}
    result := ReplaceStr(str, '-', '_');
  {$ENDIF}
end;

procedure writeTextFile(fileName, text: string);
var
  tf: TextFile;
begin
  AssignFile(tf, fileName);
  Rewrite(tf);
  Writeln(tf, text);
  CloseFile(tf);
end;

function readTextFile(fileName: string): string;
var
  tf: TextFile;
  text: string;
begin
  if FileExists(fileName) then
  begin
    AssignFile(tf, fileName);
    Reset(tf);
    Readln(tf, text);
    CloseFile(tf);
    Result := text;
  end;
end;

function fillSpaces(str: string; size: integer): string;
var
  i, l: integer;
begin
  result := str;
  l := length(str);
  for i := 1 to size-l do
    result := ' ' + result;
end;

function parseRailsDate(str: string): TDateTime;
var
  year, month, day, hour, minute, second: word;
begin
  year := StrToInt(copy(str, 1, 4));
  month := StrToInt(copy(str, 6, 2));
  day := StrToInt(copy(str, 9, 2));
  hour := StrToInt(copy(str, 12, 2));
  minute := StrToInt(copy(str, 15, 2));
  second := StrToInt(copy(str, 18, 2));
  result := EncodeDate(year, month, day) + EncodeTime(hour, minute, second, 0);
end;

function Mod10(Num : String) : Integer;
var
  tamanho, soma : Integer;
  resultado : Array [1..100] of Integer;
  fator, resto, i: Byte;
begin
  Tamanho := Length(Num);
  Fator := 2;
  for i := Tamanho Downto 1 Do
  begin
    resultado[I] := StrToInt(Copy(Num,I,1)) * Fator;
    if Fator = 2 then
      fator := 1
    else
      fator := 2;
  end;
  soma := 0;
  for i := 1 To tamanho do
    if Resultado[I] > 9 then
      soma := soma + StrToInt(Copy(IntToStr(Resultado[I]),1,1)) + StrToInt(Copy(IntToStr(Resultado[I]),2,1))
    else
      soma := soma + resultado[I];
  resto := Soma mod 10;
  if resto = 0 Then
    Mod10 := 0
  else
    Mod10 := 10 - Resto;
end;

function valorPorExtenso(vlr: real): string;
const
  unidade: array[1..19] of string = ('um', 'dois', 'trÍs', 'quatro', 'cinco',
             'seis', 'sete', 'oito', 'nove', 'dez', 'onze',
             'doze', 'treze', 'quatorze', 'quinze', 'dezesseis',
             'dezessete', 'dezoito', 'dezenove');
  centena: array[1..9] of string = ('cento', 'duzentos', 'trezentos',
             'quatrocentos', 'quinhentos', 'seiscentos',
             'setecentos', 'oitocentos', 'novecentos');
  dezena: array[2..9] of string = ('vinte', 'trinta', 'quarenta', 'cinquenta',
             'sessenta', 'setenta', 'oitenta', 'noventa');
  qualificaS: array[0..4] of string = ('', 'mil', 'milh„o', 'bilh„o', 'trilh„o');
  qualificaP: array[0..4] of string = ('', 'mil', 'milhıes', 'bilhıes', 'trilhıes');
var
                        inteiro: Int64;
                          resto: real;
  vlrS, s, saux, vlrP, centavos: string;
     n, unid, dez, cent, tam, i: integer;
                    umReal, tem: boolean;
begin
  if (vlr = 0)
     then begin
            valorPorExtenso := 'zero';
            exit;
          end;

  inteiro := trunc(vlr); // parte inteira do valor
  resto := vlr - inteiro; // parte fracion·ria do valor
  vlrS := inttostr(inteiro);
  if (length(vlrS) > 15)
     then begin
            valorPorExtenso := 'Erro: valor superior a 999 trilhıes.';
            exit;
          end;

  s := '';
  centavos := inttostr(round(resto * 100));

// definindo o extenso da parte inteira do valor
  i := 0;
  umReal := false; tem := false;
  while (vlrS <> '0') do
  begin
    tam := length(vlrS);
// retira do valor a 1a. parte, 2a. parte, por exemplo, para 123456789:
// 1a. parte = 789 (centena)
// 2a. parte = 456 (mil)
// 3a. parte = 123 (milhıes)
    if (tam > 3)
       then begin
              vlrP := copy(vlrS, tam-2, tam);
              vlrS := copy(vlrS, 1, tam-3);
            end
    else begin // ˙ltima parte do valor
           vlrP := vlrS;
           vlrS := '0';
         end;
    if (vlrP <> '000')
       then begin
              saux := '';
              if (vlrP = '100')
                 then saux := 'cem'
              else begin
                     n := strtoint(vlrP);        // para n = 371, tem-se:
                     cent := n div 100;          // cent = 3 (centena trezentos)
                     dez := (n mod 100) div 10;  // dez  = 7 (dezena setenta)
                     unid := (n mod 100) mod 10; // unid = 1 (unidade um)
                     if (cent <> 0)
                        then saux := centena[cent];
                     if ((dez <> 0) or (unid <> 0))
                        then begin
                               if ((n mod 100) <= 19)
                                  then begin
                                         if (length(saux) <> 0)
                                            then saux := saux + ' e ' + unidade[n mod 100]
                                         else saux := unidade[n mod 100];
                                       end
                               else begin
                                      if (length(saux) <> 0)
                                         then saux := saux + ' e ' + dezena[dez]
                                      else saux := dezena[dez];
                                      if (unid <> 0)
                                         then if (length(saux) <> 0)
                                                 then saux := saux + ' e ' + unidade[unid]
                                              else saux := unidade[unid];
                                    end;
                             end;
                   end;
              if ((vlrP = '1') or (vlrP = '001'))
                 then begin
                        if (i = 0) // 1a. parte do valor (um real)
                           then umReal := true
                        else saux := saux + ' ' + qualificaS[i];
                      end
              else if (i <> 0)
                      then saux := saux + ' ' + qualificaP[i];
              if (length(s) <> 0)
                 then s := saux + ', ' + s
              else s := saux;
            end;
    if (((i = 0) or (i = 1)) and (length(s) <> 0))
       then tem := true; // tem centena ou mil no valor
    i := i + 1; // prÛximo qualificador: 1- mil, 2- milh„o, 3- bilh„o, ...
  end;

  if (length(s) <> 0)
     then begin
            if (umReal)
               then s := s + ' real'
            else if (tem)
                    then s := s + ' reais'
                 else s := s + ' de reais';
          end;
// definindo o extenso dos centavos do valor
  if (centavos <> '0') // valor com centavos
     then begin
            if (length(s) <> 0) // se n„o È valor somente com centavos
               then s := s + ' e ';
            if (centavos = '1')
               then s := s + 'um centavo'
            else begin
                   n := strtoint(centavos);
                   if (n <= 19)
                      then s := s + unidade[n]
                   else begin                 // para n = 37, tem-se:
                          unid := n mod 10;   // unid = 37 % 10 = 7 (unidade sete)
                          dez := n div 10;    // dez  = 37 / 10 = 3 (dezena trinta)
                          s := s + dezena[dez];
                          if (unid <> 0)
                             then s := s + ' e ' + unidade[unid];
                       end;
                   s := s + ' centavos';
                 end;
          end;
  valorPorExtenso := s;
end;

function EscapeTextToJSON(const aValue: string): string;
begin
  Result := aValue;
  Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '\n', [rfReplaceAll]);
  if Pos('\rtf1\', Result) <= 0 then   //o TAB no RTF nao deve ser alterado
    Result := StringReplace(Result, #9, '\t', [rfReplaceAll]);
end;

end.


