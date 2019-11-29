import actorInterface from "/Users/hansl/Sources/temp/sss/canisters/hello/main.did.js";

import {
  generateKeyPair,
  makeActor,
  makeHttpAgent,
} from "/Users/hansl/.cache/dfinity/versions/0.4.8-local-debug/js-user-library";

const { publicKey, secretKey } = generateKeyPair();

const httpAgent = makeHttpAgent({
  canisterId: "a9df9ddcca952527",
  senderSecretKey: secretKey,
  senderPubKey: publicKey,
});

const actor = makeActor(actorInterface)(httpAgent);

export default actor;
