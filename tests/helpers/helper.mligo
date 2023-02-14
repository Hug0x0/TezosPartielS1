#import "../../src/contracts/main.mligo" "Main"
#import "assert.mligo" "Assert"

type taddr = (Main.parameter, Main.storage) typed_address
type contr = Main.parameter contract

let get_storage(taddr : taddr) =
    Test.get_storage taddr

let call (p, contr : Main.parameter * contr) =
    Test.transfer_to_contract contr (p) 0mutez

//Increment functions
let call_increment (p, contr : int * contr) =
    call(Increment(p), contr)

let call_increment_success (p, contr : int * contr) =
    Assert.tx_success(call_increment(p, contr))

let call_increment_failure (p, contr, expected_error : int * contr * string) =
    Assert.tx_failure(call_increment(p, contr), expected_error)

//Decrement functions
let call_decrement (p, contr : int * contr) =
    call(Decrement(p), contr)

// let call_decrement_success (p, contr : Main.parameter * contr) =
//     Assert.tx_success (call_increment(p, contr))