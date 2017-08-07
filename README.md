# NAME

WWW::ORCID - A client for the ORCID 2.0 API

# SYNOPSIS

    my $client = WWW::ORCID->new(client_id => "XXX", client_secret => "XXX");

    my $client = WWW::ORCID->new(client_id => "XXX", client_secret => "XXX", sandbox => 1);

    my $client = WWW::ORCID->new(client_id => "XXX", client_secret => "XXX", public => 1);

# DESCRIPTION

A client for the ORCID 2.x API.

# CREATING A NEW INSTANCE

The `new` method returns a new [2.0 API client](https://metacpan.org/pod/WWW::ORCID::API::v2_0).

Arguments to new:

## `client_id`

Your ORCID client id (required).

## `client_secret`

Your ORCID client secret (required).

## `version`

The only possible value at the moment is `"2.0"` which will load [WWW::ORCID::API::v2\_0](https://metacpan.org/pod/WWW::ORCID::API::v2_0) or [WWW::ORCID::API::v2\_0\_public](https://metacpan.org/pod/WWW::ORCID::API::v2_0_public).

## `sandbox`

The client will use the API sandbox if set to `1`.

## `public`

The client will use the [ORCID public API](https://pub.sandbox.orcid.org/v2.0)
if set to `1`. Default is the
[ORCID member API](https://pub.sandbox.orcid.org/v2.0).

## `transport`

Specify the HTTP client to use. Possible values are [LWP](https://metacpan.org/pod/LWP) or [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny).
Default is [LWP](https://metacpan.org/pod/LWP).

# METHODS

Please refer to the API clients [WWW::ORCID::API::v2\_0](https://metacpan.org/pod/WWW::ORCID::API::v2_0) and [WWW::ORCID::API::v2\_0\_public](https://metacpan.org/pod/WWW::ORCID::API::v2_0_public) for method documentation.

# SEE ALSO

[https://api.orcid.org/v2.0/#/Member\_API\_v2.0](https://api.orcid.org/v2.0/#/Member_API_v2.0)

# AUTHOR

Patrick Hochstenbach `<patrick.hochstenbach at ugent.be>`

Nicolas Steenlant, `<nicolas.steenlant at ugent.be>`

Simeon Warner `<simeon.warner at cornell.edu>`

# LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
