/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Directory "./directory.mo";
import Types "./types.mo";

type Profile = Types.Profile;
type PrincipalId = Types.PrincipalId;

actor Profile {
  var directory : Directory.Directory = Directory.Directory();

  public shared { caller } func set (profile : Profile) : async PrincipalId {
    let userId : PrincipalId = hashBlob(caller);
    directory.set(userId, profile);
    userId
  };

  public query func get (userId : PrincipalId) : async ?Profile {
    directory.get(userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.search(term)
  };
};
