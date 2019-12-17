const path = require("path");

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
        "ic:userlib": "/home/developer/.cache/dfinity/versions/0.4.9-28-g3127c46/js-user-library/dist/lib.prod.js"
      }
    }
  }
];
