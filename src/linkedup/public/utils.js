export const injectHtml = (htmlBytes) => {
  const html = new TextDecoder().decode(htmlBytes);
  const el = new DOMParser().parseFromString(html, "text/html");
  document.body.replaceChild(
    el.firstElementChild,
    document.getElementById("app")
  );
};

export const updateById = (selector, text) =>
  (document.querySelector(selector).innerHTML = text);

export const showPage = (pageId) => {
  document.querySelectorAll("section").forEach((section) => {
    if (section.id === pageId) {
      section.classList.remove("hidden");
    } else {
      section.classList.add("hidden");
    }
  });
};

export const idToString = (id) => JSON.stringify(id);

export const deepEquals = (obj1, obj2) => idToString(obj1) === idToString(obj2);

export class Component {
  constructor(selector = "", template = () => {}) {
    this.selector = selector;
    this.template = template;
    this.state = {};
  }

  update(newState) {
    if (!deepEquals(this.state, newState)) {
      this.state = { ...newState };
      this.render();
    }
  }

  render() {
    updateById(this.selector, this.template(this.state));
  }
}
