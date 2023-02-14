#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "fa2_storage.mligo" "NFT_FA2_Storage"
type action =
	AddAdmin of Parameter.add_admin_param
	| OkAdmin of Parameter.ok_admin_param
	| RemoveAdmin of Parameter.remove_admin_param
	| PayContractFees of Parameter.pay_contract_fees_param
	| CreateCollection of Parameter.create_collection_param
    | CreateNFT of Parameter.create_nft_param

type return = operation list * Storage.t
type ext_storage = NFT_FA2_Storage.t

let assert_admin(_assert_admin_param, store: Parameter.assert_admin_param * Storage.t) : unit =
	match  Map.find_opt(Tezos.get_sender():address) store.admin_list with
		Some (admin) -> 
			if admin then else failwith "Not admin"
		| None -> failwith "Not admin"

let assert_blacklist(_assert_blacklist_param, store : Parameter.assert_blacklist_param * Storage.t) : unit = 
	let blacklisted = fun (user : Storage.user) -> if(user = Tezos.get_sender()) then failwith "blacklisted" else () in
	let _ = List.iter blacklisted store.creator_blacklist in
    ()
	()
Ò
let add_admin(add_admin_param, store: Parameter.add_admin_param * Storage.t) : Storage.t = 
	let admin_list : Storage.admin_mapping = 
		match Map.find_opt add_admin_param store.admin_list with
			Some _ -> failwith "ive already invited this user"
			| None -> Map.add add_admin_param false store.admin_list
		in
	{ store with admin_list }

let ok_admin(_ok_admin_param, store: Parameter.ok_admin_param * Storage.t) : Storage.t =
	let sender : address = Tezos.get_sender() in
	let admin_list : Storage.admin_mapping = 
		match Map.find_opt sender store.admin_list with
			Some _ -> Map.update sender (Some(true)) store.admin_list
			| None -> failwith "Error: you are not invited to be an admin"
		in
	{ store with admin_list }

let remove_admin(remove_admin_param, store: Parameter.remove_admin_param * Storage.t) : Storage.t = 
	let sender:address = Tezos.get_sender() in
	if(sender = remove_admin_param) then 
		failwith "Error: you cannot remove yourself as an admin"
	else
		let admin_list : Storage.admin_mapping = 
			match Map.find_opt remove_admin_param store.admin_list with
				Some _ -> Map.remove remove_admin_param store.admin_list
				| None -> failwith "error: this user is not an admin"
			in
		{ store with admin_list }

let pay_contract_fees(_pay_contract_fees_param, store : Parameter.pay_contract_fees_param * Storage.t) : Storage.t =
	let amount : tez = Tezos.get_amount() in
	let sender: address = Tezos.get_sender() in
	if(amount >= 10tez) then
		match Map.find_opt sender store.paid with
			Some -> failwith "Error: you have already paid"
			| None -> 
				let paid: Storage.paid_mapping = Map.add sender true store.paid in
				{store with paid}
	else
		failwith "Error: you must pay at least 10tz to use this contract"
	store

let create_collection(_create_collection_param, store : Parameter.create_collection_param * Storage.t) : Storage.t =
    let sender = Tezos.get_sender() in
	let initial_storage: ext_storage = {
		ledger = Big_map.empty;
		token_metadata = Big_map.empty;
		operators = Big_map.empty;
		metadata = Big_map.empty;
	} in
    let create_my_contract () : (operation * address) =
      [%Michelson ( {| {
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT
#include "./FA2_NFT.tz"
               ;
            PAIR } |}
              : lambda_create_contract)] ((None : key_hash option), 0tez, initial_storage)
    in
    let originate : operation * address = create_my_contract() in
	let collections : Storage.collection_list = (sender, originate.1) :: store.collections in
    { store with collections }

let main (action, store : action * Storage.t) : return =
	let new_store : Storage.t = match action with
		| AddAdmin (user) -> 
			let _ : unit = assert_admin((), store) in 
			add_admin(user, store)
		| AcceptAdmin _ -> accept_admin((), store)	
		| RemoveAdmin(user) -> 
			let _ : unit = assert_admin((), store) in 
			remove_admin(user, store)
		| PayContractFees _ -> pay_contract_fees((), store)
		| CreateCollection _ -> 
			let _ : unit = assert_access((), store) in	
			let _ : unit = assert_blacklist((), store) in	
			create_collection((), store)
		| Reset -> { store with creator_blacklist = []; admin_list = Map.empty; paid = Map.empty; collections = [] }
		in
	(([] : operation list), new_store)

//Une vue qui permettra de retourner les collections créées par un user
[@view] let get_storage ((),s: unit * Storage.t) : Storage.t = s