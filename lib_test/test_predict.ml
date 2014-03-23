open Printf

let () =
    let fn = "heart_scale.model" in
    let m = Liblinear.load_model fn in
    printf "fts: %d\n" (Liblinear.get_nr_feature m);
    let features = [|(1, 0.5)|] in
    printf "predicted label: %f\n" (Oliblinear.predict m features);
    ()
