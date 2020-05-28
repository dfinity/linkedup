// Make the LinkedUp app's public methods available locally
import linkedup from "ic:canisters/linkedup";

import { injectHtml } from "./utils";
import { createRouter, navigateTo } from "./router";
import landingPage from "./pages/landingPage";
import showProfilePage from "./pages/showProfilePage";
import editProfilePage from "./pages/editProfilePage";
import "./main.css";

const routes = {
  "^profile/([0-9]+)": showProfilePage,
  "^profile/edit": editProfilePage,
  "^profile": showProfilePage,
  "": landingPage,
};

linkedup
  .__getAsset("index.html")
  .then(injectHtml)
  .then(() => {
    createRouter(routes);
    navigateTo("");
  });
