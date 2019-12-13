/**
 * File        : main.mo
 * Copyright   : 2019 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Experimental
 */

import Prelude "mo:stdlib/prelude.mo"

actor Profile {

    /**
     * Select the profile of a user.
     */
    public func profileSelect(
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * Insert or update the profile of a user.
     */
    public func profileUpsert(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        resume : Text
    ) : async Text {
        Prelude.unreachable()
    };

}
