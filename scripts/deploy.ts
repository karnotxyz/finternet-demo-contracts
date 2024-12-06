import * as dotenv from "dotenv";
dotenv.config();
import { deployContract, getAccount, myDeclare, getContracts } from "./utils";
import { Account, RawArgs, uint256, RpcProvider, TransactionExecutionStatus, extractContractHashes, hash, json, provider } from 'starknet'

const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function deployFinternetId(acc: Account) {
//   const { class_hash } = await myDeclare("FinternetId", "finternet")
//   sleep(10000);
  await deployContract("FinternetId", "0x26c00cc5e2c69164848b30c7038c96bf4e48ecc6a295d42bba4765151b91000", {});
//   await deployContract("FinternetId", class_hash, {});
}

async function deployKycRegistry(acc: Account) {
    const { class_hash } = await myDeclare("KycRegistry", "finternet");
    // sleep(10000);
    // await deployContract("KycRegistry", "0x26b974203a95e83d85156feaf0e0c661fb08aba53af8db57996a93b9fac1794", { owner: acc.address });
    await deployContract("KycRegistry", class_hash, { owner: acc.address });
}

async function deployLiquidityPool(acc: Account) {
    const { class_hash } = await myDeclare("LiquidityPool", "finternet");
    sleep(10000);
    await deployContract("LiquidityPool", class_hash, { 
        kyc_registry: getContracts().contracts["KycRegistry"]
    });
}

async function deployTokenManager(acc: Account) {
    const { class_hash } = await myDeclare("TokenManager", "finternet")
    sleep(10000);
    await deployContract("TokenManager", "0x02f4d694b1785d4b71e1c6c86b4600c63df6f0f77bd7e4cafbc74791b49e7310", {
        owner: acc.address,
        kyc_registry: getContracts().contracts["KycRegistry"]
    });
}



async function main() {
  const acc = getAccount();
//   await deployFinternetId(acc);
//   await deployKycRegistry(acc);
  await deployLiquidityPool(acc);
//   await deployTokenManager(acc);
}

main();
