open Printf

let fn = "heart_scale.model"

let () =
    printf "Ok load model\n%!";
    let m = Oliblinear.load_model fn in
    printf "Loaded\n%!";
    printf "num_features: %d\n" (Liblinear.get_nr_feature m);
    printf "num_classes: %d\n" (Liblinear.get_nr_class m);

    let features = [|(1, 1.0); (3, 1.0)|] in
    printf "predicted label: %f\n" (Oliblinear.predict m features);

    let labels = Oliblinear.get_labels m in
    printf "Show Labels\n";
    List.iter (fun x -> printf "Label: %d\n" x) labels
