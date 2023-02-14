import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import contract from "../src/compiled/contract.json";
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

        async function deploy() {
            const storage = {
                user_map: new MichelsonMap(),
                user_blacklist: [],
                admin_list: new MichelsonMap(),
                has_paid: new MichelsonMap(),
            };
            const op = await Tezos.contract.originate({
                code: contract,
                storage: storage,
            });
            await op.confirmation();
            console.log(`[OK] Token FA2: ${op.contractAddress}`);
            // check contract storage with CLI
            console.log(
                `get contract storage for ${op.contractAddress}`
            );
        }
    } catch (e) {
        console.log(e);
    }
};

deploy();