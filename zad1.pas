// Zadanie zaliczeniowe nr 1 - Indywidualny Projekt Programistyczny MIM UW
// Michał Garmulewicz, 15.03.2014
// Reprezentacja dynamicznej funkcji na drzewach BST
// plik główny
program ipp_zad1;

uses drzewa;

const
  MAX_INPUT_LINES = 1000000;
  // REWRITE - MAX VALID STATEMENTS 
  MAX_X_VAL = 1000000000;
  MAX_Y_VAL = 1000;


// HELPER FUNCTIONS //

procedure ignore();
  begin
    writeln('zignorowano');
  end;
  
function isDigit(const c : Char) : Boolean;
  // checks if ASCII Char is digit
  begin
    if (c < '0') or (c > '9') then
      isDigit:=false
    else
      isDigit:=true;
  end;
  
function charToInt(c : Char) : LongInt;
  // casts Char to Int
  begin 
    charToInt := ord(c) - ord('0');
  end;

function parseLongInt(const from, too : Integer; const inp : String) : LongInt;
  // parses non-negativeLongInt from a part of a String. If it cannot parse a 
  // valid String or the String has leading zeros, then it returns - 1 
  var
    i : Integer;
    resu : LongInt;
    keep_going : Boolean;
  begin
    resu := 0;
    i := from;
    keep_going := true;
    while keep_going and (i <= too) do begin
      if isDigit(inp[i]) then
        if (i - from > 0) and (resu = 0) then begin
          resu := -1;
          keep_going := false;
        end else begin
          resu := resu*10 + charToInt(inp[i]);
          inc(i);
        end
      else begin
        resu := -1;
        keep_going := false;
      end;
    end;
    parseLongInt := resu;
  end;



// INPUT PROCESSORS //
  
procedure processPossibleFuncValue(const input_line : String);
  // checks for correct func val assignment call
  var
    eq_pos : Integer;
    x, y : LongInt;
  begin
    eq_pos := 3;
    while (eq_pos <= length(input_line)) and (input_line[eq_pos] <> '=') do
      inc(eq_pos);
    if (eq_pos >= length(input_line)) or
       (input_line[eq_pos - 1] <> ':') or
       (input_line[eq_pos - 2] <> ')') then
      ignore()
    else begin
      x := parseLongInt(3, eq_pos - 3, input_line);
      y := parseLongInt(eq_pos+1, length(input_line), input_line);
      if (x = -1) or (y = -1) or (y > MAX_Y_VAL) or (x > MAX_X_VAL) then
        ignore()
      else begin
        writeln('wezlow: ', przypisanie(x, y));
      end;
    end;
  end;

procedure processPossibleSum(const input_line : String);
  // checks for a correct pattern suma(t,a..b) call
  var
    comma_pos : Integer;
    point_pos : Integer;
    a, b, t : LongInt;
    s : LongInt;
  begin
    comma_pos := 6;
    while (comma_pos <= length(input_line)) and
          (input_line[comma_pos] <> ',') do
      inc(comma_pos);
    point_pos := comma_pos+1;
    while (point_pos <= length(input_line)) and
          (input_line[point_pos] <> '.') do
      inc(point_pos);
    if (comma_pos = 6) or // no t present
       (comma_pos > length(input_line)) or
       (point_pos > length(input_line)) or
       (point_pos = comma_pos + 1) or         // no a present
       (input_line[point_pos + 1] <> '.') or
       (input_line[length(input_line)] <> ')') or
       (length(input_line) <= point_pos + 2) then // no b present
      ignore()
    else begin
      t := parseLongInt(6, comma_pos - 1, input_line);
      a := parseLongInt(comma_pos + 1, point_pos - 1 , input_line);
      b := parseLongInt(point_pos + 2, length(input_line) - 1, input_line);
      if (t = -1) or (a = -1) or
         (b = -1) or not(treeExists(t)) or
         (a > 1000000000) or (b > 1000000000) then
        ignore()
      else begin
        s := suma(t, a, b);
        if s <> -1 then
          writeln('suma(', t, ',', a, '..', b, ')=', s);
      end
    end;
  end;
  
procedure processPossibleCleanse(const input_line : String);
  // checks for a valid 'czysc(t)' pattern call
  var
    t : LongInt;
  begin
    if length(input_line) <= 7 then
      ignore()
    else begin
      t := parseLongInt(7, length(input_line) - 1, input_line);
      if (t= -1) or not(treeExists(t)) then
        ignore()
      else begin
        writeln('wezlow: ', czysc(t));
      end;
    end;
  end;


// MAIN LOOP // 

var
  input_line : String;
  valid_input_count : LongInt;

begin
  inicjuj();
  valid_input_count := 0;
  input_line := '0';
  while not(eof) do begin
    readln(input_line);
    if valid_input_count < MAX_INPUT_LINES then begin
      inc(valid_input_count);
      if copy(input_line, 1, 2) = 'f(' then
        processPossibleFuncValue(input_line)
      else if copy(input_line, 1, 5) = 'suma(' then
        processPossibleSum(input_line)
      else if copy(input_line, 1, 6) = 'czysc(' then
        processPossibleCleanse(input_line)
      else
        ignore();
    end else begin
      ignore();
    end;
  end;
  finalCleanup();
end.
