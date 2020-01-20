import * as $ from 'jquery';
import * as nacl from 'tweetnacl';
import { WOW } from 'wowjs';
import Typed from 'typed.js';
import 'bootstrap';

import graph from 'ic:canisters/graph';
import profile from 'ic:canisters/profile';

import { profileTemplate, searchResultTmpl } from './templates';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'animate.css/animate.min.css';
// import 'font-awesome/css/font-awesome.min.css';
import './index.css';

window.$ = window.jQuery = $;

profile.__getAsset("index.html")
  .then(htmlBytes => {
    // Replace the app tag with HTML from index.html.
    const html = new TextDecoder().decode(htmlBytes);
    const el = new DOMParser().parseFromString(html, "text/html");
    document.body.replaceChild(el.firstElementChild, document.getElementById('app'));
  })
  .then(() => $(document).ready(function() {
  // Reveal animations.
  const wow = new WOW();
  wow.init();

  //
  function renderNavbar() {
    const navbar = $('.navbar-custom');
    if (navbar.width() < 576) {
      navbar.addClass('collapse-custom');
    } else {
      navbar.removeClass('collapse-custom');
    }
  }

  renderNavbar();
  $(window).resize(function () {
    renderNavbar();
  });

  //
  function renderIntro() {
    const windowHeight = $(window).innerHeight();
    $('.intro').css('height', windowHeight);
  };
  renderIntro();
  $(window).resize(function () {
    renderIntro();
  });

  //
  const typed = new Typed('#typed', {
    cursorChar: '_',
    strings: [
      'n&nbsp;autonomous',
      '&nbsp;transparent',
      'n&nbsp;unstoppable',
      '&nbsp;tamperproof'
    ],
    typeSpeed: 50,
    backSpeed: 25,
    backDelay: 3000,
    loop: true
  });

  function decode(str) {
    return str ? new Uint8Array(str.match(/.{1,2}/g).map(function (x) {
      return parseInt(x, 16)
    })) : null
  }

  function encode(bytes) {
    return bytes ? bytes.reduce(function (str, x) {
      return str + x.toString(16).padStart(2, '0')
    }, '') : null
  }

  // Disable submit button.
  function disableSubmitButton(btn) {
    btn.prop('disabled', true);
    btn.empty();
    btn.append('<i class="fa fa-cog fa-spin"></i> Wait...');
  };

  // Enable submit button.
  function enableSubmitButton(btn, phrase) {
    btn.empty();
    btn.append(phrase);
    btn.prop('disabled', false);
  };


  // Handle login form.
  var keyPair = JSON.parse(localStorage.getItem('dfinity-ic-user-identity'));


  function convert(value) {
    let decoder = new TextDecoder();
    return decoder.decode(new Uint8Array(value));
  };

  function sanitize(value) {
    return value.replace(/</g, '&lt;').replace(/>/g, '&gt;');
  };

  function clearSplashView() {
    $('.splash-view').hide();
  };

  function clearAdminView() {
    $('.admin-view').hide();
  };

  function clearAdminSections() {
    $('.profile').hide();
    $('.edit').hide();
    $('.search').hide();
    $('.connections').hide();
    $('.invitations').hide();
  };

  function renderProfile(userId) {
    clearAdminSections();
    $('.profile').show();

    (async function () {
      let result = {};
      if (userId) { [result] = await profile.get(userId); }
      updateForm(result);
    })();
  };

  function renderOwn() {
    clearAdminSections();
    $('.profile').show();

    (async function () {
      const [result] = await profile.getOwn();
      updateForm(result);
    })();
  }

  function renderEdit(userId) {
    clearAdminSections();
    $('.edit').show().find('#first-name').focus();

    (async function () {
      let result = {};
      if (userId) { [result] = await profile.get(userId); }
      updateForm(result);
    })();
  };

  function renderSearch() {
    clearAdminSections();
    $('.search').show().find('#address').focus();
  };

  function renderConnections(userId) {
    clearAdminSections();
    $('.connections').show();

    (async function () {
      let connections;
      let message;
      if (userId) {
        connections = await profile.getConnections(userId);
      } else {
        connections = await profile.getOwnConnections();
      }
      console.log(connections);
      if (connections.length) {
        message = connections.map(profile => searchResultTmpl(profile));
      } else {
        message = "<div>You don't have any connections yet.";
      }
      $('.connections-list').html(message);
    })();
  };

  function renderInvitations() {
    clearAdminSections();
    $('.invitations').show();

    async function action() {
      let publicKey = keyPair.publicKey;
      var invitations = await graph.invitations({
        'unbox': Array.from(publicKey)
      });
      var list = '';
      while (invitations != null) {
        let address = encode(invitations[0].unbox);
        list += '<div class="form-group form-group-lg"><div class="input-group input-group-md"><form class="form-control input-group-prepend" id="profile-form" role="form"><input id="address" name="address" type="hidden" value="' + address + '"><button class="btn-profile" type="submit">' + address + '</button></form><form class="input-group-append" id="accept-form" role="form"><input id="address" name="address" type="hidden" value="' + address + '"><button class="btn btn-md btn-accept" type="submit">Accept</button></form><form class="input-group-append" id="reject-form" role="form"><input id="address" name="address" type="hidden" value="' + address + '"><button class="btn btn-md btn-reject" type="submit">Reject</button></form></div></div>';
        invitations = invitations[1];
      }
      ;
      $('.invitations-list').html(list);
    };
    action();
  };

  $(document).on('submit', '#search-form', function (event) {
    event.preventDefault();
    let term = $(this).find('#address').val();
    let button = $(this).find('button');
    disableSubmitButton(button);
    $('.search-result').hide();
    $('#connect-form').hide();

    (async function () {
      let [profiles] = await profile.search(term);
      console.log(profiles);
      let message;
      if (profiles.length) {
        message = profiles.map(profile => searchResultTmpl(profile));
      } else {
        message = '<div><i class="fa fa-warning"></i> Profile not found!</div>';
      }
      $('.search-result').html(message).show();
      enableSubmitButton(button, 'Search');
    })();
  });

  $(document).on('submit', '#connect-form', function (event) {
    event.preventDefault();
    let address = $(this).find('#address').val();
    let button = $(this).find('button');
    disableSubmitButton(button);

    async function action() {
      let nonce = new Uint8Array(8);
      let messageType = new Uint8Array([3]);
      let publicKey = decode(address);
      var message = new Uint8Array(41);
      message.set(nonce);
      message.set(messageType, 8);
      message.set(publicKey, 9);
      let signature = nacl.sign(message, keyPair.secretKey);
      let signer = keyPair.publicKey;
      let result = await graph.run(
        Array.from(signer),
        Array.from(signature),
        Array.from(message)
      );
      alert(result.message);
      enableSubmitButton(button, 'Connect');
    };
    action();
  });

  $(document).on('submit', '#profile-form', function (event) {
    event.preventDefault();
    let address = $(this).find('#address').val();
    clearAdminSections();
    $('.profile').show();

    function display(id, value) {
      $('.profile').find(id).html(value);
    };

    async function action() {
      let publicKey = decode(address);
      var result = await profile.find({
        'unbox': Array.from(publicKey)
      });
      if (result == null) {
        result = {
          'firstName': [],
          'lastName': [],
          'title': [],
          'company': [],
          'experience': []
        };
      }
      ;
      $('.profile').find('#address').html(encode(publicKey));
      display('#first-name', sanitize(convert(result.firstName)));
      display('#last-name', sanitize(convert(result.lastName)));
      display('#title', sanitize(convert(result.title)));
      display('#company', sanitize(convert(result.company)));
      display('#experience', sanitize(convert(result.experience)).replace(/\n/g, '<br/>'));
    };
    action();
  });

  $(document).on('submit', '#accept-form', function (event) {
    event.preventDefault();
    let address = $(this).find('#address').val();
    let button = $(this).find('button');
    disableSubmitButton(button);

    async function action() {
      let nonce = new Uint8Array(8);
      let messageType = new Uint8Array([5]);
      let publicKey = decode(address);
      let test = new Uint8Array([1]);
      var message = new Uint8Array(42);
      message.set(nonce);
      message.set(messageType, 8);
      message.set(publicKey, 9);
      message.set(test, 41);
      let signature = nacl.sign(message, keyPair.secretKey);
      let signer = keyPair.publicKey;
      let result = await graph.run(
        Array.from(signer),
        Array.from(signature),
        Array.from(message)
      );
      alert(result.message);
      renderInvitations();
    };
    action();
  });

  $(document).on('submit', '#reject-form', function (event) {
    event.preventDefault();
    let address = $(this).find('#address').val();
    let button = $(this).find('button');
    disableSubmitButton(button);

    async function action() {
      let nonce = new Uint8Array(8);
      let messageType = new Uint8Array([5]);
      let publicKey = decode(address);
      let test = new Uint8Array([0]);
      var message = new Uint8Array(42);
      message.set(nonce);
      message.set(messageType, 8);
      message.set(publicKey, 9);
      message.set(test, 41);
      let signature = nacl.sign(message, keyPair.secretKey);
      let signer = keyPair.publicKey;
      let result = await graph.run(
        Array.from(signer),
        Array.from(signature),
        Array.from(message)
      );
      alert(result.message);
      renderInvitations();
    };
    action();
  });

  $(document).on('submit', '#revoke-form', function (event) {
    event.preventDefault();
    let address = $(this).find('#address').val();
    let button = $(this).find('button');
    disableSubmitButton(button);

    async function action() {
      let nonce = new Uint8Array(8);
      let messageType = new Uint8Array([6]);
      let publicKey = decode(address);
      var message = new Uint8Array(41);
      message.set(nonce);
      message.set(messageType, 8);
      message.set(publicKey, 9);
      let signature = nacl.sign(message, keyPair.secretKey);
      let signer = keyPair.publicKey;
      let result = await graph.run(
        Array.from(signer),
        Array.from(signature),
        Array.from(message)
      );
      alert(result.message);
      renderConnections();
    };
    action();
  });

  $('#edit-form').submit(function (event) {
    event.preventDefault();
    const button = $(this).find('button[type="submit"]');
    disableSubmitButton(button);

    const firstName = $(this).find('#first-name').val();
    const lastName = $(this).find('#last-name').val();
    const title = $(this).find('#title').val();
    const company = $(this).find('#company').val();
    const experience = $(this).find('#experience').val();

    async function action() {
      const userId = await profile.create({
        firstName,
        lastName,
        title,
        company,
        experience
      });
      renderProfile(userId);
      enableSubmitButton(button, 'Submit');
    }
    action();
  });


  $('a#edit').click(function () {
    renderEdit();
  });

  $('a#profile').click(function () {
    renderOwn();
  });

  $('a#connections').click(function () {
    renderConnections();
  });

  $('a#invitations').click(function () {
    renderInvitations();
  });

  $('a#search').click(function () {
    renderSearch();
  });

  $('a#logout').click(function () {
    location.reload();
  });

  $('a#login').click(function () {
    $('.splash-view').slideUp(0, 'linear');
    $('.admin-view').slideDown(250, 'linear');
    renderOwn();
  });

  $(".preloader-canvas").fadeOut(1000, "linear");

  const updateById = (selector, text) =>
    document.querySelector(selector).innerHTML = text;

  const updateForm = model => {
    const { id, firstName, lastName, title, company, experience } = model;
    updateById('#address', id);
    updateById('#first-name', firstName);
    updateById('#last-name', lastName);
    updateById('#title', title);
    updateById('#company', company);
    updateById('#experience', experience);
  };

  // Actions

  const connectWith = userId => {
    try { profile.connect(parseInt(userId, 10)); }
    catch (err) { console.error(err); }
  };

  window.actions = {
    connectWith
  };

}));
