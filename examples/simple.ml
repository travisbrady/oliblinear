open Printf

let fn = "heart_scale.model"


let () =
    let m = Liblinear.load_model fn in
    let nrf = Liblinear.get_nr_feature m in
    printf "num_features: %d\n" (Liblinear.get_nr_feature m);
    printf "num_classes: %d\n" (Liblinear.get_nr_class m);

    let features = Oliblinear.feature_node_array [(1, 1.0); (3, 1.0)] nrf in
    printf "predicted label: %f\n" (Liblinear.predict m features);

    let labels = Oliblinear.get_labels m in
    printf "Show Labels\n";
    List.iter (fun x -> printf "Label: %d\n" x) labels
