import { Converter } from "showdown";
const converter = new Converter();
import { deepEquals, idToString } from "../utils";
import "./showProfilePage.css";

const showProfilePage = (state) => {
  const { connections, isConnected, ownId, profile } = state;
  const isOwn = !profile.id || deepEquals(ownId, profile.id);
  const profileConnections = connections[idToString(profile.id)];
  return `
    <div>
      <h4>Profile</h4>
      ${profileTmpl(profile)}
      ${
        isOwn ? `<button onclick="actions.go('editProfile')">Edit</button>` : ""
      }
      ${
        !isOwn && !isConnected
          ? `<button onclick="actions.connect()">Connect</button>`
          : ""
      }
    </div>
    <div>
      <h4>Connections</h4>
      ${
        profileConnections && profileConnections.length
          ? profileConnections.map(connectionTmpl).join("")
          : "No connections"
      }
    </div>
  `;
};

const profileTmpl = ({
  firstName,
  lastName,
  title,
  company,
  experience,
  education,
  imgUrl,
}) => `
  <div class="profile">
    <img class="avatar" src="${imgUrl}" />
    <div class="details">
      <h1 class="name">${firstName} ${lastName}</h1>
      <p class="bio">${title} at ${company}</p>
    </div>
    ${
      experience === ""
        ? ""
        : `
        <div class="experience">
          <h4>Experience</h4>
          <div>${converter.makeHtml(experience)}</div>
        </div>
      `
    }
    ${
      education === ""
        ? ""
        : `
      <div class="education">
        <h4>Education</h4>
        <div>${converter.makeHtml(education)}</div>
      </div>
    `
    }
  </div>
`;

const connectionTmpl = (profile, index) => `
  <a class="connection" onclick="actions.showConnection(${index})">
    <img class="avatar" src="${profile.imgUrl}" />
    <h5>${profile.firstName} ${profile.lastName}</h5>
    <p><b>${profile.title}</b> at <b>${profile.company}</b></p>
  </a>
`;

export default showProfilePage;
