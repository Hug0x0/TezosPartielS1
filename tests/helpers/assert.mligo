let tx_failure (res, expected_error: test_exec_result * string) : unit =
	let expected = Test.eval expected_error in
	match res with
		Success _ -> failwith "Transaction should fail"
		| Fail (Rejected(actual, _ )) -> assert ( actual = expected)
		| Fail (Balance_too_low _) -> failwith "Failed:  Balance too low"
		| Fail (Other s) -> failwith s


let tx_success (res: test_exec_result) : unit =
	match res with
		Success _ -> ()
		| Fail (Rejected(error, _ )) ->
			let () = Test.log(error) in
			Test.failwith "Transaction should not fail"
		| Fail _ -> Test.failwith "Transaction should not fail"