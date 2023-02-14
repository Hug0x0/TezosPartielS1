import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit } from "@taquito/taquito";
import dotenv from "dotenv";
import path from "path";


// Read environment variables from .env file
dotenv.config({ path: path.join(__dirname, "..", ".env") });

// Initialize RPC connection
const Tezos = new TezosToolkit(process.env.NODE_URL || "");

const deploy = async () => {
    try {
        const signer = await InMemorySigner.fromSecretKey(
            process.env.ADMIN_SK || ""
        );
        const admin: string = await signer.publicKeyHash();
        Tezos.setProvider({ signer });

        const storage = 0;

        const op = await Tezos.contract.originate({
            code: code_contract_1,
            storage: storage,
        });
        await op.confirmation();
        console.log(`[OK] Token FA2: ${op.contractAddress}`);
        // check contract storage with CLI
        console.log(
            `tezos-client --endpoint http://localhost:20000 get contract storage for ${op.contractAddress}`
        );
    } catch (e) {
        console.log(e);
    }
};

deploy();

