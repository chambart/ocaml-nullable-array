(** Nullable arrays behave like the [option array] with a more compact
    memory representation.

    Accesses are slightly more expensive than those of (non option)
    array. Values of type float are systematically boxed. *)

type 'a t
(** Arrays of nullable values *)

val make : int -> 'a t
(** [make n] Create an empty array of size n

    Raise [Invalid_argument] if [n < 0] or [n > Sys.max_array_length - 1]. *)

val empty_array : 'a t
(** A preallocated empty array *)

val length : 'a t -> int
(** Return the length (number of elements) of the given array. *)

val get : 'a t -> int -> 'a option
(** [get a n] Get the n-th field of the a array.
    The first element has number 0.
    The last element has number [Array.length a - 1].

    Raise [Invalid_argument "index out of bounds"]
    if [n] is outside the range 0 to [length a - 1].

    The result option is freshly allocated.
*)

val set : 'a t -> int -> 'a option -> unit
(** [set a n x] Modifies array [a] in place, replacing
    element number [n] with [x].

    Raise [Invalid_argument "index out of bounds"]
    if [n] is outside the range 0 to [Array.length a - 1].

    {[set a n v; assert( get a n = v )]}
*)

val set_some : 'a t -> int -> 'a -> unit
(** [set_some a n x] Modifies array [a] in place, replacing
    element number [n] with [Some x].

    Raise [Invalid_argument "index out of bounds"]
    if [n] is outside the range 0 to [Array.length a - 1].

    {[set_some a n v; assert( get a n = Some v )]}
*)

val clear : 'a t -> int -> unit
(** [clear a n] Modifies array [a] in place, replacing
    element number [n] with [None].

    Raise [Invalid_argument "index out of bounds"]
    if [n] is outside the range 0 to [Array.length a - 1].

    {[clear a n; assert( get a n = None )]}
*)

val iteri : some:(int -> 'a -> unit) -> none:(int -> unit) -> 'a t -> unit
(** [iteri ~some ~none a] applies function [some] in turn to the index
    and the value of all the defined elements of [a] and function [none]
    to all the indices of the undefined ones.
    On an array [ [|Some v0; None; Some v2|] ] it is equivalent to
    [some 0 v0; none 1; some 2 v2].
 *)

val blit : 'a t -> int -> 'a t -> int -> int -> unit
(** [blit from from_start to to_start len] copies [len] elements
    from array [from], starting at element number [from_start],
    to array [to], starting at element number [to_start]. It works
    correctly even if [v1] and [v2] are the same array, and
    the source and destination chunks overlap.

    Raise [Invalid_argument "Nullable_array.blit"] if [from_start]
    and [len] do not designate a valid subarray of [from], or if
    [to_start] and [len] do not designate a valid subarray of [to].
 *)
