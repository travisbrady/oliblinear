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

let make_feature_node idx value =
    let fn = Ctypes.make L.feature_node in
    let () = begin
        Ctypes.setf fn L.index idx;
        Ctypes.setf fn L.value value
    end in
    fn

let feature_node_array lst feature_max =
    List.filter_map lst ~f:(fun (x, y) ->
        if x <= feature_max then Some (make_feature_node x y) else None
    )
    |> (fun x -> List.concat [x; [make_feature_node (-1) 0.0; make_feature_node (-1) 0.0]])
    |> Ctypes.Array.of_list L.feature_node
    |> Ctypes.Array.start

let bias_feature_node m =
    let nrf = get_nr_feature m in
    let bias = Ctypes.getf (!@ m) L.bias in
    let bias_term =
        if bias >= 0.0 then
            make_feature_node (nrf + 1) bias
        else
            make_feature_node (-1) bias
    in
    bias_term

let predict m fns =
    let len = Array.length fns in
    let fnp = Ctypes.allocate_n L.feature_node ~count:(len + 1) in

    let bias_term = bias_feature_node m in

    for i = 0 to (len - 1) do
        let (x, y) = Array.get fns i in
        let ft = make_feature_node x y in
        (fnp +@ i) <-@ ft
    done;
    (fnp +@ len) <-@ bias_term;
    L.predict m fnp

let predict_list m fns =
    let nrf = get_nr_feature m in
    let len = List.length fns in
    let fnp = feature_node_array fns nrf in
    let bias_term = bias_feature_node m in
    (fnp +@ len) <-@ bias_term;
    L.predict m fnp

let get_labels m =
    let num_classes = get_nr_class m in
    let _labels = Ctypes.allocate_n Ctypes.int ~count:num_classes in
    let _ = Liblinear.get_labels m _labels in
    Ctypes.Array.to_list (Ctypes.Array.from_ptr _labels num_classes)

