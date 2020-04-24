import linkedup from "ic:canisters/linkedup";
import { idToString } from "./utils";

const createActions = (store) => ({
  init: () =>
    store.update({
      connections: {},
      isConnected: true,
      ownId: null,
      page: "landingPage",
      profile: {},
      results: [],
      showProfileId: null,
    }),

  connect: async () => {
    const { connections, ownId, profile, showProfileId } = store.getState();
    linkedup.connect(showProfileId);
    store.update({
      connections: {
        ...connections,
        [idToString(ownId)]: [...connections[idToString(ownId)], profile],
      },
    });
    window.actions.goProfile();
  },

  go: (page) => store.update({ page, results: [] }),

  goProfile: async (id) => {
    if (!id) {
      const ownId = await linkedup.getOwnId();
      const profile = await linkedup.get(ownId);
      id = ownId;
      if (profile.firstName === "") {
        store.update({ ownId, page: "editProfile", profile });
      } else {
        store.update({
          ownId,
          page: "showProfile",
          profile,
          showProfileId: ownId,
        });
      }
    } else {
      const profile = await linkedup.get(id);
      store.update({ page: "showProfile", profile, showProfileId: id });
    }
    window.actions.loadConnections(id);
  },

  loadConnections: async (id) => {
    Promise.all([linkedup.getConnections(id), linkedup.isConnected(id)]).then(
      ([connections, isConnected]) => {
        const state = store.getState();
        store.update({
          connections: { ...state.connections, [idToString(id)]: connections },
          isConnected,
        });
      }
    );
  },

  saveProfile: async (event) => {
    event.preventDefault();
    const profile = Object.fromEntries(new FormData(event.target));
    linkedup.create(profile);
    store.update({ profile });
    window.actions.goProfile();
  },

  search: async (event) => {
    const term = event.target.value;
    if (term.length > 2) {
      const results = await linkedup.search(term);
      store.update({ page: "searchResults", results });
    }
  },

  showConnection: (index) => {
    const { connections, showProfileId } = store.getState();
    window.actions.goProfile(connections[idToString(showProfileId)][index].id);
  },

  showResult: (index) => {
    const { results } = store.getState();
    window.actions.goProfile(results[index].id);
  },
});

export default createActions;
