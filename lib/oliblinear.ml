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
        Ctypes.setf fn L.index (-1);
        Ctypes.setf fn L.value (-1.0)
    end in
    fn

let feature_node_array lst =
    List.map lst ~f:(fun (x, y) -> make_feature_node x y)
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
    let len = List.length fns in
    let fnp = feature_node_array fns in
    let bias_term = bias_feature_node m in
    (fnp +@ len) <-@ bias_term;
    L.predict m fnp

let get_labels m =
    let num_classes = get_nr_class m in
    let _labels = Ctypes.allocate_n Ctypes.int ~count:num_classes in
    let _ = Liblinear.get_labels m _labels in
    Ctypes.Array.to_list (Ctypes.Array.from_ptr _labels num_classes)

    (*
let parse_svm_line line =
    let max_idx = ref 0 in
    match (String.split_on_chars line ~on:[' '; '\t']) with
    | label :: fts -> Some (Float.of_string label,
            List.map fts ~f:(fun s ->
                let pair = String.split s ~on:':' in
                let idx = List.nth_exn pair 0 |> Int.of_string in
                if idx > !max_idx then max_idx := idx;
                (*make_feature_node idx (List.nth_exn pair 1 |> Float.of_string)*)
                feature_node_array idx (List.nth_exn pair 1 |> Float.of_string)
            ), !max_idx)
    | _ -> None

exception Bad_svm_line of string * int

let svm_read_problem problem_file_name ?(bias= -1.0) =
    let i = ref 0 in
    let x = ref [] in
    let y = ref [] in
    let max_idx = ref 0 in
    In_channel.iter_lines (open_in problem_file_name) ~f:(fun line ->
        incr i;
        match parse_svm_line line with
        | None -> raise (Bad_svm_line (line, !i))
        | Some (label, fts, this_max) ->
                if this_max > !max_idx then max_idx := this_max;
                y := label :: !y;
                x := fts :: !x
    );
    let c_y = Ctypes.Array.of_list Ctypes.double !y |> Ctypes.Array.start in
    let c_x = Ctypes.Array.of_list L.feature_node !x |> Ctypes.Array.start in
    let c_x = Ctypes.Array.of_list (Ctypes.ptr
    let prob = Ctypes.make L.problem in
    let () = begin
        Ctypes.setf prob L.l !i;
        Ctypes.setf prob L.n !max_idx;
        Ctypes.setf prob L.x c_x;
        Ctypes.setf prob L.y c_y;
        Ctypes.setf prob L.bias bias
    end in
    prob
*)
