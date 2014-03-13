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
  function przypisanie(x, y : LongInt) : LongInt;
  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
  function czysc(nr_funkcji : LongInt) : LongInt;

  procedure writeTree(const t : tree; i : integer);
  procedure writeTrees();

implementation

  type
    linkage = (left, right, both);

  var
    trees : the_trees;
    counter : LongInt;
    vec_pos : integer;
  
  procedure inicjuj();
    var
      i : LongInt;
    begin
      counter := 0;
      vec_pos := 0;
      for i := 1 to MAX_TREE_NUM do
        trees[i] := NIL;
    end;

  function wrap(const x, y : LongInt) : tree;
    var
      resu : tree;
    begin
      new(resu);
      inc(counter);
      resu^.x := x;
      resu^.y := y;
      resu^.ref_count := 1;
      resu^.left := Nil;
      resu^.right := Nil;
      wrap := resu;
    end;

  function copyTree(const t : tree) : tree;
    var
      resu : tree;
    begin
      new(resu);
      inc(counter);
      resu^.x := t^.x;
      resu^.y := t^.y;
      resu^.ref_count := 1;
      resu^.right := nil;
      resu^.left := nil;
      copyTree := resu;
    end;

  procedure link(var previous : tree; var current : tree; const dir : linkage);
    begin
      if (previous = NIL) or (current = NIL) then
        writeln('ERROR LINKING');
      if dir = both then begin
        current^.right := previous^.right;
        current^.left := previous^.left;
        if previous^.left <> Nil then
	  inc(previous^.left^.ref_count);
        if previous^.right <> Nil then
	  inc(previous^.right^.ref_count);
      end else if dir = left then begin
        current^.left := previous^.left;
        if previous^.left <> Nil then
	  inc(previous^.left^.ref_count);
      end else begin
        current^.right := previous^.right;
        if previous^.right <> Nil then
	  inc(previous^.right^.ref_count);
      end;
    end;

  function findSmallestNode(const t : tree ) : tree;
    var
      temp : tree;
    begin 
      temp := t;
      while temp^.left <> Nil do
        temp := temp^.left;
	findSmallestNode := temp;
    end;

  function przypisanie(x, y : LongInt) : LongInt;

    function treeChanges(const t : tree):boolean;
      begin
	if t = nil then
	  treeChanges := true
	else if (t^.x = x) and (t^.y = y) then
	  treeChanges := false
	else if (t^.x = x) and (t^.y <> y) then
	  treeChanges := true
	else if (t^.x < x) then
	  treeChanges := treeChanges(t^.right)
	else
	  treeChanges := treeChanges(t^.left);
      end;


    procedure processing(var previous, current : tree);
      var
	temp : tree;
      begin
	if treeChanges(previous) then begin
          current := copyTree(previous); 
	  // uwaga! trzeba policzyć czy drzewo całe nie jest niezmienne
          if previous^.x = x then begin
	    // remember about y <> 0 
	    if y <> 0 then begin
              current^.y := y;
              link(previous, current, both);
	    end else begin
	      if previous^.right = Nil then begin
	        dispose(current);
	        counter := counter - 1;
	        current := previous^.left;
	      end else begin
	        // wypelnij content currenta najmniejszym elementem poddrzewa prawego
	        x := current^.x;
	        temp := findSmallestNode(current^.right);
	        current^.x := temp^.x;
	        current^.y := temp^.y;
	        processing(previous^.right, current^.right);
	      end
	    end
          end else if previous^.x < x then
            // go right
            if previous^.right = Nil then begin
              current^.right := wrap(x,y);
              link(previous, current, left);
            end else begin
	      processing(previous^.right, current^.right);
              link(previous, current, left);
	    end
          else
            // go left
            if previous^.left = Nil then begin
              current^.left := wrap(x,y);
              link(previous, current, right);
            end else begin
	      processing(previous^.left, current^.left);
              link(previous, current, right);
	    end;
        end else begin
	  current := previous;
	  inc(previous^.ref_count);
	end;
      end;

    begin
      inc(vec_pos);
      if (vec_pos = 1) or (trees[vec_pos-1] = nil) then begin
        trees[1] := wrap(x,y);
      end else
	processing(trees[vec_pos-1], trees[vec_pos]);
      przypisanie := counter;
    end;


  procedure writeTree(const t : tree; i : integer);
    var
      j : integer;
    begin
      for j := 0 to i do
        write('   ');
      if t <> Nil then begin
	writeln('node x = ', t^.x, ' y = ', t^.y);
        writeTree(t^.left, i+1);
        writeTree(t^.right, i+1);
      end else
	writeln('nil');
    end;

  procedure writeTrees();
    var 
      j : integer;
    begin
      for j := 1 to vec_pos do begin
        writeTree(trees[j], 0);
	writeln();
      end;
      writeln('Current number of nodes is: ', counter);
    end;

  procedure cleanse(var t : tree);
    begin
      if t <> Nil then begin
        dec(t^.ref_count); 
        if (t^.ref_count = 0) then begin
	  cleanse(t^.left);
	  cleanse(t^.right);
	  dispose(t);
	  dec(counter);
	  t := Nil;
	end;
      end;
    end;

  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
    begin
      suma := 0;
    end;

  function czysc(nr_funkcji : LongInt) : LongInt;
    begin
      cleanse(trees[nr_funkcji]);
      trees[nr_funkcji] := nil;
      czysc := counter;
    end;

end.
