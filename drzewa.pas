unit drzewa;

interface

const
  MAX_TREE_NUM = 1000000;

type
  tree = ^node;
  node = record
    x : LongInt;
    y : LongInt;
    l_sum : LongInt;
    ref_count : integer;
    left : tree;
    right : tree;
  end;

  the_trees = array[0..MAX_TREE_NUM] of tree;
  // for holding trees at diffrent moments of time 

  procedure inicjuj;
  // run at the beginning. Nils array of trees, sets up node counter and 
  // used array space counter 

  function przypisanie(x, y : LongInt) : LongInt;
  // used for handling valid assignment. Returns current number of nodes

  function suma(nr_funkcji, lewy_argument, prawy_argument : LongInt) : LongInt;
  // used for handling valid 'suma' calls. Returns wanted sum

  function czysc(nr_funkcji : LongInt) : LongInt;
  // used for handling valid 'czysc' calls

  function treeExists(const i : LongInt) : boolean;
  // used for checking if given tree exists

  procedure writeTree(const t : tree; i : integer);
  // used for debugging this module. Writes given tree, which starts at depth i.
  // For writing tree from the root use writeTree(t, 0); 

  procedure writeTrees();
  // used for debugging. Writes all trees in memory from the begging to now.

  procedure finalCleanup();
  // cleans up garbage after program run

