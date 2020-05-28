const matchRoute = (routes) => ({ newURL }) => {
  const newRoute = newURL.split("#")[1] || "";
  for (let i = 0; i < Object.keys(routes).length; i++) {
    const key = Object.keys(routes)[i];
    const match = newRoute.match(new RegExp(key));
    if (match) {
      routes[key](match.slice(1));
      break;
    }
  }
};

export const createRouter = (routes = {}) => {
  const handleHashChange = matchRoute(routes);
  window.addEventListener("hashchange", handleHashChange);
  handleHashChange({ newURL: window.location.hash });
};

export const navigateTo = (hash) => (window.location.hash = hash);
