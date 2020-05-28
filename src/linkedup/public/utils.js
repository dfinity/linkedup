export const injectHtml = (htmlBytes) => {
  const html = new TextDecoder().decode(htmlBytes);
  const el = new DOMParser().parseFromString(html, "text/html");
  document.body.replaceChild(
    el.firstElementChild,
    document.getElementById("app")
  );
};

export const render = (id, html) =>
  (document.querySelector(id).innerHTML = html);

export const renderAll = (elements) =>
  Object.entries(elements).forEach(([id, html]) => render(id, html));

export const show = (sectionId) =>
  document.querySelectorAll("section").forEach((section) => {
    if (section.id === sectionId.replace("#", "")) {
      section.classList.remove("hidden");
    } else {
      section.classList.add("hidden");
    }
  });
