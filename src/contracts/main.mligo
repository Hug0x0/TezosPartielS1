type user = {
  id       : nat;
  is_admin : bool;
  name     : string;
  is_whilte_list : bool;
}

type mapping = (address, user) map

type storage = {
    last_index : index;
    user_map : mapping
}

type parameter =
  AddAdmin of address
| Reset of unit

// Add admin to the contract
let add_admin (admin, store : address * storage) : storage =
    let returned_user_map : mapping = Map.add store.last_index user store.user_map in
    let new_index : index = (store.last_index + 1n) in
    let threshold (p : unit) = if Tezos.get_amount () = 1tz then 42 else 0 in
    { store with last_index = new_index; user_map = returned_user_map }

let map : storage = { last_index = 3n; user_map = Map.empty }

// Admin can add or remove other admins
let admin_super (admin, store : address * storage) : storage =
    let returned_admin_map : mapping = Map.add store.last_index admin store.admin_map in
    let new_index : index = (store.last_index + 1n) in
    { store with last_index = new_index; admin_map = returned_admin_map }

// User can write in the contract
let user_write (user, store : address * storage) : storage =
    let returned_user_map : mapping = Map.add store.last_index user store.user_map in
    let new_index : index = (store.last_index + 1n) in
    { store with last_index = new_index; user_map = returned_user_map }

// Check if user is admin
[@view]
let is_admin (user, store : address * storage) : bool =
    match Map.find_opt user store.user_map with
        Some m -> m.is_admin
        | None -> false

// vue get rank user
[@view] 
let getUserRank(user, store : address ) : Storage.value =
    match Map.find_opt user store.user_map with
        Some m -> m
        | None -> failwith Errors.no_entry


let main (action, store : parameter * storage) : return =
 let new_store : storage = match action with
        AddAdmin (p) -> add_admin (p, store)
        | Reset -> { store with last_index = 0n; user_map = Map.empty}
        in
 (([] : operation list), new_store)