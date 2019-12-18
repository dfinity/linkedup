const fs = require('fs');
const path = require("path");

const versionsDir = path.join(process.env["HOME"], ".cache/dfinity/versions");
const versions = fs.readdirSync(
  path.join(process.env["HOME"], ".cache/dfinity/versions")
);
const specific = process.env["DFX_VERSION"];
const latest = versions.map(function (version) {
  const chunks = version.split('-');
  const prefix = chunks[0].split('.').map(s => parseInt(s));
  const suffix = chunks[1] == null ? 0 : parseInt(chunks[1]);
  return [prefix.concat(suffix).map(n => 1000000 + n).join(), version];
}).sort().slice(-1)[0][1];
const version = specific ? specific : latest;

const sourceDir = path.join(__dirname, "src");
const sourceRootMap = {
  "graph": path.join(sourceDir, "graph"),
  "index": path.join(sourceDir, "index"),
  "profile": path.join(sourceDir, "profile"),
};

const targetDir = path.join(__dirname, "build");
const targetRootMap = {
  "graph": path.join(targetDir, "graph"),
  "index": path.join(targetDir, "index"),
  "profile": path.join(targetDir, "profile")
};

module.exports = [
  {
    entry: path.join(sourceRootMap["index"], "main.js"),
    mode: "production",
    output: {
      filename: "index.js",
      path: sourceRootMap["index"]
    },
    resolve: {
      alias: {
        "ic:canister/graph": path.join(targetRootMap["graph"], "main.js"),
        "ic:canister/profile": path.join(targetRootMap["profile"], "main.js"),
        "ic:idl/graph": path.join(targetRootMap["graph"], "main.did.js"),
        "ic:idl/profile": path.join(targetRootMap["profile"], "main.did.js"),
        "ic:userlib": path.join(
          versionsDir,
          version ? version : latest,
          "js-user-library/dist/lib.prod.js",
        ),
      }
    }
  }
];
