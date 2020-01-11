import HashMap "mo:stdlib/hashMap.mo";
import Hash "mo:stdlib/hash.mo";

import types "./types.mo";

module {
	type PrincipalId = types.PrincipalId;
	type Profile = types.Profile;

	public class Directory () {
		func passthrough (hash : PrincipalId) : PrincipalId { hash };
		let hashMap = HashMap.HashMap<PrincipalId, Profile>(1, Hash.Hash.hashEq, passthrough);

		public func get(userId : PrincipalId) : ?Profile {
			hashMap.get(userId)
		};

		public func set(userId : PrincipalId, _profile : Profile) : () {
			let profile : Profile = {
				id = userId;
				firstName = _profile.firstName;
				lastName = _profile.lastName;
				title = _profile.title;
				company = _profile.company;
				experience = _profile.experience;
			};
			ignore hashMap.set(userId, profile);
		};

	};
};
