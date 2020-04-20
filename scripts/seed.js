const fetch = require("node-fetch");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { crc8 } = require("node-crc");
const { Crypto } = require("node-webcrypto-ossl");

global.crypto = new Crypto();

const { defaults, dfx } = require("../dfx.json");
const DFX_VERSION = dfx;
const DEFAULT_HOST = `http://${defaults.start.address}:${defaults.start.port}`;
const OUTPUT_DIR = defaults.build.output;

const userLib = require(path.join(
  os.homedir(),
  "/.cache/dfinity/versions/",
  DFX_VERSION,
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
    await linkedup.create(profile);
    console.log("...profile added");
  });
};

// Helpers

const getActor = (
  canisterName,
  host = DEFAULT_HOST,
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
  path.join(__dirname, "..", OUTPUT_DIR, canisterName);

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
