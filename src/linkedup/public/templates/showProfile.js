import { Converter } from "showdown";
import connection from "../templates/connection";
const converter = new Converter();

const showProfile = ({ ownId, profile }) => `
  <div>
    <h4>Profile</h4>
    <div id="profile" class="profile">
      <img class="avatar" src="${profile.imgUrl}" />
      <div class="details">
        <h1 class="name">${profile.firstName} ${profile.lastName}</h1>
        <p class="bio">${profile.title} at ${profile.company}</p>
      </div>
      <div class="experience">
        <h4>Experience</h4>
        <div>${converter.makeHtml(profile.experience)}</div>
      </div>
      <div class="education">
        <h4>Education</h4>
        <div>${converter.makeHtml(profile.education)}</div>
      </div>
      ${
        ownId === profile.id ? `<button href="#profile/edit">Edit</button>` : ""
      }
      ${
        ""
        // !isOwn && !isConnected
        // ? `<button onclick="actions.connect()">Connect</button>`
        // : ""
      }
    </div>
    <div id="connections">
      <h4>Connections</h4>
      ${
        ""
        // profileConnections && profileConnections.length
        // ? profileConnections.map(connection).join("")
        // : "No connections"
      }
    </div>
  </div>
`;

export default showProfile;
