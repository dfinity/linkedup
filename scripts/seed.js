const fetch = require("node-fetch");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { crc8 } = require("node-crc");
const { Crypto } = require("node-webcrypto-ossl");

global.crypto = new Crypto();

const config = require("../dfx.json");
const userLib = require(path.join(
  os.homedir(),
  "/.cache/dfinity/versions/",
  config.dfx,
  "/js-user-library/src"
));
const {
  generateKeyPair,
  HttpAgent,
  makeActorFactory,
  makeAuthTransform,
  makeNonceTransform,
} = userLib;

// Main

const main = async () => {
  console.log("Adding profiles...");
  const profiles = require("./data");
  profiles.forEach(async (profile) => {
    const linkedup = await getActor("linkedup");
    const userId = await linkedup.create(profile);
    console.log("...profile added", userId);
  });
};

// Helpers

const getActor = (
  canisterName,
  host = "http://localhost:8000",
  keypair = generateKeyPair()
) => {
  const candid = eval(getCandid(canisterName));
  const canisterId = getCanisterId(canisterName);
  const httpAgent = new HttpAgent({ fetch, host });
  httpAgent.addTransform(makeNonceTransform());
  httpAgent.addTransform(makeAuthTransform(keypair));
  return makeActorFactory(candid)({ canisterId, httpAgent });
};

const getCanisterPath = (canisterName) =>
  path.join(__dirname, "../canisters/", canisterName);

const getCandid = (canisterName) =>
  fs
    .readFileSync(`${getCanisterPath(canisterName)}/main.did.js`)
    .toString()
    .replace("export default ", "");

const getCanisterId = (canisterName) => {
  let id = fs.readFileSync(`${getCanisterPath(canisterName)}/_canister.id`);
  return `ic:${format(id)}${format(crc8(id))}`;
};

const format = (canisterId) => canisterId.toString("hex").toUpperCase();

// Run main()

main();
