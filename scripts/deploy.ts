import * as dotenv from "dotenv";
dotenv.config();
import { deployContract, getAccount, myDeclare, getContracts, getProvider } from "./utils";
import { Account, ByteArray, RawArgs, uint256, RpcProvider, TransactionExecutionStatus, extractContractHashes, hash, json, provider, byteArray, Contract, num } from 'starknet'

const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function deployFinternetId(acc: Account) {
    // const { class_hash } = await myDeclare("FinternetId", "finternet")
  await deployContract("FinternetId", "0x40aaa5f37b5e30a6ae8af91fe7fbb957a6a846c3354eac330a7b8c18d734e4d", {});
    // await deployContract("FinternetId", class_hash, {});
}

async function deployKycRegistry(acc: Account) {
  // const { class_hash } = await myDeclare("KycRegistry", "finternet");
  // sleep(10000);
  await deployContract("KycRegistry", "0x06e81bb3ea0e05c8f671aff70cb165ac724f6c4672fee4faff34a3fea195a521", { owner: acc.address });
  // await deployContract("KycRegistry", class_hash, { owner: acc.address });
}

async function deployLiquidityPool(acc: Account) {
  // const { class_hash } = await myDeclare("LiquidityPool", "finternet");
  // sleep(10000);
  await deployContract("LiquidityPool", "0x72f359e66fc9b2f620252cfb1b8bb3f55ab8195e7999d75d9c7e8a52b48ff6f", {
    kyc_registry: getContracts().contracts["KycRegistry"]
  });
  // await deployContract("LiquidityPool", class_hash, {
  //   kyc_registry: getContracts().contracts["KycRegistry"]
  // });
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
    user: "0x34b4735bf438f1468502f82cee84384d2789f80397ff0e8a51a4f0ba9799d3b"
  });
  let result = await acc.execute([call]);
  console.log('Kyc approved: ', result.transaction_hash);
  console.log(result);
}

async function registerTokenManager(acc: Account) {
  const tokenManager = getContracts().contracts["TokenManager"];
  const provider = getProvider();
  const cls = await provider.getClassAt(tokenManager);
  const token_manager = new Contract(cls.abi, tokenManager, provider);
  const call = token_manager.populate('approve_registration', {
    entity: "0x105482b8465f4b017675d4cb461ead4c926e14f15b8c1dc867e363f903705cf"
  });
  let result = await acc.execute([call]);
  console.log('Kyc approved: ', result.transaction_hash);
  console.log(result);

  const is_registered = await token_manager.is_registered("0x105482b8465f4b017675d4cb461ead4c926e14f15b8c1dc867e363f903705cf");
  console.log('Is registered: ', is_registered);
}


async function whitelistCurrency(acc: Account) {
  const tokenManager = getContracts().contracts["TokenManager"];
  const provider = getProvider();
  const cls = await provider.getClassAt(tokenManager);
  const token_manager = new Contract(cls.abi, tokenManager, provider);

  const call = token_manager.populate('whitelist_currency', {
    currency: "0x20326e47ad027323af36b4c36bc03f163c718934bcfe5e4986a84abb67c575"
  });
  let result = await acc.execute([call]);
  console.log('Currency whitelisted: ', result.transaction_hash);
  console.log(result);
}

async function tokenizeCurrency(acc: Account) {
  const tokenManager = getContracts().contracts["TokenManager"];
  const provider = getProvider();
  const cls = await provider.getClassAt(tokenManager);
  const token_manager = new Contract(cls.abi, tokenManager, provider);
  const call = token_manager.populate('tokenize', {
    currency: "0x1774290639912d741e14f18acd4d852318144f41eb18246a1dfe219d3cee6ae",
    user: getContracts().contracts["LiquidityPool"],
    amount: "1000000000000000000000000000"
  });
  let result = await acc.execute([call]);
  console.log('Tokenized: ', result.transaction_hash);
}

async function transferCurrency(acc: Account) {
  const sgdr = getContracts().contracts["SGD"];
  const provider = getProvider();
  const cls = await provider.getClassAt(sgdr);
  const sgdr_contract = new Contract(cls.abi, sgdr, provider);
  const call = sgdr_contract.populate('transfer', {
    recipient: getContracts().contracts["LiquidityPool"],
    amount: BigInt("1000000000000000000000000000")
  });
  let result = await acc.execute([call]);
  console.log('Transferred: ', result.transaction_hash);
  console.log(result);
}

async function getBalance(acc: Account) {
  const sgdr = getContracts().contracts["SGD"];
  const provider = getProvider();
  const cls = await provider.getClassAt(sgdr);
  const sgdr_contract = new Contract(cls.abi, sgdr, provider);
  const call = sgdr_contract.populate('get_balance', {
    user: getContracts().contracts["LiquidityPool"]
  });
  let result = await acc.execute([call]);
  console.log('Transferred: ', result.transaction_hash);
  console.log(result);
}


async function setExchangeRate(acc: Account) {
  const liquidityPool = getContracts().contracts["LiquidityPool"];
  const provider = getProvider();
  const cls = await provider.getClassAt(liquidityPool);
  const liquidity_pool = new Contract(cls.abi, liquidityPool, provider);
  const call = liquidity_pool.populate('set_exchange_rate', {
    exchange_rate: 1000000
  });
  let result = await acc.execute([call]);
  console.log('Exchange rate set: ', result.transaction_hash);
  console.log(result);
}




async function main() {
  const acc = getAccount();
  await deployFinternetId(acc);
  await deployKycRegistry(acc);
  // await deployLiquidityPool(acc);
  // await deployTokenManager(acc);
  // await deployTokenizedCurrency(acc);
  // await approveKyc(acc);
  // await registerTokenManager(acc);
  // await whitelistCurrency(acc);
  // await tokenizeCurrency(acc);
  // await transferCurrency(acc);
  // await getBalance(acc);
  // await setExchangeRate(acc);
}

main();
