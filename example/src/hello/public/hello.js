import hello from 'canisters:hello';

window.hello = async function(name) {
  const reply = await hello.greet(name);
  document.getElementById('output').innerText = reply;
};
