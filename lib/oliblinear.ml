open Core.Std

module L = Liblinear

let (+@) = Ctypes.(+@)
let (<-@) = Ctypes.(<-@)
let (!@) = Ctypes.(!@)

let save_model = L.save_model

let load_model fn =
    match Sys.file_exists fn with
    | `Yes -> L.load_model fn
    | _ -> raise (Sys_error ("File: " ^ fn ^ " does not exist"))

let get_nr_feature = L.get_nr_feature
let get_nr_class = L.get_nr_class
let free_model_content = L.free_model_content
let free_and_destroy_model = L.free_and_destroy_model
let destroy_param = L.destroy_param
let check_parameter = L.check_parameter
let check_probability_model = L.check_probability_model

let get_bias m = Ctypes.getf (!@ m) L.bias

let get_labels m =
    let num_classes = get_nr_class m in
    let _labels = Ctypes.allocate_n Ctypes.int ~count:num_classes in
    let _ = Liblinear.get_labels m _labels in
    Ctypes.Array.to_list (Ctypes.Array.from_ptr _labels num_classes)

let make_feature_node idx value =
    let fn = Ctypes.make L.feature_node in
    let () = begin
        Ctypes.setf fn L.index idx;
        Ctypes.setf fn L.value value
    end in
    fn

let feature_node_array lst feature_max ?(bias=(-1.0)) =
    let bias_node = if bias >= 0.0 then
        make_feature_node (feature_max + 1) bias
    else
        make_feature_node (-1) 0.0
    in
    List.filter_map lst ~f:(fun (x, y) ->
        if x <= feature_max then Some (make_feature_node x y) else None
    )
    |> (fun x -> List.concat [x; [make_feature_node (-1) 0.0; bias_node]])
    |> Ctypes.Array.of_list L.feature_node
    |> Ctypes.Array.start

let predict model features =
    let bias = get_bias model in
    let nrf = get_nr_feature model in
    let feature_nodes = feature_node_array features nrf ~bias in
    L.predict model feature_nodes

