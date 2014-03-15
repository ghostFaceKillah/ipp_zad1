// Zadanie zaliczeniowe nr 1 - Indywidualny Projekt Programistyczny MIM UW
// Michał Garmulewicz, 15.03.2014
// Reprezentacja dynamicznej funkcji na drzewach BST
// plik główny
program ipp_zad1;

uses drzewa;
  // a module for handling tree operations and tree memory of the func

const
  CHAR_OFFSET = 48; // for casting char to int
  MAX_INPUT_LINES = 1000000; // given in the task statement

procedure ignore();
  begin
    writeln('zignorowano');
  end;
  
function isDigit(const c : char) : boolean;
  // checks if ASCII char is digit
  begin
    if (ord(c)<48) or (ord(c)>57) then isDigit:=false else isDigit:=true;
  end;
  
function char_to_int(c : char) : LongInt;
  // casts char to int
  begin 
    char_to_int := ord(c) - CHAR_OFFSET;
  end;

function parseLongInt(const from, too : Integer; const inp : String) : LongInt;
  // parses non-negativeLongInt from a part of a string. If it cannot parse a 
  // valid string or the string has leading zeros, then it returns -1 
  var
    i : integer;
    resu : LongInt;
    keepGoing : boolean;
  begin
    resu := 0;
    i := from;
    keepGoing := true;
    while keepGoing and (i <= too) do begin
      if isDigit(inp[i]) then
        if (i-from > 0) and (resu = 0) then begin
          resu := -1;
          keepGoing := false;
        end else begin
          resu := resu*10 + char_to_int(inp[i]);
          inc(i);
        end
      else begin
        resu := -1;
        keepGoing := false;
      end;
    end;
    parseLongInt := resu;
  end;
  
procedure processPossibleFuncValue(const current_input : string);
  // checks for correct func val assignment call
  var
    eqPos : integer;
    x, y : LongInt;
  begin
    eqPos := 3;
    while (eqPos <= length(current_input)) and (current_input[eqPos] <> '=') do
      inc(eqPos);
    if (eqPos >= length(current_input)) or
       (current_input[eqPos-1] <> ':') or
       (current_input[eqPos-2] <> ')') then
      ignore()
    else begin
      x := parseLongInt(3, eqPos-3, current_input);
      y := parseLongInt(eqPos+1, length(current_input), current_input);
      if (x = -1) or (y = -1) or (y > 1000) or (x > 1000000000) then
        ignore()
      else begin
        writeln('wezlow: ', przypisanie(x,y));
      end;
    end;
  end;

procedure processPossibleSum(const current_input : string);
  // checks for a correct pattern suma(t,a..b) call
  var
    commaPos : integer;
    pointPos : integer;
    a, b, t : LongInt;
    s : LongInt;
  begin
    commaPos := 6;
    while (commaPos <= length(current_input)) and
    (current_input[commaPos] <> ',') do
      inc(commaPos);
    pointPos := commaPos+1;
    while (pointPos <= length(current_input)) and
    (current_input[pointPos] <> '.') do
      inc(pointPos);
    if (commaPos = 6) or // no t present
       (commaPos > length(current_input)) or
       (pointPos > length(current_input)) or
       (pointPos = commaPos + 1) or         // no a present
       (current_input[pointPos+1] <> '.') or
       (current_input[length(current_input)] <> ')') or
       (length(current_input) <= pointPos + 2) then // no b present
    ignore()
    else begin
      t := parseLongInt(6, commaPos-1, current_input);
      a := parseLongInt(commaPos+1, pointPos-1 , current_input);
      b := parseLongInt(pointPos+2, length(current_input)-1, current_input);
      if (t=-1) or (a=-1) or
         (b=-1) or not(treeExists(t)) or
         (a > 1000000000) or (b > 1000000000) then
        ignore()
      else begin
        s := suma(t,a,b);
        if s <> -1 then
          writeln('suma(', t, ',', a, '..', b, ')=', s);
      end
    end;
  end;
  
procedure processPossibleCleanse(const current_input : string);
  // checks for a valid 'czysc(t)' pattern call
  var
    t : LongInt;
  begin
    if length(current_input) <= 7 then
      ignore()
    else begin
      t := parseLongInt(7, length(current_input)-1, current_input);
      if (t= -1) or not(treeExists(t)) then
        ignore()
      else begin
        writeln('wezlow: ', czysc(t));
      end;
    end;
  end;

var
  current_input : string;
  input_count : LongInt;


begin
  inicjuj();
  input_count := 0;
  current_input := '0';
  while not(eof) do begin
    if input_count < MAX_INPUT_LINES then begin
      inc(input_count);
      readln(current_input);
      if copy(current_input, 1,2) = 'f(' then
        processPossibleFuncValue(current_input)
      else if copy(current_input, 1, 5) = 'suma(' then
        processPossibleSum(current_input)
      else if copy(current_input, 1, 6) = 'czysc(' then
        processPossibleCleanse(current_input)
      else
        ignore();
      // if you want to debug, then:
      // writeTrees();
    end else begin
      readln(current_input);
      ignore();
    end;
  end;
end.
