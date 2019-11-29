const HtmlWebpackPlugin = require('html-webpack-plugin');
const path = require("path");

const canisterRootMap = {
  "sss": path.join(__dirname, "src/hello"),
};

const outputRootMap = {
  "sss": path.join(__dirname, "canisters/hello"),
};

module.exports = [
  // Canister "sss".
  {
    mode: "production",
    entry: path.join(canisterRootMap["sss"], "public/hello.js"),
    resolve: {
      alias: {
        "canisters:hello": path.join(outputRootMap["sss"], "main.js"),
      },
    },
    output: {
      filename: "index.js",
      path: path.join(outputRootMap["sss"], "assets"),
    },
    plugins: [
      new HtmlWebpackPlugin({
        template: path.join(canisterRootMap["sss"], "public/index.html"),
        filename: path.join(outputRootMap["sss"], "assets/index.html"),
      }),
    ],
  },
];
