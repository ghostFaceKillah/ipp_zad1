// Zadanie zaliczeniowe nr 1 - Indywidualny Projekt Programistyczny MIM UW
// Michał Garmulewicz, 15.03.2014
// Reprezentacja dynamicznej funkcji na drzewach BST

unit drzewa;

interface

  procedure inicjuj();
  // runs at the beginning. nils array of trees, sets up node node_counter and 
  // used array space node_counter 

  function przypisanie(const x, y : LongInt) : LongInt;
  // used for handling valid assignment. Returns current number of nodes

  function suma(const nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
  // used for handling syntactically valid 'suma' calls. Returns wanted sum

  function czysc(const nr_funkcji : LongInt) : LongInt;
  // used for handling syntactically valid 'czysc' calls

  function treeExists(const i : LongInt) : Boolean;
  // used for checking if given tree exists

  procedure writeTrees();
  // used for debugging. Writes all trees in memory from the begging to now.

  procedure finalCleanup();
  // cleans up garbage after program run

implementation

  const
    MAX_TREE_NUM = 1000000;
  
  type
    Tree = ^Node;
    Node = record
      x : LongInt;
      y : LongInt;
      l_sum : LongInt;
      // sum of all ys in the left subtree
      ref_count : Integer;
      left : Tree;
      right : Tree;
    end;

    TheTrees = Array[0..MAX_TREE_NUM] of Tree;

  var
    trees : TheTrees;
    node_counter : LongInt;
    functions_counter : Integer;
  
  procedure inicjuj();
    var
      i : LongInt;
    begin
      node_counter := 0;
      functions_counter := 0;
      for i := 0 to MAX_TREE_NUM do
        trees[i] := nil;
    end;

  function wrap(const x, y, l_sum : LongInt) : Tree;
    var
      resu : Tree;
    begin
      new(resu);
      inc(node_counter);
      resu^.x := x;
      resu^.y := y;
      resu^.l_sum := l_sum;
      resu^.ref_count := 1;
      resu^.left := nil;
      resu^.right := nil;
      wrap := resu;
    end;

  function copyTree(const t : Tree) : Tree;
    begin
      copyTree := wrap(t^.x, t^.y, t^.l_sum);
    end;

  procedure link(var previous : Tree; var current : Tree; 
                 const which_direction : String);
    // used for automatic linking of unchanged subtrees. 
    begin
      assert(previous <> nil);
      assert(current <> nil);
      assert((which_direction = 'left') or
             (which_direction = 'right') or
             (which_direction = 'both'));
      if (which_direction = 'left') or (which_direction = 'both') then begin
        current^.left := previous^.left;
        if (previous^.left <> nil) then
          inc(previous^.left^.ref_count);
      end;
      if (which_direction = 'right') or (which_direction = 'both') then begin
        current^.right := previous^.right;
        if (previous^.right <> nil) then
          inc(previous^.right^.ref_count);
      end;
    end;

  function getFunctionValue(const t : Tree; const x :  LongInt) : Integer;
    begin
      if (t = nil) then
        getFunctionValue := 0
      else if (t^.x = x) then
        getFunctionValue := t^.y
      else if (t^.x < x) then
        getFunctionValue := getFunctionValue(t^.right, x)
      else
        getFunctionValue := getFunctionValue(t^.left, x);
    end;

  procedure insertNodeIntoTree(var previous : Tree; var current : Tree; 
                               const x, y : LongInt);
    begin
      if (previous = nil) then 
        current := wrap(x, y, 0)
      else begin
        current := copyTree(previous);
        assert(current^.x <> x);
        if (previous^.x < x) then begin
           link(previous, current, 'left');
           insertNodeIntoTree(previous^.right, current^.right, x, y);
         end else begin
           link(previous, current, 'right');
           current^.l_sum := current^.l_sum + y;
           insertNodeIntoTree(previous^.left, current^.left, x, y);
        end;
      end;
    end;

  procedure changeValueOfFunction(var previous : Tree; var current : Tree;
                                  const x, y, dy : LongInt);
    begin
      assert(previous <> nil);
      current := copyTree(previous);
      if (previous^.x = x) then begin
        current^.y := y;
        link(previous, current, 'both');
      end else if (previous^.x < x) then begin
        link(previous, current, 'left');
        changeValueOfFunction(previous^.right, current^.right, x, y, dy);
      end else begin
        link(previous, current, 'right');
        current^.l_sum := current^.l_sum + dy;
        changeValueOfFunction(previous^.left, current^.left, x, y, dy);
      end;
    end;

  procedure deleteHelper(var previous : Tree; var current : Tree; 
                         const dy : LongInt);
    // it deletes the smallest x child of right subtree of node
    // being deleted in the next procedure. It starts from the root of
    // the right subtree and copies & links all nodes on the way down
    var
      temp : Tree;
    begin
      current := copyTree(previous);
      if (previous^.left <> nil) then begin
        current^.l_sum := current^.l_sum + dy;
        link(previous, current, 'right');
        deleteHelper(previous^.left, current^.left, dy);
      end else begin
        temp := current;
        current := previous^.right;
        dispose(temp);
        dec(node_counter);
        if (current <> nil) then
          inc(current^.ref_count);
      end;
    end;

  procedure deleteNode(var previous : Tree; var current : Tree;
                       const x, dy : LongInt);
    var
      temp : Tree;
    begin
      assert(previous <> nil);
      current := copyTree(previous);
      if (previous^.x = x) then begin
        if (previous^.right = nil) then begin
          dispose(current);
          dec(node_counter);
          current := previous^.left;
          if (current <> nil) then 
            inc(previous^.left^.ref_count);
        end else begin
          temp := previous^.right;
          while (temp^.left <> nil) do begin
            temp := temp^.left;
          end;
          current^.x := temp^.x;
          current^.y := temp^.y;
          link(previous, current, 'left');
          deleteHelper(previous^.right, current^.right, -temp^.y);
        end
      end else if (previous^.x < x) then begin
        link(previous, current, 'left');
        deleteNode(previous^.right, current^.right, x, dy);
      end else begin
        link(previous, current, 'right');
        current^.l_sum := current^.l_sum + dy;
        deleteNode(previous^.left, current^.left, x, dy);
      end;
    end;


  function przypisanie(const x, y : LongInt) : LongInt;
    var
      current_y : LongInt;

    begin
      inc(functions_counter);
      current_y := getFunctionValue(trees[functions_counter - 1], x);
      if (current_y = 0) and (y > 0) then
        insertNodeIntoTree(trees[functions_counter - 1], 
                           trees[functions_counter], x, y)
      else if (current_y > 0) and (y > 0) and (current_y <> y) then
        changeValueOfFunction(trees[functions_counter - 1],
                              trees[functions_counter], x, y, y - current_y)
      else if (current_y > 0) and (y = 0) then
        deleteNode(trees[functions_counter - 1], trees[functions_counter],
                   x, -current_y)
      else begin
        trees[functions_counter] := trees[functions_counter - 1];
        if (trees[functions_counter] <> nil) then
          inc(trees[functions_counter - 1]^.ref_count);
      end;
      przypisanie := node_counter;
    end;

  procedure writeTree(const t : Tree; h : Integer);
    // used for debugging
    var
      j : Integer;
    begin
      for j := 0 to h do
        write('   ');
      if (t <> nil) then begin
        writeln('f(', t^.x, ')=', t^.y,' l_sum=', t^.l_sum);
        writeTree(t^.left, h + 1);
        writeTree(t^.right, h + 1);
      end else
        writeln('nil');
    end;

  procedure writeTrees();
    // used for debugging
    var 
      j : Integer;
    begin
      for j := 0 to functions_counter do begin
        writeTree(trees[j], 0);
        writeln();
      end;
      writeln('Current number of nodes is: ', node_counter);
    end;

  procedure cleanse(var t : Tree);
    // worker function for wrapper czysc. Decreases the reference node_counter
    // and when ref count is zero, node should be disposed.
    begin
      if (t <> nil) then begin
        dec(t^.ref_count); 
        if (t^.ref_count = 0) then begin
          cleanse(t^.left);
          cleanse(t^.right);
          dispose(t);
          dec(node_counter);
        end;
        t := nil;
      end;
    end;

  function czysc(const nr_funkcji : LongInt) : LongInt;
    begin
      if (nr_funkcji > functions_counter) then
        czysc := -1
      else begin
        cleanse(trees[nr_funkcji]);
        trees[nr_funkcji] := nil;
        czysc := node_counter;
      end;
    end;

  function partialSum(const x : LongInt; t : tree) : LongInt;
    var
      sum : LongInt;
    begin
      sum := 0;
      while (t <> nil) do
        if (t^.x > x) then
          t := t^.left
        else begin
          sum := sum + t^.y + t^.l_sum;
          t := t^.right;
        end;
        partialSum := sum;
    end;
    
  function suma(const nr_funkcji, lewy_argument,
                prawy_argument : LongInt) : LongInt;
    begin
      if (nr_funkcji > functions_counter) then
        suma := -1
      else if (trees[nr_funkcji] = nil) then
        suma := 0
      else begin
        suma := partialSum(prawy_argument, trees[nr_funkcji])
                - partialSum(lewy_argument - 1, trees[nr_funkcji]);
      end;
    end;

  function treeExists(const i : LongInt) : Boolean;
    begin
      treeExists := (i <= functions_counter);
    end;

  procedure finalCleanup();
    var
      i : LongInt;
    begin
      for i := 0 to functions_counter do
        cleanse(trees[i]);
      assert(node_counter = 0);
    end;
end.
