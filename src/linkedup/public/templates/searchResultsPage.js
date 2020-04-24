import "./searchResultsPage.css";

const searchResultsPage = ({ results }) => `
  <h4>Search Results</h4>
  <div class="searchResults">
    ${
      results && results.length
        ? results.map(searchResultTmpl).join("")
        : "No results"
    }
  </div>
`;

const searchResultTmpl = (profile, index) => `
  <a class="searchResult" onclick="actions.showResult(${index})">
  <img class="avatar" src="${profile.imgUrl}" />
  <h5>${profile.firstName} ${profile.lastName}</h5>
  <p><b>${profile.title}</b> at <b>${profile.company}</b></p>
</a>
`;

export default searchResultsPage;
