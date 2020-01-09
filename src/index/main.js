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
			return str ? new Uint8Array(str.match(/.{1,2}/g).map(function (x) {
				return parseInt(x, 16)
			})) : null
		}

		function encode(bytes) {
			return bytes ? bytes.reduce(function (str, x) {
				return str + x.toString(16).padStart(2, '0')
			}, '') : null
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
		function enableSubmitButton(btn, phrase) {
			btn.empty();
			btn.append(phrase);
			btn.prop('disabled', false);
		};



		// Handle login form.
		var keyPair;

































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

		function renderProfile() {
			clearAdminSections();
			$('.profile').show();
			function display(id, value) {
				$('.profile').find(id).html(value);
			};
			async function action() {
				let publicKey = keyPair.publicKey;
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
				};
				$('.profile').find('#address').html(encode(publicKey));
				display('#first-name', sanitize(convert(result.firstName)));
				display('#last-name', sanitize(convert(result.lastName)));
				display('#title', sanitize(convert(result.title)));
				display('#company', sanitize(convert(result.company)));
				display('#experience', sanitize(convert(result.experience)).replace(/\n/g, '<br/>'));
			};
			action();
		};

		function renderEdit() {
			clearAdminSections();
			$('.edit').show().find('#first-name').focus();
			function display(id, value) {
				$('.edit').find(id).val(value);
			};
			async function action() {
				let publicKey = keyPair.publicKey;
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
				};
				$('.edit').find('#address').html(encode(publicKey));
				display('#first-name', convert(result.firstName));
				display('#last-name', convert(result.lastName));
				display('#title', convert(result.title));
				display('#company', convert(result.company));
				display('#experience', convert(result.experience));
			};
			action();
		};

		function renderSearch() {
			clearAdminSections();
			$('.search').show().find('#address').focus();
		};

		function renderConnections() {
			clearAdminSections();
			$('.connections').show();
			async function action() {
				let publicKey = keyPair.publicKey;
				var connections = await graph.connections1({
					'unbox': Array.from(publicKey)
				});
				var list = '';
				while (connections != null) {
					list += '<div class="form-group form-group-lg"><div class="input-group input-group-md"><form class="form-control input-group-prepend" id="profile-form" role="form"><input id="address" name="address" type="hidden" value="' + address + '"><button class="btn-profile" type="submit">' + address + '</button></form><form class="input-group-append" id="revoke-form" role="form"><input id="address" name="address" type="hidden" value="' + address + '"><button class="btn btn-md btn-revoke" type="submit">Revoke</button></form></div></div>';
					connections = connections[1];
				};
				$('.connections-list').html(list);
			};
			action();
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
				};
				$('.invitations-list').html(list);
			};
			action();
		};

		$(document).on('submit', '#search-form', function(event) {
			event.preventDefault();
			let address = $(this).find('#address').val();
			let button = $(this).find('button');
			disableSubmitButton(button);
			$('.search-result').hide();
			$('#connect-form').hide();
			async function action() {
				let publicKey = decode(address);
				let result = await profile.find({
					'unbox': Array.from(publicKey)
				});
				var message;
				if (result == null) {
					message = '<div><i class="fa fa-warning"></i> Profile not found!</div>';
				} else {
					message = '<div class="form-group form-group-lg"><label for="first-name">First Name</label><div class="form-control" id="first-name">' + sanitize(convert(result.firstName)) + '</div></div><div class="form-group form-group-lg"><label for="last-name">Last Name</label><div class="form-control" id="last-name">' + sanitize(convert(result.lastName)) + '</div></div><div class="form-group form-group-lg"><label for="title">Job Title</label><div class="form-control" id="title">' + sanitize(convert(result.title)) + '</div></div><div class="form-group form-group-lg"><label for="company">Company Name</label><div class="form-control" id="company">' + sanitize(convert(result.company)) + '</div></div><div class="form-group form-group-lg"><label for="experience">Work Experience</label><div class="form-control" style="height: auto; min-height: calc(1.5em + .75rem + 2px)" id="experience">' + sanitize(convert(result.experience)).replace(/\n/g, '<br/>') + '</div></div>';
					$('#connect-form').find('input').val(address);
					$('#connect-form').show();
				};
				$('.search-result').html(message).show();
				enableSubmitButton(button, 'Search');
			};
			action();
		});

		$(document).on('submit', '#connect-form', function(event) {
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

		$(document).on('submit', '#profile-form', function(event) {
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
				};
				$('.profile').find('#address').html(encode(publicKey));
				display('#first-name', sanitize(convert(result.firstName)));
				display('#last-name', sanitize(convert(result.lastName)));
				display('#title', sanitize(convert(result.title)));
				display('#company', sanitize(convert(result.company)));
				display('#experience', sanitize(convert(result.experience)).replace(/\n/g, '<br/>'));
			};
			action();
		});

		$(document).on('submit', '#accept-form', function(event) {
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

		$(document).on('submit', '#reject-form', function(event) {
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



















		$('#edit-form').submit(function(event) {
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
					renderProfile();
				} else {
					alert('Something went wrong! :(');
				}
				enableSubmitButton(button, 'Submit');
			};
			action();
		});



		$('a#edit').click(function() {
			renderEdit();
		});

		$('a#profile').click(function() {
			renderProfile();
		});

		$('a#connections').click(function() {
			renderConnections();
		});

		$('a#invitations').click(function() {
			renderInvitations();
		});

		$('a#search').click(function() {
			renderSearch();
		});

		$('a#logout').click(function() {
			location.reload();
		});




		$(document).on('submit', '#register-form', function(event) {
			event.preventDefault();
			const button = $(this).find('button[type="submit"]');
			disableSubmitButton(button);
			var word;
			for (var i = 0; i < 12; i++) {
				word = '#word-' + ('00' + i.toString()).slice(-2);
				$(word).val(words[i]);
			}
			$('#login-form').submit();
			enableSubmitButton(button, 'Complete');
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
				$('.splash-view').slideUp(0, 'linear');
				$('.admin-view').slideDown(250, 'linear');
				renderEdit();
			} catch (err) {
				const details = '<div><i class="fa fa-warning"></i> ' + err.toString() + '</div>';
				response.hide().html(details).slideDown(350, 'linear', function() {
					enableSubmitButton(button, 'Login');
				});
			}
		});

	});

	$(window).on("load", function(e) {
		$(".preloader-canvas").fadeOut(1000, "linear");
	});

})(jQuery);
