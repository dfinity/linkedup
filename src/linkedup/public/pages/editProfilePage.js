import LinkedUp from "ic:canisters/linkedup";
import { render, renderAll, show } from "../utils";
import header from "../templates/header";
import footer from "../templates/footer";
import loading from "../templates/loading";
import editProfile from "../templates/editProfile";
import { navigateTo } from "../router";
import "../styles/editProfilePage.css";

const editProfilePage = async () => {
  renderAll({
    "#header": header({ page: "editProfilePage" }),
    "#editProfile": loading(),
    "#footer": footer(),
  });
  show("#editProfile");

  let profile;
  try {
    const ownId = await LinkedUp.getOwnId();
    profile = await LinkedUp.get(ownId);
  } catch (e) {
    profile = {};
  }
  render("#editProfile", editProfile({ profile }));

  document
    .querySelector("#editProfileForm")
    .addEventListener("submit", createOrUpdate(profile));
};

const createOrUpdate = (profile) => async (event) => {
  event.preventDefault();
  render("#editProfile", loading());

  const updatedProfile = {
    ...profile,
    ...Object.fromEntries(new FormData(event.target)),
  };
  if (profile.id) {
    await LinkedUp.update(updatedProfile);
  } else {
    await LinkedUp.create(updatedProfile);
  }
  navigateTo("#profile");
};

export default editProfilePage;
