import * as $ from 'jquery';
import { WOW } from 'wowjs';
import Typed from 'typed.js';
import 'bootstrap';

// Make the Profile app's public methods available locally
import profile from 'ic:canisters/profile';

import { ownProfilePageTmpl, profilePageTmpl, searchResultsPageTmpl } from './templates';
import { injectHtml } from './utils';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'animate.css/animate.min.css';
import './index.css';

window.$ = window.jQuery = $;

profile.__getAsset("index.html")
  .then(injectHtml)
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

  new Typed('#typed', {
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

  function clearAdminSections() {
    $('.profile').hide();
    $('.edit').hide();
    $('.search').hide();
    $('.connections').hide();
  };

  function renderOwnProfile() {
    clearAdminSections();
    (async function () {
      try {
        const [data] = await profile.getOwn();
        data.connections = [];
        $('.profile').html(ownProfilePageTmpl(data)).show();
        data.connections = await profile.getOwnConnections();
        $('.profile').html(ownProfilePageTmpl(data)).show();
      } catch (err) {
        console.error(err);
      }
    })();
  }

  function renderProfile(userId) {
    clearAdminSections();
    (async function () {
      try {
        let [data] = await profile.get(userId);
        data.connections = [];
        data.isConnected = true;
        $('.profile').html(profilePageTmpl(data)).show();
        Promise.all([
          profile.isConnected(userId),
          profile.getConnections(userId),
        ])
        .then(([isConnected, connections]) => {
          data.isConnected = isConnected;
          data.connections = connections;
          $('.profile').html(profilePageTmpl(data)).show();
        });
      } catch (err) {
        console.error(err);
      }
    })();
  };

  function renderEdit(userId) {
    clearAdminSections();
    $('.edit').show().find('#first-name').focus();

    (async function () {
      let result = {};
      if (userId) { [result] = await profile.get(userId); }
      updateForm(result);
    })();
  };

  function renderSearch(term) {
    clearAdminSections();

    (async function () {
      try {
        const [results] = await profile.search(term);
        $('.search').html(searchResultsPageTmpl(results)).show();
      } catch (err) {
        console.error(err);
      }
    })();
  };

  function renderConnections(userId) {
    clearAdminSections();
    $('.connections').show();

    (async function () {
      let connections = userId
        ? await profile.getConnections(userId)
        : await profile.getOwnConnections();
      let message;
      if (connections.length) {
        message = connections.map(profile => searchResultTmpl(profile));
      } else {
        message = "<div>You don't have any connections yet.";
      }
      $('.connections-list').html(message);
    })();
  };

  $('#edit-form').submit(function (event) {
    event.preventDefault();
    const button = $(this).find('button[type="submit"]');
    disableSubmitButton(button);

    const firstName = $(this).find('#first-name').val();
    const lastName = $(this).find('#last-name').val();
    const title = $(this).find('#title').val();
    const company = $(this).find('#company').val();
    const experience = $(this).find('#experience').val();
    const education = $(this).find('#education').val();
    const imgUrl = $(this).find('#imgUrl').val();

    async function action() {
      // Call Profile's public methods without an API
      const userId = await profile.create({
        firstName,
        lastName,
        title,
        company,
        experience,
        education,
        imgUrl,
      });
      renderOwnProfile();
      enableSubmitButton(button, 'Submit');
    }
    action();
  });


  $('a#edit').click(function () {
    renderEdit();
  });

  $('a#profile').click(function () {
    renderOwnProfile();
  });

  $('a#connections').click(function () {
    renderConnections();
  });

  $('a#login').click(function () {
    $('.splash-view').slideUp(0, 'linear');
    $('.admin-view').slideDown(250, 'linear');
    renderOwnProfile();
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

  const showEdit = () => {
    renderEdit();
  };

  const connectWith = userId => {
    try {
      profile.connect(parseInt(userId, 10));
      renderOwnProfile();
    } catch (err) {
      console.error(err);
    }
  };

  const showProfile = userId => {
    renderProfile(parseInt(userId, 10));
  };

  const search = () => {
    const searchInputEl = document.getElementById('search');
    renderSearch(searchInputEl.value);
  };

  window.actions = {
    connectWith,
    showProfile,
    search,
    showEdit,
  };

}));
