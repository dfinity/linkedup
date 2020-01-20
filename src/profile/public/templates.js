import { Converter } from 'showdown';
const converter = new Converter();

/**
 * Profile Page
 */

export const ownProfilePageTmpl = model => `
  <div class="lu_profile-page container">
    <div class="row">
      <div class="col-md-8">
        <h4 class="lu_section-header">Profile</h4>
        ${profileTmpl(model)}
        <button class="lu_button lu_edit-button" onclick="actions.showEdit()">Edit</button>
      </div>
      <div class="col-md-4">
        <h4 class="lu_section-header">Your Connections</h4>
        ${connectionsTmpl(model)}
      </div>
    </div>
  </div>
`;

export const profilePageTmpl = model => `
  <div class="lu_profile-page container">
    <div class="row">
      <div class="lu_main col-md-8">
        <h4 class="lu_section-header">Profile</h4>
        ${profileTmpl(model)}
        <button class="lu_button lu_connect-button" onclick="actions.connectWith('${model.id}')">Connect</button>
      </div>
      <div class="col-md-4">
        <h4 class="lu_section-header">${model.firstName}'s Connections</h4>
        ${connectionsTmpl(model)}
      </div>
    </div>
  </div>
`;

const profileTmpl = model => `
  <div class="lu_profile">
    <div class="lu_avatar"><img src="${model.imgUrl}" /></div>
    <div class="lu_details">
      <h3 class="lu_details_header">${model.firstName} ${model.lastName}</h3>
      <h4 class="lu_details_body">${model.title} at ${model.company}</h4>
    </div>
    <div class="lu_experience">
      <h4 class="lu_section-header">Experience</h4>
      <div>${converter.makeHtml(model.experience)}</div>
    </div>
    <div class="lu_education">
      <h4 class="lu_section-header">Education</h4>
      <div>${converter.makeHtml(model.education)}</div>
    </div>
  </div>
`;

const connectionsTmpl = model => model.connections.length
  ? model.connections.map(connectionTmpl).join('')
  : "No connections";

const connectionTmpl = model => `
  <a class="lu_connection" onclick="actions.showProfile('${model.id}')">
    <div class="lu_avatar"><img src="${model.imgUrl}" /></div>
    <div class="lu_details">
      <h5 class="lu_details_header">${model.firstName} ${model.lastName}</h5>
      <p class="lu_details_body"><b>${model.title}</b> at <b>${model.company}</b></p>
    </div>
  </a>
`;

/**
 * Search Results Page
 */

export const searchResultsPageTmpl = model => `
  <div class="lu_search-results-page container">
    <h4 class="lu_section-header">Search Results</h4>
    ${searchResultsTmpl(model)}
  </div>
`;

const searchResultsTmpl = model => model.length
  ? model.map(searchResultTmpl).join('')
  : "No results";

const searchResultTmpl = model => `
  <a class="lu_search-result" onclick="actions.showProfile('${model.id}')">
    <div class="lu_avatar"><img src="${model.imgUrl}" /></div>
    <div class="lu_details">
      <h4>${model.firstName} ${model.lastName}</h4>
      <p><b>${model.title}</b></p>
      <p>${model.company}</p>
    </div>
  </a>
`;
