unit drzewa;

interface

const
  MAX_TREE_NUM = 1000000;

type
  tree = ^node;
  node = record
    x : LongInt;
    y : LongInt;
    ref_count : integer;
    left : tree;
    right : tree;
  end;

  the_trees = array[1..MAX_TREE_NUM] of tree;

  procedure inicjuj;
  function przypisanie(argument, wartosc : LongInt) : LongInt;
  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
  function czysc(nr_funkcji : LongInt) : LongInt;

  procedure insertNodeIntoTree(const toInsert : tree; var r : tree);
  function searchValueInTree(x : LongInt; t : tree) : tree;
  procedure writeTree(const t : tree; i : integer);

implementation
  var
    trees : the_trees;
  
  procedure inicjuj();
    var
      i : LongInt;
    begin
      for i := 1 to MAX_TREE_NUM do
        trees[i] := NIL;
    end;

  function searchValueInTree(x : LongInt; t : tree) : tree;
    var
      cont : boolean;
    begin
      cont := true;
      while cont do begin
        if t <> Nil then begin
	  if x = t^.x then
	    cont := false
	  else if x > t^.x then
	    t := t^.right
	  else
	    t := t^.left;
        end else begin
	  cont := false;
	end;
      end;
      searchValueInTree := t;
    end;

  procedure insertNodeIntoTree(const toInsert : tree; var r : tree);
    begin
      if r = Nil then
	r := toInsert
      else 
	if r^.x < toInsert^.x then
	  if r^.right <> Nil then
	    insertNodeIntoTree(toInsert, r^.right)
	  else
	    r^.right := toInsert
	else
	  if r^.left <> Nil then
	    insertNodeIntoTree(toInsert, r^.left)
	  else
	    r^.left := toInsert;
    end;

  procedure processValueIntoTree(x,y : LongInt; var r : tree);
    var
      toInsert : tree;
      search : tree;
    begin
      search := searchValueInTree(x, r);
      if search = Nil then begin
        new(toInsert);
	toInsert^.x := x;
	toInsert^.y := y;
	toInsert^.ref_count := 1;
	toInsert^.left := Nil;
	toInsert^.right := Nil;
	insertNodeIntoTree(toInsert, r)
      end else
	search^.y := y;
    end;

  procedure writeTree(const t : tree; i : integer);
    var
      j : integer;
    begin
      if t <> Nil then begin
        for j := 0 to i do
	  write('   ');
	writeln('node x = ', t^.x, ' y = ', t^.y);
        writeTree(t^.left, i+1);
        writeTree(t^.right, i+1);
      end;
    end;

  function przypisanie(argument, wartosc : LongInt) : LongInt;
    begin end;
  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
    begin end;
  function czysc(nr_funkcji : LongInt) : LongInt;
    begin end;

end.
