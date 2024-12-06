import *  as starknet from "starknet";

const OZ_ACCOUNT_CLASS_HASH = "0x01484c93b9d6cf61614d698ed069b3c6992c32549194fc3465258c2194734189";

function calculatePrefactualAccountAddress() {
  // new Open Zeppelin account v0.8.1
  // Generate public and private key pair.
  const privateKey = starknet.stark.randomAddress();
  console.log("Starknet private key:", privateKey);
  const starkKeyPub = starknet.ec.starkCurve.getStarkKey(privateKey);
  console.log("Starknet public key:", starkKeyPub);

  // Calculate future address of the account
  const OZaccountConstructorCallData = starknet.CallData.compile({
    publicKey: starkKeyPub,
  });
  const OZcontractAddress = starknet.hash.calculateContractAddressFromHash(
    starkKeyPub,
    OZ_ACCOUNT_CLASS_HASH,
    OZaccountConstructorCallData,
    0,
  );

  console.log("Starknet account address:", OZcontractAddress);
  return {
    address: OZcontractAddress,
    private_key: privateKey,
    public_key: starkKeyPub,
  };
}

calculatePrefactualAccountAddress();


