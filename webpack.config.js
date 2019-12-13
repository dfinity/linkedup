const path = require("path");

const sourceRootMap = {
  "profile": path.join(__dirname, "src"),
};

const targetRootMap = {
  "profile": path.join(__dirname, "build/profile"),
};

module.exports = [
  {
    mode: "production",
    entry: path.join(sourceRootMap["profile"], "preambles.js"),
    resolve: {
      alias: {
        "canisters:profile": path.join(targetRootMap["profile"], "profile.js")
      }
    },
    output: {
      filename: "index.js",
      path: sourceRootMap["profile"]
    }
  }
];

