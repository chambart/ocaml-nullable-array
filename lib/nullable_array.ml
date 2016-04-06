(*
   Designed and tested for OCaml <= 4.03 bytecode and native,
   Taking into consideration:
   * Dynamic float arrays
   * Marshalling
   * no-naked-pointer variant

   If future version of OCaml runtime and compiler break some
   expected invariants, this library will be updated accordingly.

   Please do not use it with any non-blessed version. Consider
   using the slower, but safer Option array variant.

   Also in general: Please do not write code like that. This rely on
   many compiler implementation details that are impossible to get
   right without knowing the compiler internals !
   --
   Pierre Chambart
*)

(* A size n nullable array is a size n+1 array containing a reference
   null value at index 0.

   The n-th field of [a] is considered null iff [a.(n+1) == a.(0)]

   Setting the n-th field to null is done by [a.(n+1) <- a.(0)]

   Setting the n-th field to a given value [v] is simply [a.(n+1) <- v]

   This reference null value in field 0 is required since
   marshalling/unmarshalling destroy sharing (breaking physical
   equality). (See null definition for more details)

   The reference null is in field 0 to avoid needing to read the size
   for accessing it. It implies that any other access requires some
   arithmetic, but this is already the case in OCaml as integers are
   tagged.


   Since nullable arrays can contain both pointers (the null value is
   a pointer) and floating point values, great care is taken to ensure
   that the compiler consider a nullable array as an array containing
   either pointer or integers. This means that float values will be
   boxed and that not dynamic tag check occur when building or
   accessing a nullable array. To achieve this, every manipulation
   must be explicitely annotated with the ['a elt] type.

*)


type elt =
  | Constant
  | Allocated of int
  (* No value of this type will ever be created, but this type
     annotation is important to ensure that the compiler consider
     those values as 'anything that is not a float'

     When this property is required, the code should be completely
     explicitely annotated. *)

exception Null
let null : elt = Obj.magic Null
(* The null value is encoded as a value for which the semantics of
   physical equality is completely defined. This could be a mutable
   value, but exception also have the nice benefic of being able to
   be statically allocated as they are not mutable.

   There is only a single instance of the null value explicitely
   created, but other instances can be created through unmarshal.

   Note that the 0 value could have been use with the classic
   runtime, but would break the no-naked-pointer invariant of never
   having a pointer outside of the heap that does not look like a
   black OCaml value, which of course cannot be achieved with 0.
   Future version of the runtime could be made to understant the
   0 pointer. If this happen, this value could be created as:

   {[
     external int_as_pointer : int -> elt = "%int_as_pointer"
     let null : elt = int_as_pointer 0

     let nullf () : elt = int_as_pointer 0 [@@ocaml.inline]
   ]}

   Note that nullf might be faster in general as if the compiler
   is not able to constant fold the primitive (which will probably
   never happen as this is not a valid OCaml value and has no
   valid representation in either closure or flambda approximations)
   it will still be able to inline the function which will easily
   produce efficient code. *)

type 'a t = elt array

let make (n:int) : 'a t =
  (* This is annotated with the type to ensure that transcore
     specialize it to the elt type. i.e. it is represented as an
     array that can contain integer and pointers, but cannot contain
     floating point values. *)

  (* The array contains n+1 elements: the first one is used to store
     the reference null. *)
  if n < 0 then invalid_arg "Nullable_array.make";
  (* There is no need to check for the upper bound as [Array.make]
     already does it *)
  Array.make (n+1) (null:elt)

let empty_array : 'a t = [| null |]

let get_null (a:'a t) : elt =
  (* An array of type ['a t] cannot be empty *)
  Array.unsafe_get (a:'a t) 0
[@@ocaml.inline]

let get (a:'a t) (n:int) : 'a option =
  (* There is no need to check for the upper bound as [Array.get]
     already does it *)
  if n < 0 then invalid_arg "Nullable_array.get";
  let elt = Array.get (a:'a t) (n+1) in
  let null = get_null a in
  if elt == null then
    None
  else
    Some (Obj.magic elt:'a)

let length (a:'a t) = Array.length a - 1

let set_some (a:'a t) (n:int) (v:'a) : unit =
  if n < 0 then invalid_arg "Nullable_array.set_some";
  Array.set (a:'a t) (n+1) (Obj.magic v : elt)

let clear (a:'a t) (n:int) : unit =
  if n < 0 then invalid_arg "Nullable_array.clear";
  let null = get_null a in
  Array.set (a:'a t) (n+1) null

let set (a:'a t) (n:int) (v:'a option) : unit =
  if n < 0 then invalid_arg "Nullable_array.set_some";
  match v with
  | None ->
    let null = get_null a in
    Array.set (a:'a t) (n+1) null
  | Some v ->
    Array.set (a:'a t) (n+1) (Obj.magic v : elt)

let iteri ~(some:int -> 'a -> unit) ~(none:int -> unit) (a:'a t) : unit =
  let null = get_null a in
  for i = 1 to Array.length a - 1 do
    let elt = Array.unsafe_get a i in
    if elt != null then
      some (i-1) (Obj.magic elt:'a)
    else
      none (i-1)
  done
[@@ocaml.inline]

let unsafe_manual_blit (from:'a t) (from_start:int) (to_:'a t) (to_start:int) (len:int) =
  let null_from = get_null from in
  let null_to = get_null to_ in
  for i = 0 to len - 1 do
    let v = from.(i + from_start + 1) in
    if v == null_from then
      to_.(i + to_start + 1) <- null_to
    else
      to_.(i + to_start + 1) <- v
  done

let blit (from:'a t) (from_start:int) (to_:'a t) (to_start:int) (len:int) =
  if len < 0 || from_start < 0 || from_start > length from - len
     || to_start < 0 || to_start > length to_ - len
  then invalid_arg "Nullable_array.blit"
  else begin
    (* If both null are the same, we can optimize by using the version
       from the runtime. Since the only way for those not to be equal is
       related to some marshaling/unmarshaling, this hold in the general
       case, hence the [@inlined never] attibute on the other branch. *)
    let null_from = get_null from in
    let null_to = get_null to_ in
    if null_from == null_to then
      Array.blit from (from_start + 1) to_ (to_start + 1) len
    else
      (unsafe_manual_blit [@inlined never]) from from_start to_ to_start len
  end
