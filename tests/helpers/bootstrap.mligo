#import "../../src/contracts/main.mligo" "Main"

let boot_accounts (inittime : timestamp) =
    let () = Test.reset_state_at inittime 6n ([] : tez list) in
    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2,
        Test.nth_bootstrap_account 3
    in
    accounts

let originate_contract (init_storage: Main.storage) = 
    let (taddr, _, _) = Test.originate Main.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    (addr, taddr, contr)

let base_storage = 0