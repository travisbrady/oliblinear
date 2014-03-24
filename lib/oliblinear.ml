
module L = Liblinear

let (+@) = Ctypes.(+@)
let (<-@) = Ctypes.(<-@)

let no_bias =
    let fn = Ctypes.make L.feature_node in
    let () = begin
        Ctypes.setf fn L.index (-1);
        Ctypes.setf fn L.value (-1.0)
    end in
    fn

let predict m fns =
    let len = Array.length fns in
    let fnp = Ctypes.allocate_n L.feature_node ~count:(len + 1) in

    for i = 0 to (len - 1) do
        let (x, y) = Array.get fns i in
        let ft = Ctypes.make L.feature_node in
        let () = begin
            Ctypes.setf ft L.index x;
            Ctypes.setf ft L.value y
        end in
        (fnp +@ i) <-@ ft
    done;
    let nb = no_bias in
    (fnp +@ len) <-@ nb;
    L.predict m fnp


let get_nr_feature = Liblinear.get_nr_feature
let get_nr_class = Liblinear.get_nr_class

let get_labels m =
    let num_classes = get_nr_class m in
    let _labels = Ctypes.allocate_n Ctypes.int ~count:num_classes in
    let _ = Liblinear.get_labels m _labels in
    Ctypes.Array.to_list (Ctypes.Array.from_ptr _labels num_classes)
