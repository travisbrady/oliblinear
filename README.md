oliblinear
==========

OCaml bindings to the liblinear library for large linear classification

Synopsis
========
This library provides (currently incomplete and razor-thin) OCaml bindings to liblinear via ctypes.
The entire API is exposed via the Liblinear module, but to work with that you'll have to create
ctypes values directly, the Oliblinear library shows a minimal attempt to alleviate the ctypes bit.
But support there is incomplete/brand new/alpha/etc

Installation:
=============
Do the standard thing.
```
$ make
$ make install
```

Usage:
======
Example from lib_test/test_predict.ml:
```ocaml
open Printf

let () =
    let fn = "heart_scale.model" in
    let m = Liblinear.load_model fn in
    printf "fts: %d\n" (Liblinear.get_nr_feature m);
    let features = [|(1, 0.5)|] in
    printf "predicted label: %f\n" (Oliblinear.predict m features);
    ()
```



