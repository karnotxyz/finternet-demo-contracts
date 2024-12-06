import * as dotenv from "dotenv";
dotenv.config();
import { deployContract, getAccount, myDeclare, getContracts, getProvider } from "./utils";
import { Account, ByteArray, RawArgs, uint256, RpcProvider, TransactionExecutionStatus, extractContractHashes, hash, json, provider, byteArray, Contract } from 'starknet'

const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function deployFinternetId(acc: Account) {
  //   const { class_hash } = await myDeclare("FinternetId", "finternet")
  //   sleep(10000);
  await deployContract("FinternetId", "0x26c00cc5e2c69164848b30c7038c96bf4e48ecc6a295d42bba4765151b91000", {});
  //   await deployContract("FinternetId", class_hash, {});
}

async function deployKycRegistry(acc: Account) {
  // const { class_hash } = await myDeclare("KycRegistry", "finternet");
  // sleep(10000);
  await deployContract("KycRegistry", "0x06e81bb3ea0e05c8f671aff70cb165ac724f6c4672fee4faff34a3fea195a521", { owner: acc.address });
  // await deployContract("KycRegistry", class_hash, { owner: acc.address });
}

async function deployLiquidityPool(acc: Account) {
  const { class_hash } = await myDeclare("LiquidityPool", "finternet");
  sleep(10000);
  await deployContract("LiquidityPool", class_hash, {
    kyc_registry: getContracts().contracts["KycRegistry"]
  });
}

async function deployTokenManager(acc: Account) {
  // const { class_hash } = await myDeclare("TokenManager", "finternet")
  // sleep(10000);
  await deployContract("TokenManager", "0x028d89a306b161c617570e7e7820e8834e0a2d7fdfcf63e89b044945204de3ac", {
    owner: acc.address,
    kyc_registry: getContracts().contracts["KycRegistry"]
  });
}

async function deployTokenizedCurrency(acc: Account) {
  // const { class_hash } = await myDeclare("TokenizedCurrency", "finternet")
  // sleep(10000);
  const name = byteArray.byteArrayFromString('Tokenized SGD');
  const symbol = byteArray.byteArrayFromString('tSGD');
  await deployContract("TokenizedCurrency", "0x4a045f7165ab41e7a48efff932c3ced8d80050183cc425b55101e2e586a232", {
    name,
    symbol,
    owner: getContracts().contracts["TokenManager"],
  });
  // await deployContract("TokenizedCurrency", class_hash, {
  //   name: byteArray.byteArrayFromString("Tokenized INR"),
  //   symbol: byteArray.byteArrayFromString("tINR"),
  //   owner: getContracts().contracts["TokenManager"],
  // });
}

async function approveKyc(acc: Account) {
  const kycRegistry = getContracts().contracts["KycRegistry"];
  const provider = getProvider();
  const cls = await provider.getClassAt(kycRegistry);
  const kyc_registry = new Contract(cls.abi, kycRegistry, provider);
  const call = kyc_registry.populate('approve_registration', {
    user: "0x034D71cAD6637385a0FfabdeDB8202D451a2d50DC7E46575456124362E8eFC41"
  });
  let result = await acc.execute([call]);
  console.log('Kyc approved: ', result.transaction_hash);
  console.log(result);
}



async function main() {
  const acc = getAccount();
  //   await deployFinternetId(acc);
  // await deployKycRegistry(acc);
  // await deployLiquidityPool(acc);
  // await deployTokenManager(acc);
  // await deployTokenizedCurrency(acc);
  await approveKyc(acc);
}

main();
