import { Component, showPage, deepEquals } from "../utils";
import header from "./header";
import landingPage from "./landingPage";
import showProfilePage from "./showProfilePage";
import editProfilePage from "./editProfilePage";
import searchResultsPage from "./searchResultsPage";
import footer from "./footer";
import "./app.css";

class App extends Component {
  constructor() {
    super();
    this.header = new Component("#header", header);
    this.landingPage = new Component("#landingPage", landingPage);
    this.showProfilePage = new Component("#showProfile", showProfilePage);
    this.editProfilePage = new Component("#editProfile", editProfilePage);
    this.searchResultsPage = new Component("#searchResults", searchResultsPage);
    this.footer = new Component("#footer", footer);
  }
  render() {
    const {
      connections,
      isConnected,
      ownId,
      page,
      profile,
      results,
    } = this.state;

    this.header.update({ page });
    this.landingPage.update();
    this.showProfilePage.update({ connections, isConnected, ownId, profile });
    this.editProfilePage.update({ profile });
    this.searchResultsPage.update({ results });
    this.footer.update();

    showPage(page);
  }
}

export default App;
