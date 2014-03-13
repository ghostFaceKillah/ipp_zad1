// Zadanie zaliczeniowe - Indywidualny Projekt Programistyczny MIM UW
// Michał Garmulewicz
// Reprezentacja dynamicznej funkcji na drzewach BST
// początek programu	ogólny opis programu: autor, data powstania, co program robi, jak go uruchamiać
// typ definiowany przez użytkownika	do czego służy, co oznaczają poszczególne składowe
// procedura lub funkcja	co robi, jak szybko to robi, informacje nt. przekazywanych argumentów, wymagane warunki wstępne, zapewniane warunki końcowe
// dowolny niebanalny kawałek kodu	jak działa i dlaczego jest zapisany akurat w ten sposób
program ipp_zad1;

uses drzewa;

const
  CHAR_OFFSET = 48; // for casting char to int

procedure ignore();
  begin
    writeln('Zignorowano');
  end;

function isDigit(const c : char) : boolean;
  begin
    if (ord(c)<48) or (ord(c)>57) then isDigit:=false else isDigit:=true;
  end;

function char_to_int(c : char) : LongInt;
  begin 
    char_to_int := ord(c) - CHAR_OFFSET;
  end;

function parseLongInt(const from, too : Integer; const inp : String) : LongInt;
  // funkcja operuje na części stringa i zwraca LongInt, gdy ten fragment
  // to nieujemna liczba całkowita, a -1 w przeciwnym wypadku
  var
    i : integer;
    resu : LongInt;
    keepGoing : boolean;
  begin
    resu := 0;
    i := from;
    keepGoing := true;
    while keepGoing and (i <= too) do begin
      if isDigit(inp[i]) then begin
        resu := resu*10 + char_to_int(inp[i]);
	inc(i);
      end else begin
	resu := -1;
	keepGoing := false;
      end;
    end;
    parseLongInt := resu;
  end;

procedure processPossibleFuncValue(const current_input : string);
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
      if (x = -1) or (y = -1) then
	ignore()
      else
	writeln('Got a valid func assignment: f(',x,'):=', y);
    end;
  end;

procedure processPossibleSum(const current_input : string);
  // checking for pattern suma(t,a..b)
  var
    commaPos : integer;
    pointPos : integer;
    a, b, t : LongInt;
  begin
    writeln('Maybe its a sum..');
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
      // parse int needed ??
      t := parseLongInt(6, commaPos-1, current_input);
      a := parseLongInt(commaPos+1, pointPos-1 , current_input);
      b := parseLongInt(pointPos+2, length(current_input)-1, current_input);
      if (t=-1) or (a=-1) or (b=-1) then
	ignore()
      else
        writeln('Got a valid sum assignment: suma(',t,',',a,'..',b,')');
    end;
  end;

procedure processPossibleCleanse(const current_input : string);
  var
    t : LongInt;
  begin
    if length(current_input) <= 7 then
      ignore()
    else begin
      t := parseLongInt(7, length(current_input)-1, current_input);
      if t= -1 then
	ignore()
      else
	writeln('Got a valid cleanse assignent: czysc(',t,')');
    end;
  end;

procedure debug();
  begin
    writeln('do heaps and heaps of debugging code');
  end;


var
  current_input : string;

  i : integer;
  j : LongInt;
  t, curr : tree;


begin
  t := Nil;
  while (true) do begin
    readln(j);
    new(curr);
    curr^.left := Nil;
    curr^.right := Nil;
    curr^.x := j;
    curr^.y := j;
    curr^.ref_count := 1;
    insertNodeIntoTree(curr, t);
    writeTree(t, 0);
  end;

  
  // current_input := '0';
  // while current_input <> '' do begin
  //   readln(current_input);
  //   if copy(current_input, 1,2) = 'f(' then
  //     processPossibleFuncValue(current_input)
  //   else if copy(current_input, 1, 5) = 'suma(' then
  //     processPossibleSum(current_input)
  //   else if copy(current_input, 1, 6) = 'czysc(' then
  //     processPossibleCleanse(current_input)
  //   else if copy(current_input, 1, 5) = 'debug' then
  //     debug()
  //   else if current_input <> '' then
  //     ignore();
  // end;
end.
