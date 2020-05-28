import { renderAll, show } from "../utils";
import header from "../templates/header";
import footer from "../templates/footer";
import "../styles/landingPage.css";

const landingPage = () => {
  renderAll({
    "#landingPage": `<p>An open professional network.</p>`,
    "#header": header({ page: "landingPage" }),
    "#footer": footer(),
  });
  show("#landingPage");
};

export default landingPage;
