open Printf

let fn = "heart_scale.model"

let () =
    let m = Liblinear.load_model fn in
    printf "num_features: %d\n" (Liblinear.get_nr_feature m);
    printf "num_classes: %d\n" (Liblinear.get_nr_class m);

    let features = [|(1, 0.5)|] in
    printf "predicted label: %f\n" (Oliblinear.predict m features);

    let labels = Oliblinear.get_labels m in
    List.iter (fun x -> printf "Label: %d\n" x) labels;
    ()
