import * as dotenv from "dotenv";
dotenv.config();
import { myDeclare } from "./utils";
import {Account, RawArgs, uint256, RpcProvider, TransactionExecutionStatus, extractContractHashes, hash, json, provider} from 'starknet'

async function deployLST(acc: Account, staking_addr: string) {
    const { class_hash } = await myDeclare("LST", "lst")
    
}