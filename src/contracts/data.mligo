type storage = int

// define admin of the contract
let add_admin (admin, store : address * storage) : storage =
    let returned_user_map : mapping = Map.add store.last_index user store.user_map in
    let new_index : index = (store.last_index + 1n) in
    let threshold (p : unit) = if Tezos.get_amount () = 1tz then 42 else 0 in
    { store with last_index = new_index; user_map = returned_user_map }

// Set data from api to contract storage
let set_data (data : storage ) : storage = 
    let result : string = newName in
    result

[@view]
let get_last_data (store : storage) : storage = 
    let result : string = store.last_name in
    result

let main (action, store : parameter * storage) : return =
 let new_store : storage = match action with
        AddAdmin (p) -> add_admin (p, store)
        | Reset -> { store with last_index = 0n; user_map = Map.empty}
        in
 (([] : operation list), new_store)