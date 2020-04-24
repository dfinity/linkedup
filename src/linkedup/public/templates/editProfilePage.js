import "./editProfilePage.css";

const editProfilePage = ({ profile }) => `
  <h4>Editing Profile</h4>
  <form id="editProfileForm" onsubmit="actions.saveProfile(event)">
    ${formFields.map(fieldTmpl(profile)).join("")}
    <button type="submit">Save</button>
  </form>
`;

const fieldTmpl = (profile) => ({ label, name, type }) => `
  <p>
    <label for="${name}">${label}</label>
    ${
      type === "textarea"
        ? `<textarea name="${name}" id="${name}">${profile[name]}</textarea>`
        : `<input name="${name}" id="${name}" value="${profile[name]}" />`
    }
  </p>
`;

const formFields = [
  { name: "firstName", label: "First Name" },
  { name: "lastName", label: "Last Name" },
  { name: "title", label: "Title" },
  { name: "company", label: "Company" },
  { name: "experience", label: "Experience", type: "textarea" },
  { name: "education", label: "Education", type: "textarea" },
  { name: "imgUrl", label: "Image URL" },
];

export default editProfilePage;
