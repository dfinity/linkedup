/**
 * File        : main.mo
 * Copyright   : 2019 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Experimental
 */

import Prelude "mo:stdlib/prelude.mo"

actor Graph {

    /**
     * Create a connection invitation.
     */
    public func invitationCreate(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * Revoke a connection invitation.
     */
    public func invitationRevoke(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * List all connection invitations.
     */
    public func invitationList(
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * Respond to a connection invitation.
     */
    public func invitationRespond(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        userId : [Word8],
        accept : Bool
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * List all connections.
     */
    public func connectionList(
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

    /**
     * Revoke a connection.
     */
    public func connectionRevoke(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        userId : [Word8]
    ) : async Text {
        Prelude.unreachable()
    };

}
