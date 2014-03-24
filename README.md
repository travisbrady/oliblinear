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
Install liblinear, then do the standard thing for this library.
```
$ make
$ make install
```

Usage:
======
Example from examples/simple.ml:
```ocaml
open Printf

let fn = "heart_scale.model"

let () =
    let m = Liblinear.load_model fn in
    printf "num_features: %d\n" (Liblinear.get_nr_feature m);
    printf "num_classes: %d\n" (Liblinear.get_nr_class m);

    let features = [|(1, 1.0); (3, 1.0)|] in
    printf "predicted label: %f\n" (Oliblinear.predict m features);

    let labels = Oliblinear.get_labels m in
    printf "Show Labels\n";
    List.iter (fun x -> printf "Label: %d\n" x) labels
```
Currently I only need the ability to load a saved model and call `predict`, but support for `train`, `cross_validation` and the rest are forthcoming.
The features array is of the form [|(index, value)|]

Note
====
The version of liblinear in apt (1.8) returns a confusing result for predict.  After some pain I was able to
create a 1.9.4 debian package using [fpm](https://github.com/jordansissel/fpm) and things worked fine.
The version in homebrew is up-to-date and works as expected



