// Make the LinkedUp app's public methods available locally
import linkedup from "ic:canisters/linkedup";

import App from "./templates/App";
import createActions from "./actions";
import createStore from "./store";
import { injectHtml } from "./utils";

linkedup
  .__getAsset("index.html")
  .then(injectHtml)
  .then(() => {
    const store = createStore();
    store.subscribe(console.log); //debugging

    const app = new App();
    store.subscribe(app.update.bind(app));

    window.actions = createActions(store);
    actions.init();
  });
