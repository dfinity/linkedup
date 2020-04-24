import "./header.css";

const header = ({ page }) => `
  <a class="logo" href="/">Linked<span>up</span></a>
  ${
    page === "searchResults"
      ? `<input id="search" type="search" onkeyup="actions.search(event)" />`
      : ""
  }
  <nav>
    <ul>
    ${
      page === "landingPage"
        ? navTmpl({ action: "goProfile()", label: "Login" })
        : navItems.map(navTmpl).join("")
    }
    </ul>
  </nav>
`;

const navTmpl = ({ action, label }) =>
  `<li><a onclick="actions.${action}">${label}</a></li>`;

const navItems = [
  { action: "goProfile()", label: "Profile" },
  { action: "go('searchResults')", label: "Search" },
  { action: "goProfile()", label: "Connections" },
  { action: "goProfile()", label: "Invites" },
];

export default header;
