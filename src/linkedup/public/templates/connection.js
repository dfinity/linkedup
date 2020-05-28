import "../styles/connection.css";

const connection = (profile) => `
  <a class="connection" href="#profile/${profile.id}">
    <img class="avatar" src="${profile.imgUrl}" />
    <h5>${profile.firstName} ${profile.lastName}</h5>
    <p><b>${profile.title}</b> at <b>${profile.company}</b></p>
  </a>
`;

export default connection;
