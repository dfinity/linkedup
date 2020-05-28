import LinkedUp from "ic:canisters/linkedup";
import header from "../templates/header";
import footer from "../templates/footer";
import loading from "../templates/loading";
import showProfile from "../templates/showProfile";
import { navigateTo } from "../router";
import { render, renderAll, show } from "../utils";
import "../styles/showProfilePage.css";

const showProfilePage = async ([id]) => {
  renderAll({
    "#header": header({ page: "showProfilePage" }),
    "#showProfile": loading(),
    "#footer": footer(),
  });
  show("#showProfile");

  try {
    const ownId = await LinkedUp.getOwnId();
    const profile = await LinkedUp.get(id || ownId);
    console.log(ownId, profile);
    render("#showProfile", showProfile({ ownId, profile }));
  } catch (e) {
    navigateTo("#profile/edit");
  }
};

export default showProfilePage;
