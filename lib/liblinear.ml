open Ctypes
open Foreign

type solver =
    L2R_LR
    | L2R_L2LOSS_SVC_DUAL
    | L2R_L2LOSS_SVC
    | L2R_L1LOSS_SVC_DUAL
    | MCSVM_CS
    | L1R_L2LOSS_SVC
    | L1R_LR
    | L2R_LR_DUAL
    | L2R_L2LOSS_SVR
    | L2R_L2LOSS_SVR_DUAL
    | L2R_L1LOSS_SVR_DUAL

let solver_num = function
    | L2R_LR -> 0
    | L2R_L2LOSS_SVC_DUAL -> 1
    | L2R_L2LOSS_SVC      -> 2
    | L2R_L1LOSS_SVC_DUAL -> 3
    | MCSVM_CS            -> 4
    | L1R_L2LOSS_SVC    ->5
    | L1R_LR    -> 6
    | L2R_LR_DUAL -> 7
    | L2R_L2LOSS_SVR -> 11
    | L2R_L2LOSS_SVR_DUAL -> 8
    | L2R_L1LOSS_SVR_DUAL -> 9

type feature_node
let feature_node : feature_node structure typ = structure "feature_node"
let index = field feature_node "index" int
let value = field feature_node "value" double
let () = seal feature_node

type problem
let problem : problem structure typ = structure "problem"
let l = field problem "l" int
let n = field problem "n" int
let y = field problem "y" (ptr double)
let x = field problem "x" (ptr (ptr feature_node))
let bias = field problem "bias" double
let () = seal problem

type parameter
let parameter : parameter structure typ = structure "parameter"
let solver_type = field parameter "solver_type" int
let eps = field parameter "eps" double
let c = field parameter "C" double
let nr_weight = field parameter "nr_weight" int
let weight_label = field parameter "weight_label" (ptr int)
let weight = field parameter "weight_label" (ptr double)
let p = field parameter "p" double
let () = seal parameter

type model
let model : model structure typ = structure "model"
let param = field model "param" parameter
let nr_class = field model "nr_class" int
let nr_feature = field model "nr_feature" int
let w = field model "w" (ptr double)
let label = field model "label" (ptr int)
let bias = field model "bias" double
let () = seal model

(*let from = Dl.(dlopen ~filename:"liblinear/liblinear.so.1" ~flags:[RTLD_NOW])*)

let train = foreign "train" (ptr problem @-> ptr parameter @-> returning (ptr model))
let cross_validation = foreign "cross_validation" (ptr problem @-> ptr parameter @-> ptr double @-> returning void)

let predict_values = foreign "predict_values" (ptr model @-> ptr feature_node @-> ptr double @-> returning double)
let predict = foreign "predict" (ptr model @-> ptr feature_node @-> returning double)
let predict_probability = foreign "predict_probability" (ptr model @-> ptr feature_node @-> ptr double @-> returning double)

let save_model = foreign "save_model" (string @-> ptr model @-> returning int)
let load_model = foreign "load_model" (string @-> returning (ptr model))

let get_nr_feature = foreign "get_nr_feature" (ptr model @-> returning int)
let get_nr_class = foreign "get_nr_class" (ptr model @-> returning int)
let get_labels = foreign "get_labels" (ptr model @-> ptr int @-> returning void)

let free_model_content = foreign "free_model_content" (ptr model @-> returning void)
let free_and_destroy_model = foreign "free_and_destroy_model" (ptr (ptr model) @-> returning void)
let destroy_param = foreign "destroy_param" (ptr parameter @-> returning void)

let check_parameter = foreign "check_parameter" (ptr problem @-> ptr parameter @-> returning string)
let check_probability_model = foreign "check_probability_model" (ptr model @-> returning int)

