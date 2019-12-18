import graph from 'ic:canister/graph';
import profile from 'ic:canister/profile';
import userlib from 'ic:userlib'

(function($) {

	$(document).ready(function() {

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
		$(window).resize(function() {
			renderNavbar();
		});

		// 
		function renderIntro() {
			const windowHeight = $(window).innerHeight();
			$('.intro').css('height', windowHeight);
		};
		renderIntro();
		$(window).resize(function() {
			renderIntro();
		});
		$('.intro').backstretch('https://enzohaussecker.s3-us-west-2.amazonaws.com/images/handshake.jpg');
		$('.backstretch > img').after('<span class="dim"></span>');

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
			return new Uint8Array(str.match(/.{1,2}/g).map(function (x) {
				return parseInt(x, 16)
			}))
		}

		function encode(bytes) {
			return bytes.reduce(function (str, x) {
				return str + x.toString(16).padStart(2, '0')
			}, '')
		}

		//
		var words = [];
		function resetPhrase() {
			var arr = new Uint8Array(16);
			window.crypto.getRandomValues(arr);
			words = key_to_english(encode(arr)).split(' ');
		}
		$('.dropdown').on('show.bs.dropdown', function() {
			resetPhrase();
			var accum = '';
			for (var i = 0; i < 4; i++) {
				accum = accum + '<div class="form-row">';
				for (var j = 0; j < 3; j++) {
					accum = accum + '<div class="col-lg-4 form-group form-group-lg"><div class="form-control">' + words[3 * i + j] + '</div></div>';
				}
				accum = accum + '</div>';
			}
			$('.mnemonic-seed').html(accum);
		});

		// Disable submit button.
		function disableSubmitButton(btn) {
			btn.prop('disabled', true);
			btn.empty();
			btn.append('<i class="fa fa-cog fa-spin"></i> Wait...');
		};

		// Enable submit button.
		function enableSubmitButton(btn) {
			btn.empty();
			btn.append('<i class="fa fa-retweet"></i> Try again');
			btn.prop('disabled', false);
		};



		// Handle login form.
		var keyPair;












		function renderProfileEdit() {
			$('.splash-view').slideUp(10, 'linear');
			$('.profile-view').slideUp(10, 'linear');
			$('.profile-edit').slideDown(10, 'linear');
			async function action() {
				var signer = keyPair.publicKey;
				var result = await profile.find({ "unbox": Array.from(signer) });
				if (result == null) {
					result = {
						"firstName": "",
						"lastName": "",
						"title": "",
						"company": "",
						"experience": ""
					};
				};
				$('.profile-edit').find('#first-name').val(result.firstName);
				$('.profile-edit').find('#last-name').val(result.lastName);
				$('.profile-edit').find('#title').val(result.title);
				$('.profile-edit').find('#company').val(result.company);
				$('.profile-edit').find('#experience').val(result.experience);
			};
			action();
		};

		function renderProfileView() {
			$('.splash-view').slideUp(10, 'linear');
			$('.profile-edit').slideUp(10, 'linear');
			$('.profile-view').slideDown(10, 'linear');
			async function action() {
				var signer = keyPair.publicKey;
				var result = await profile.find({ "unbox": Array.from(signer) });
				if (result == null) {
					result = {
						"firstName": "",
						"lastName": "",
						"title": "",
						"company": "",
						"experience": ""
					};
				};
				$('.profile-view').find('#address').html(encode(signer));
				$('.profile-view').find('#first-name').html(result.firstName);
				$('.profile-view').find('#last-name').html(result.lastName);
				$('.profile-view').find('#title').html(result.title);
				$('.profile-view').find('#company').html(result.company);
				$('.profile-view').find('#experience').html(result.experience.replace(/\n/g, "<br />"));
			};
			action();
		};

		$('#profile-edit-form').submit(function(event) {
			event.preventDefault();
			const button = $(this).find('button[type="submit"]');
			disableSubmitButton(button);
			const encoder = new TextEncoder();
			const nonce = new Uint8Array(8);
			const messageType = new Uint8Array([1]);
			const firstName = encoder.encode($(this).find('#first-name').val());
			const firstNameLen = firstName.length;
			const lastName = encoder.encode($(this).find('#last-name').val());
			const lastNameLen = lastName.length;
			const title = encoder.encode($(this).find('#title').val());
			const titleLen = title.length;
			const company = encoder.encode($(this).find('#company').val());
			const companyLen = company.length;
			const experience = encoder.encode($(this).find('#experience').val());
			const experienceLen = experience.length;
			var message = new Uint8Array(15 + firstNameLen + lastNameLen + titleLen + companyLen + experienceLen);
			message.set(nonce);
			message.set(messageType, 8);
			message.set(new Uint8Array([firstNameLen]), 9);
			message.set(firstName, 10);
			message.set(new Uint8Array([lastNameLen]), 10 + firstNameLen);
			message.set(lastName, 11 + firstNameLen);
			message.set(new Uint8Array([titleLen]), 11 + firstNameLen + lastNameLen);
			message.set(title, 12 + firstNameLen + lastNameLen);
			message.set(new Uint8Array([companyLen]), 12 + firstNameLen + lastNameLen + titleLen);
			message.set(company, 13 + firstNameLen + lastNameLen + titleLen);
			console.log(experienceLen);
			message.set(new Uint8Array([experienceLen / 256]), 13 + firstNameLen + lastNameLen + titleLen + companyLen);
			message.set(new Uint8Array([experienceLen % 256]), 14 + firstNameLen + lastNameLen + titleLen + companyLen);
			message.set(experience, 15 + firstNameLen + lastNameLen + titleLen + companyLen);
			const signature = nacl.sign(message, keyPair.secretKey);
			const signer = keyPair.publicKey;
			async function action() {
				const success = await profile.run(Array.from(signer), Array.from(signature), Array.from(message));
				if (success) {
					renderProfileView();
				} else {
					alert('Something went wrong! :(');
				}
				enableSubmitButton(button);
			};
			action();
		});

		$('a#edit').click(function() {
			renderProfileEdit();
		});

		$('a#view').click(function() {
			renderProfileView();
		});

		$('a#logout').click(function() {
			location.reload();
		});

		$('#register-form').submit(function(event) {
			event.preventDefault();
			const button = $(this).find('button[type="submit"]');
			disableSubmitButton(button);
			var word;
			for (var i = 0; i < 12; i++) {
				word = '#word-' + ('00' + i.toString()).slice(-2);
				$(word).val(words[i]);
			}
			$('#login').click();
			enableSubmitButton(button);
		});

		$('#login-form').submit(function(event) {
			event.preventDefault();
			const button = $(this).find('button[type="submit"]');
			disableSubmitButton(button);
			const response = $(this).find('.response');
			var word;
			var words = [];
			for (var i = 0; i < 12; i++) {
				word = '#word-' + ('00' + i.toString()).slice(-2);
				words.push($(word).val());
			}
			try {
				var seed = new Uint8Array(32);
				seed.set(decode(english_to_key(words.join(' ').toUpperCase())));
				keyPair = nacl.sign.keyPair.fromSeed(seed);
				renderProfileView();
			} catch (err) {
				const details = '<div><i class="fa fa-warning"></i> ' + err.toString() + '</div>';
				response.hide().html(details).slideDown(350, 'linear', function() {
					enableSubmitButton(button);
				});
			}
		});

	});

	$(window).on("load", function(e) {
		$(".preloader-canvas").fadeOut(1000, "linear");
	});

})(jQuery);
