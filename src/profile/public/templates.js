const profileTemplate = model => `[PROFILE: ${model.firstName}]`;

const searchResultTmpl = model => `
  <div class="lu_search-result">
    <div class="lu_avatar">
      <img src="" />
    </div>
    <div class="lu_details">
      <h4 class="lu_details_header">${model.firstName} ${model.lastName}</h4>
      <p class="lu_details_body">${model.title} at ${model.company}</p>
    </div>
    <div class="lu_connect-button">
      <button onClick="actions.connectWith('${model.id}')">Connect</button>
    </div>
  </div>
`;

module.exports = { profileTemplate, searchResultTmpl };
