open OUnit2

let fn = "heart_scale.model"

let test_load _ =
    let m = Oliblinear.load_model fn in
    assert_bool "Test Load" true

let test_nr_features _ =
    let m = Oliblinear.load_model fn in
    assert_equal 13 (Oliblinear.get_nr_feature m)

let test_nr_classes _ =
    let m = Oliblinear.load_model fn in
    assert_equal 2 (Oliblinear.get_nr_class m)

let test_get_labels _ =
    let m = Oliblinear.load_model fn in
    let labels = List.sort compare (Oliblinear.get_labels m) in
    assert_equal [-1; 1] labels

let test_get_bias _ =
    let m = Oliblinear.load_model fn in
    assert_equal (-1.0) (Oliblinear.get_bias m)

(*
 * Verify that prediction using heart_scale.model
 * matches result returned by Python lib from the liblinear/python README
 * https://github.com/ninjin/liblinear/blob/master/python/README#L81
 *)
let test_predict _ =
    let m = Oliblinear.load_model fn in
    let features = [(1, 1.0); (3, 1.0)] in
    assert_equal 1.0 (Oliblinear.predict m features)

let suite= "Test Oliblinear" >:::
    ["test_load" >:: test_load;
     "test_nr_features" >:: test_nr_features;
     "test_nr_classes" >:: test_nr_classes;
     "test_get_labels" >:: test_get_labels;
     "test_get_bias"   >:: test_get_bias;
     "test_predict"    >::  test_predict]

let _ = run_test_tt_main suite
