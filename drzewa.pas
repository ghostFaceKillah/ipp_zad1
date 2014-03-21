// Zadanie zaliczeniowe nr 1 - Indywidualny Projekt Programistyczny MIM UW
// Michał Garmulewicz, 15.03.2014
// Reprezentacja dynamicznej funkcji na drzewach BST
unit drzewa;

interface

  procedure inicjuj();
  // run at the beginning. nils array of trees, sets up node node_counter and 
  // used array space node_counter 

  function przypisanie(x, y : LongInt) : LongInt;
  // used for handling valid assignment. Returns current number of nodes

  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
  // used for handling valid 'suma' calls. Returns wanted sum

  function czysc(nr_funkcji : LongInt) : LongInt;
  // used for handling valid 'czysc' calls

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
    // for holding trees at diffrent moments of time 

  var
    trees : TheTrees;
    // array for holding all the trees
    node_counter : LongInt;
    // how many distinct nodes we have allocated
    functions_counter : Integer;
    // where in trees array 'time' we are (how many trees there are)
  
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
      if (previous = nil) or (current = nil) then
        writeln('ERROR LINKING');
      if (which_direction = 'left') or (which_direction = 'both') then begin
        current^.left := previous^.left;
        if previous^.left <> nil then
          inc(previous^.left^.ref_count);
      end;
      if (which_direction = 'right') or (which_direction = 'both') then begin
        current^.right := previous^.right;
        if (previous^.right <> nil) then
          inc(previous^.right^.ref_count);
      end;
    end;

  function findSmallestNode(t : Tree) : Tree;
    // finds node with smallest x in the tree
    begin 
      assert(t <> nil);
      while t^.left <> nil do
        t := t^.left;
      findSmallestNode := t;
    end;

  function przypisanie(x, y : LongInt) : LongInt;

    function howMuchYChanges(const t : tree; const x, y : LongInt) : Integer;
      // subroutine used for calculating if and how much the tree changes,
      // measured in abs of y change.
      begin
        if (t = nil) then
          howMuchYChanges := y
        else if (t^.x = x) then
          howMuchYChanges := y - t^.y
        else if (t^.x < x) then
          howMuchYChanges := howMuchYChanges(t^.right, x, y)
        else
          howMuchYChanges := howMuchYChanges(t^.left, x, y);
      end;

    procedure processing(var previous, current : Tree; x, y : LongInt);
      // first it calculates how much and where the previous tree should change
      // Later it applies the change. It also links the unchaged subtrees on
      // the go, using link() procedure.
      // REWRITE DELETING 
      // REFACTOR INTO THREE SMALL FUNCS
      var
        temp : Tree;
        change_of_y : Integer;
      begin
        change_of_y := howMuchYChanges(previous, x, y);
        // calculate if tree change_of_ys
        if (change_of_y <> 0) then begin
          current := copyTree(previous); 
          // current (at the moment t)  node is same as in t - 1, but with small 
          // modificationsthat are as follows:
          if previous^.x = x then begin
            // current node should get a new y
            if y <> 0 then begin 
              // just overwrite the old y
              current^.y := y;
              link(previous, current, 'both');
            end else begin
              // kill the current node, using algorithm described on moodle
              if (previous^.right = nil) then begin
                // if right child is empty, we just dispose and link to the left
                dispose(current);
                dec(node_counter);
                current := previous^.left;
                if (previous^.left <> nil) then
                  inc(previous^.left^.ref_count);
              end else begin
                // we fill the content of current node with content of smallest
                // x element from the right subtree ...
                temp := findSmallestNode(previous^.right);
                current^.x := temp^.x;
                current^.y := temp^.y;
                // ... and dispose of the node,  which contents
                //  were taken, by setting its y to 0 and processing it
                x := current^.x;
                y := 0;
                processing(previous^.right, current^.right, x, y);
                link(previous, current, 'left');
              end
            end
          end else if (previous^.x < x) then
            // go right looking for right place for the node
            if (previous^.right = nil) then begin
              // free space in the tree to insert the node
              current^.right := wrap(x, y, 0);
              link(previous, current, 'left');
            end else begin
              // no space here, keep looking
              processing(previous^.right, current^.right, x, y);
              link(previous, current, 'left');
            end
          else begin
            current^.l_sum := current^.l_sum + change_of_y;
            // go left, but remember to modify l_sum
            if (previous^.left = nil) then begin
              // some space here, insert
              current^.left := wrap(x, y, 0);
              link(previous, current, 'right');
            end else begin
              // no space here
              processing(previous^.left, current^.left, x, y);
              link(previous, current, 'right');
            end;
          end;
        end else begin
          // the new tree is same as old one, so we just link to it
          current := previous;
          inc(previous^.ref_count);
        end;
      end;

    begin
      // now we just need to call processing() with good args
      inc(functions_counter);
      if (trees[functions_counter - 1] = nil) then begin
        // no t - 1 tree to compare to, so we make a new one
        trees[functions_counter] := wrap(x, y, 0);
      end else
        processing(trees[functions_counter - 1], trees[functions_counter], x, y);
      przypisanie := node_counter;
    end;

  procedure writeTree(const t : Tree; i : Integer);
    var
      j : Integer;
    begin
      for j := 0 to i do
        write('   ');
      if (t <> nil) then begin
        writeln('f(', t^.x, ')=', t^.y,' l_sum=', t^.l_sum);
        writeTree(t^.left, i+1);
        writeTree(t^.right, i+1);
      end else
        writeln('nil');
    end;

  procedure writeTrees();
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
          t := nil;
        end;
      end;
    end;


  function czysc(nr_funkcji : LongInt) : LongInt;
    begin
      cleanse(trees[nr_funkcji]);
      trees[nr_funkcji] := nil;
      czysc := node_counter;
    end;

  function findLastSmallerOrEq(x : LongInt; t : tree) : LongInt;
    var
      resu : LongInt;
    begin
      resu := 0;
      while t <> nil do
        if (t^.x = x) then begin
          t := nil;
          resu := x;
        end else if (t^.x > x) then
          t := t^.left
        else begin
          resu := t^.x;
          t := t^.right;
        end;
      findLastSmallerOrEq := resu;
    end;
  
  function partialSum(x : LongInt; t : Tree) : LongInt;
    // returns sum of y for x from 1 to  x, using sums of left subtrees
    // please note that x is _always_ in the tree, because its the maximal
    // smaller or equal than 'real' x element not the 'real' x.
    var
      sum : LongInt;
    begin
      sum := 0;
      if (x <> 0) then begin
        while t^.x <> x do 
          if (x > t^.x) then begin
            sum := sum + t^.y + t^.l_sum;
            t := t^.right;
          end else
            t := t^.left;
        sum := sum + t^.y + t^.l_sum;
      end;
      partialSum := sum;
    end;
      
  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
    var
      left_bound, right_bound : LongInt;
    begin
      if trees[nr_funkcji] = nil then
        suma := 0
      else begin
        left_bound := findLastSmallerOrEq(lewy_argument - 1, trees[nr_funkcji]);
        right_bound := findLastSmallerOrEq(prawy_argument, trees[nr_funkcji]);
        suma := partialSum(right_bound, trees[nr_funkcji]) 
                 - partialSum(left_bound, trees[nr_funkcji]);
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
