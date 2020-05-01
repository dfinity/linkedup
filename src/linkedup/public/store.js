const createStore = (initState = {}) => {
  let state = { ...initState };
  const listeners = [];
  const getState = () => state;
  const update = (change) => {
    state = { ...state, ...change };
    listeners.forEach((listener) => listener(state));
  };
  const subscribe = (callback) => listeners.push(callback);
  return { getState, subscribe, update };
};

export default createStore;
