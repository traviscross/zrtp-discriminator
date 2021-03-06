Discriminator Mode for ZRTP
===========================

When designing a secure phone, we want not just the traditional CIA
triad -- confidentiality, integrity, and availability -- we want
software that is convenient and easy to use.  We want a user interface
that imposes itself as little as possible on the user.

Creating and maintaining a tight security association can fail in
myriad ways, however, and many of those ways may suggest the presence
of an attacker.  It seems natural that we should communicate this to
the user.  But we risk creating confusion, warning fatigue, or even
playing into a sophisticated social engineering plot.

In this memo we discuss another way.  Rather than focusing on the
user, we focus on the attacker and his options and incentives.

For example, an attacker capable of even attempting a
man-in-the-middle (MitM) attack is, by definition, also capable of
performing a denial of service (DoS) attack.  We cannot deny the
attacker this, so we should embrace it.  If we make it so any
manipulation the attacker performs leads to denial of service, then we
have reduced the attacker to an outcome he can effect anyway.  He
either allows the call to pass unmolested, or he chooses to deny
service.

Using this insight, we can carefully design behaviors that preserve
security without burdening the user.  We'll first discuss our mental
model for a secure phone then discuss security exceptions and how the
software should respond.

Mental Security Model
---------------------

The mental model users need to internalize is simple: if the call is
Not Secure then verify the short authentication string (SAS) and
inform the software of the outcome.  If the SAS does not match, you
are being attacked.  You are always speaking securely with
authenticated servers.  Only when the software says the call is Secure
is it really secure.

In this model there are only two states: Secure and Not Secure.

Secure means the call is end-to-end secure.  This is the highest
security level.

Not Secure simply means the call is other than Secure; it is at best
secure only if the server can be trusted ("trusted-server secure").
This is our security baseline.  If we can't create a secure connection
with the server the call will not complete at all.

A call will be Secure only when there are no security exceptions and
either the local user has verified the SAS on the current call or both
users have verified the SAS on a previous call.

DoS Security Exceptions
-----------------------

To preserve security without communicating details to the user, we
will transform certain unexpected security exceptions into a denial of
service to deny the attacker the ability to manipulate the service
without blocking it completely.

If we cannot connect to the server via TLS with an appropriate cipher
suite, or we cannot authenticate the server's TLS certificate, we must
drop the call.

If the server does not offer or answer with only secure media, or we
would offer or answer with other than only secure media, we must drop
the call.

If we would send RTP rather than SRTP for any reason, we must drop the
call.  If we receive RTP rather than SRTP we must silently discard the
packets.

If we would send a ZRTP packet not tunneled in SRTP, we must drop the
call.  If we receive a ZRTP packet not tunneled in SRTP it must be
silently discarded.

If we receive or would send a ZRTP Commit message, but did not receive
a zrtp-hash value in the signaling, we must drop the call.

If the received zrtp-hash value in the signaling does not match the
hash of the actual received ZRTP Hello message, we must drop the call.

Changing the Cache Name
-----------------------

If the user edits an existing cache name but has not verified the SAS
on the current call, we must clear the ZRTP Verified flag and revert
the interface to the Not Secure state.  This is to prevent users from
"fixing" the cache name of an attacker -- thinking a simple error has
occurred -- without rechecking the SAS.

Behavior on Cache Mismatch
--------------------------

An attacker can always avoid creating a cache mismatch by simply
randomizing his ZID.  To maintain security while simplifying the
behavior surrounding a cache mismatch, we only need to give the
attacker no advantage as compared to randomizing his ZID.

On a cache mismatch the interface must show the Not Secure state until
the user verifies the SAS.

As described in RFC 6189 Section 4.6.1.1, the cache must not be
manipulated at all until the user verifies the SAS.  This prevents the
attacker from clearing a legitimate security association.

Prompting for the SAS Comparison
--------------------------------

A user may not know what it means if the words on screen do not match.
If we only provide one path forward or encourage one answer over
another, we risk prompting the user to lie to us.  We must ask the
user plainly whether the words match, the words do not match, or the
user wishes to compare the words later.

Behavior on SAS Mismatch
------------------------

If the user indicates an SAS mismatch, the call is -- without a doubt
-- being actively intercepted.  The software must show the Not Secure
state and alert the user clearly that he or she is being attacked.
This is the one and only security exception we cannot address by
either dropping the call or simply showing Not Secure.  The humans are
going to have to work this one out on their own, and we need to give
them the information they need to understand their predicament.

Secure State
------------

We move to the Secure state only after the ZRTP negotiation has
completed successfully and when either the ZRTP Verified flag is set
in the cache or the local user indicates to the software that the
words on screen match.

If any security exception other than an SAS mismatch has occurred, we
will have already dropped the call and so cannot move into the Secure
state.

Not Secure State
----------------

The Not Secure state is shown whenever the Secure state cannot yet be
shown, or when we must revert to this state as described in this
document.

Summary
-------

We can simplify the operation of a ZRTP secure phone by directing all
attacker manipulations toward outcomes the attacker could achieve in
other ways.  In many cases we simply drop the call.  In others, we
indicate the call is Not Secure until the users verify the SAS.

Our mental model is then reduced to a single user behavior.  If the
call is Not Secure for any reason, the users should verify the SAS.
If it matches the call is Secure.  If it doesn't the users are being
attacked.  All other security exceptions are handled transparently by
the software.

---

`Author: Travis Cross <tc@traviscross.com>`

`Date: 2014-10-19`

`Document Version: v0.5`

`Document ID: be11702b-66df-4404-b9f4-346c8e900253`

---

Copyright (c) 2014 Travis Cross

Distribution of this memo is unlimited.
