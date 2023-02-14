// Permet d'ajouter des user dans une map, equivalent d'une BDD d'user

type index = nat
type user = string

type mapping = (index, user) map

type storage = {
    last_index : index;
    user_map : mapping
}

type parameter =
  AddUser of string
| Reset of unit

type return = operation list * storage

let add_user (user, store : string * storage) : storage =
    let returned_user_map : mapping = Map.add store.last_index user store.user_map in
    let new_index : index = (store.last_index + 1n) in
    { store with last_index = new_index; user_map = returned_user_map }

let main (action, store : parameter * storage) : return =
 let new_store : storage = match action with
        AddUser (p) -> add_user (p, store)
        | Reset -> { store with last_index = 0n; user_map = Map.empty}
        in
 (([] : operation list), new_store)