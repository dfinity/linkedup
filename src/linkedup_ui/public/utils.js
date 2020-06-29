export const injectHtml = htmlBytes => {
    const html = new TextDecoder().decode(htmlBytes);
    const el = new DOMParser().parseFromString(html, "text/html");
    document.body.replaceChild(el.firstElementChild, document.getElementById('app'));
};
