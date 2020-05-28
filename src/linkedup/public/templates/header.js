import "../styles/header.css";

const header = ({ page }) => {
  const isSearchPage = page === "searchResults";
  const isLandingPage = page === "landingPage";
  return `
    <a class="logo" href="/">Linked<span>up</span></a>
    ${isSearchPage ? `<input id="search" type="search" />` : ""}
    <nav>
      <ul>
      ${
        isLandingPage
          ? `<li><a href="#profile">Login</a></li>`
          : `<li><a href="#profile">Profile</a></li>
             <li><a href="#search">Search</a></li>
             <li><a href="#profile">Connections</a></li>
             <li><a href="#profile">Invites</a></li>`
      }
      </ul>
    </nav>
  `;
};

export default header;
