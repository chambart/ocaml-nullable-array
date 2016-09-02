Nullable-array is a small self-contained library providing an efficient implementation for a type equivalent to `'a option array`

The OCamlDoc documentation is available (here)[...]


```OCaml
let a = Nullable_array.make 3 in
Nullable_array.set 1 (Some 4);
assert(Nullable_array.get 0 = None);
assert(Nullable_array.get 1 = Some 4);
```
