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

		// 
		function hexEncode(buf) {
			const arr = new Uint8Array(buf);
			return Array.prototype.map.call(arr, i =>
				('00' + i.toString(16)).slice(-2)
			).join('');
		}

		//
		var words = [];
		function resetPhrase() {
			var arr = new Uint8Array(16);
			window.crypto.getRandomValues(arr);
			words = key_to_english(hexEncode(arr)).split(' ');
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

		const decode = hexString =>
			new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));

		const encode = bytes =>
			bytes.reduce((str, byte) => str + byte.toString(16).padStart(2, '0'), '');

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

		// Handle registration form.
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

		// Handle login form.
		var keyPair;
		$('#login-form').submit(function(event) {
			event.preventDefault();
			const button = $(this).find('button[type="submit"]');
			disableSubmitButton(button);
			const response = $(this).find('.response');
			var words = [];
			for (var i = 0; i < 12; i++) {
				word = '#word-' + ('00' + i.toString()).slice(-2);
				words.push($(word).val());
			}
			try {
				var seed = new Uint8Array(32);
				seed.set(decode(english_to_key(words.join(' ').toUpperCase())));
				keyPair = nacl.sign.keyPair.fromSeed(seed);
				// TODO: Fetch profile.
				alert(encode(keyPair.publicKey));
				enableSubmitButton(button);
			} catch (err) {
				response.hide().html('<div><i class="fa fa-warning"></i> ' + err.toString() + '</div>').slideDown(350, 'linear', function() {
					enableSubmitButton(button);
				});
			}
		});

	});

	$(window).on("load", function(e) {
		// Remove preloader overlay.
		$(".preloader-canvas").fadeOut(1000, "linear");
	});

})(jQuery);
