import { Converter } from 'showdown';
const converter = new Converter();

/**
 * Profile Page
 */

export const ownProfilePageTmpl = data => `
  <div class="lu_profile-page container">
    <div class="row">
      <div class="col-md-8">
        <h4 class="lu_section-header">Profile</h4>
        ${profileTmpl(data)}
        <button class="lu_button lu_edit-button" onclick="actions.showEdit()">Edit</button>
      </div>
      <div class="col-md-4">
        <h4 class="lu_section-header">Your Connections</h4>
        ${connectionsTmpl(data)}
      </div>
    </div>
  </div>
`;

export const profilePageTmpl = data => `
  <div class="lu_profile-page container">
    <div class="row">
      <div class="lu_main col-md-8">
        <h4 class="lu_section-header">Profile</h4>
        ${profileTmpl(data)}
        ${data.isConnected
          ? ""
          : `<button class="lu_button lu_connect-button" onclick="actions.connectWith('${data.id}')">Connect</button>`
        }
      </div>
      <div class="col-md-4">
        <h4 class="lu_section-header">${data.firstName}'s Connections</h4>
        ${connectionsTmpl(data)}
      </div>
    </div>
  </div>
`;

const profileTmpl = data => `
  <div class="lu_profile">
    <div class="lu_avatar"><img src="${data.imgUrl}" /></div>
    <div class="lu_details">
      <h3 class="lu_details_header">${data.firstName} ${data.lastName}</h3>
      <h4 class="lu_details_body">${data.title} at ${data.company}</h4>
    </div>
    ${data.experience === ""
      ? ""
      : `
        <div class="lu_experience">
          <h4 class="lu_section-header">Experience</h4>
          <div>${converter.makeHtml(data.experience)}</div>
        </div>
      `}
      ${data.education === ""
      ? ""
      : `
        <div class="lu_education">
          <h4 class="lu_section-header">Education</h4>
          <div>${converter.makeHtml(data.education)}</div>
        </div>
      `}
  </div>
`;

const connectionsTmpl = data => data.connections.length
  ? data.connections.map(connectionTmpl).join('')
  : "No connections";

const connectionTmpl = data => `
  <a class="lu_connection" onclick="actions.showProfile('${data.id}')">
    <div class="lu_avatar"><img src="${data.imgUrl}" /></div>
    <div class="lu_details">
      <h5 class="lu_details_header">${data.firstName} ${data.lastName}</h5>
      <p class="lu_details_body"><b>${data.title}</b> at <b>${data.company}</b></p>
    </div>
  </a>
`;

/**
 * Search Results Page
 */

export const searchResultsPageTmpl = data => `
  <div class="lu_search-results-page container">
    <h4 class="lu_section-header">Search Results</h4>
    ${searchResultsTmpl(data)}
  </div>
`;

const searchResultsTmpl = data => data.length
  ? data.map(searchResultTmpl).join('')
  : "No results";

const searchResultTmpl = data => `
  <a class="lu_search-result" onclick="actions.showProfile('${data.id}')">
    <div class="lu_avatar"><img src="${data.imgUrl}" /></div>
    <div class="lu_details">
      <h4>${data.firstName} ${data.lastName}</h4>
      <p><b>${data.title}</b></p>
      <p>${data.company}</p>
    </div>
  </a>
`;
