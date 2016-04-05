module A = Nullable_array

let check_invalid_arg (f: 'a -> unit) (a: 'a) =
  try f a; raise Exit
  with
  | Exit -> assert false
  | Invalid_argument _ -> ()

let ign_make (n:int) =
  ignore(A.make n:'a A.t)

let ign_get (a:'a A.t) n =
  ignore(A.get a n:'a option)

let t1 () =
  let a = A.make 8 in
  let b = A.make 8 in
  assert(a = b);
  assert(not (a == b));
  assert(A.length a = 8);
  check_invalid_arg ign_make (-1);
  check_invalid_arg ign_make (-120908);
  check_invalid_arg ign_make Sys.max_array_length

let t2 () =
  let a = A.make 3 in
  assert(A.get a 0 = None);
  assert(A.get a 1 = None);
  assert(A.get a 2 = None);
  check_invalid_arg (ign_get a) (-1);
  check_invalid_arg (ign_get a) (-1000);
  check_invalid_arg (ign_get a) (3);
  check_invalid_arg (ign_get a) max_int;
  check_invalid_arg (ign_get a) min_int

let t3 () =
  let a = A.make 3 in
  let empty = A.make 3 in
  assert(A.length a = 3);
  assert(A.length A.empty_array = 0);
  check_invalid_arg (A.set a (-1)) (Some 'a');
  check_invalid_arg (A.set a (-1000)) (Some 'a');
  check_invalid_arg (A.set a (3)) (Some 'a');
  check_invalid_arg (A.set a (max_int)) (Some 'a');
  check_invalid_arg (A.set a (min_int)) (Some 'a');
  check_invalid_arg (A.set_some a (-1)) 'a';
  check_invalid_arg (A.set_some a (-1000)) 'a';
  check_invalid_arg (A.set_some a (3)) 'a';
  check_invalid_arg (A.set_some a (max_int)) 'a';
  check_invalid_arg (A.set_some a (min_int)) 'a';
  check_invalid_arg (A.clear a) (-1);
  check_invalid_arg (A.clear a) (-1000);
  check_invalid_arg (A.clear a) (3);
  check_invalid_arg (A.clear a) (max_int);
  check_invalid_arg (A.clear a) (min_int);
  assert(a = empty)

let t4 () =
  let a = A.make 3 in
  let empty = A.make 3 in
  A.set a 0 (Some 'a');
  A.set a 2 (Some 'c');
  assert(A.get a 0 = Some 'a');
  assert(A.get a 1 = None);
  assert(A.get a 2 = Some 'c');
  A.set_some a 1 'b';
  assert(A.get a 0 = Some 'a');
  assert(A.get a 1 = Some 'b');
  assert(A.get a 2 = Some 'c');
  A.clear a 2;
  assert(A.get a 0 = Some 'a');
  assert(A.get a 1 = Some 'b');
  assert(A.get a 2 = None);
  A.clear a 0;
  assert(A.get a 0 = None);
  assert(A.get a 1 = Some 'b');
  assert(A.get a 2 = None);
  A.clear a 1;
  assert(A.get a 0 = None);
  assert(A.get a 1 = None);
  assert(A.get a 2 = None);
  assert(a = empty)

let () =
  t1 ();
  t2 ();
  t3 ();
  t4 ();
  ()