implementation

  type
    linkage = (left, right, both);
    // this is datatype used for passing which subtrees should be linked unchanged

  var
    trees : the_trees;
    // array for holding all the trees
    counter : LongInt;
    // how many distinct nodes we have allocated
    vec_pos : integer;
    // where in trees array 'time' we are (how many trees there are)
  
  procedure inicjuj();
    var
      i : LongInt;
    begin
      counter := 0;
      vec_pos := 0;
      for i := 0 to MAX_TREE_NUM do
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
      resu^.l_sum := 0;
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
      resu^.l_sum := t^.l_sum;
      resu^.ref_count := 1;
      resu^.right := nil;
      resu^.left := nil;
      copyTree := resu;
    end;

  procedure link(var previous : tree; var current : tree; const dir : linkage);
    // used for automatic linking of unchanged subtrees. Please note usage of 
    // custom enum type linkage= (left, right, both)
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
    // finds node with smallest x in the tree
    var
      temp : tree;
    begin 
      temp := t;
      while temp^.left <> Nil do
        temp := temp^.left;
	findSmallestNode := temp;
    end;

  function przypisanie(x, y : LongInt) : LongInt;

    function treeChanges(const t : tree; const x,y : LongInt) : integer;
      // subroutine used for calculating if and how much the tree changes,
      // measured in abs of y change.
      begin
	if t = nil then
	  treeChanges := y
	else if (t^.x = x) and (t^.y = y) then
	  treeChanges := 0
	else if (t^.x = x) and (t^.y <> y) then
	  treeChanges := y - t^.y
	else if (t^.x < x) then
	  treeChanges := treeChanges(t^.right,x,y)
	else
	  treeChanges := treeChanges(t^.left,x,y);
      end;

    procedure processing(var previous, current : tree; x,y : LongInt);
      // first it calculates how much and where the previous tree should change
      // Later it applies the change. It also links the unchaged subtrees on
      // the go, using link() procedure.
      var
	temp : tree;
	change : integer;
      begin
	change := treeChanges(previous, x, y);
        // calculate if tree changes
	if change <> 0 then begin
          current := copyTree(previous); 
          // current (at the moment t)  node is same as in t-1, but with small 
          // changes applied under:
          if previous^.x = x then begin
            // current node should get a new y
	    if y <> 0 then begin 
              // just overwrite the old y
              current^.y := y;
              link(previous, current, both);
	    end else begin
              // kill the current node, using algorithm from the task
	      if previous^.right = Nil then begin
                // if right son is empty, we just dispose and link to the left
	        dispose(current);
		dec(counter);
	        current := previous^.left;
		if previous^.left <> Nil then
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
                link(previous, current, left);
	      end
	    end
          end else if previous^.x < x then
            // go right looking for right place for the node
            if previous^.right = Nil then begin
              // free space in the tree to insert the node
              current^.right := wrap(x,y);
              link(previous, current, left);
            end else begin
              // no space here, keep looking
	      processing(previous^.right, current^.right, x, y);
              link(previous, current, left);
	    end
          else begin
	    current^.l_sum := current^.l_sum + change;
            // go left, but remember to change l_sum
            if previous^.left = Nil then begin
              // some space here, insert
              current^.left := wrap(x,y);
              link(previous, current, right);
            end else begin
              // no space here
	      processing(previous^.left, current^.left, x, y);
              link(previous, current, right);
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
      inc(vec_pos);
      if (trees[vec_pos-1] = nil) then begin
        // no t-1 tree to compare to, so we make a new one
        trees[vec_pos] := wrap(x,y);
      end else
	processing(trees[vec_pos-1], trees[vec_pos], x, y);
      przypisanie := counter;
    end;

  procedure writeTree(const t : tree; i : integer);
    var
      j : integer;
    begin
      for j := 0 to i do
        write('   ');
      if t <> Nil then begin
	writeln('f(', t^.x, ')=', t^.y,' l_sum=', t^.l_sum);
        writeTree(t^.left, i+1);
        writeTree(t^.right, i+1);
      end else
	writeln('nil');
    end;

  procedure writeTrees();
    var 
      j : integer;
    begin
      for j := 0 to vec_pos do begin
        writeTree(trees[j], 0);
	writeln();
      end;
      writeln('Current number of nodes is: ', counter);
    end;

  procedure cleanse(var t : tree);
    // worker function for wrapper czysc. Decreases the reference counter
    // and when ref count is zero, node should be disposed.
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


  function czysc(nr_funkcji : LongInt) : LongInt;
    begin
      cleanse(trees[nr_funkcji]);
      trees[nr_funkcji] := nil;
      czysc := counter;
    end;

  function findLastSmallerOrEq(x : LongInt; t : tree) : LongInt;
    var
      resu : LongInt;
    begin
      resu := 0;
      while t <> Nil do
        if t^.x = x then begin
	  t := Nil;
	  resu := x;
        end else if t^.x > x then
	  t := t^.left
	else begin
	  resu := t^.x;
	  t := t^.right;
	end;
      findLastSmallerOrEq := resu;
    end;
  
  function partialSum(x : LongInt; t : tree) : LongInt;
    // please note that x is _always_ in the tree, because its the maximal
    // smaller or equal than 'real' x element not the 'real' x.
    // finding partial sum from arg=0 to arg=0 is easy when we keep correct
    // l_sums. We search for x in the tree, and every time we go right,
    // we need to add l_sum and value of current node to the result
    // (because it is BST tree we are sure all of the nodes in left subtree
    // are smaller than x. When we go left, we are sure current elem should not
    // be added to the result, and when we find the wanted element addition
    // if its value and sum of its left subtree is obvious, as nodes there
    // are smaller
    var
      sum : LongInt;
    begin
      sum := 0;
      if x <> 0 then begin
        while t^.x <> x do 
         if x > t^.x then begin
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
      if trees[nr_funkcji] = Nil then
        suma := 0
      else begin
        left_bound := findLastSmallerOrEq(lewy_argument - 1, trees[nr_funkcji]);
        right_bound := findLastSmallerOrEq(prawy_argument, trees[nr_funkcji]);
        suma := partialSum(right_bound, trees[nr_funkcji]) 
                 - partialSum(left_bound, trees[nr_funkcji]);
      end;
    end;

  function treeExists(const i : LongInt) : boolean;
    begin
      if i > vec_pos then
        treeExists := false
      else
        treeExists := true
    end;

  procedure finalCleanup();
    var
      i : LongInt;
    begin
      for i := 0 to vec_pos do
        cleanse(trees[i]);
    end;

end.
