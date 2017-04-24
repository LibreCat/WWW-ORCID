package WWW::ORCID;

use strict;
use warnings;

our $VERSION = 0.02;

use Class::Load qw(try_load_class);
use Carp;
use namespace::clean;

my $DEFAULT_VERSION = '2.0';

sub new {
    my $self = shift;
    my $opts = ref $_[0] ? {%{$_[0]}} : {@_};
    my $version = $opts->{version} ||= $DEFAULT_VERSION;
    $version =~ s/\./_/g;
    my $class = "WWW::ORCID::API::v${version}";
    try_load_class($class)
      or croak("Could not load $class: $!");
    $class->new($opts);
}

1;

__END__

=pod

=head1 NAME

WWW::ORCID - A client for the ORCID API

=head1 SYNOPSIS

    use WWW::ORCID;

    my $client = WWW::ORCID->new(client_id => "XXX", client_secret => "XXX", sandbox => 1);

    my $hits = $orcid->search(q => "johnson");

=head1 DESCRIPTION

A client for the ORCID 2.0 API.

=head1 CREATING A NEW INSTANCE

The C<new> method returns a new L<2.0 API client|WWW::ORCID::API::v2_0>.

Arguments to new:

=head2 C<client_id>

Your ORCID client id (required).

=head2 C<client_secret>

Your ORCID client secret (required).

=head2 C<version>

The only possible value at the moment is C<"2.0"> which will load L<WWW::ORCID::API::v2_0>.

=head2 C<sandbox>

The client will talk to the L<ORCID sandbox API|https://api.sandbox.orcid.org/v2.0> if set to C<1>.

=head2 C<transport>

Specify the HTTP client to use. Possible values are L<LWP> or L<HTTP::Tiny>. Default is L<LWP>.

=head1 METHODS

=head2 C<client_id>

Returns the ORCID client id used by the client.

=head2 C<client_secret>

Returns the ORCID client secret used by the client.

=head2 C<sandbox>

Returns C<1> if the client is using the sandbox API, C<0> otherwise.

=head2 C<transport>

Returns what HTTP transport the client is using.

=head2 C<api_url>

Returns the base API url used by the client.

=head2 C<oauth_url>

Returns the base OAuth url used by the client.

=head C<access_token>

Request a new access token.

    my $token = $client->access_token(
        grant_type => 'client_credentials',
        scope => '/read-limited',
    );

=head C<authorize_url>

Returns an authorization url for 3-legged OAuth requests.

    # in your web application
    redirect($client->authorize_url(
        show_login => 'true',
        scope => '/person/update',
        response_type => 'code',
        redirect_uri => 'http://your.callback/url',
    ));

See the C</authorize> and C</authorized> routes in the included playground
application for an example.

=head2 C<read_public_token>

Return an access token with scope C</read-public>.

=head2 C<read_limited_token>

Return an access token with scope C</read-limited>.

=head2 C<client_details>

Fetch details about the current C<client_id>.

See C<API docs|https://api.orcid.org/v2.0/#!/Member_API_v2.0/viewClient>.

=head2 C<search>

    $client->search(q => 'Smith');

See C<API docs|https://api.orcid.org/v2.0/#!/Member_API_v2.0/searchByQueryXML>.

=head2 C<last_error>

Returns the last error returned by the ORCID API, if any.

=head2 C<log>

Returns the L<Log::Any> logger.

=head1 SEE ALSO

L<https://api.orcid.org/v2.0/#/Member_API_v2.0>

=head1 AUTHOR

Patrick Hochstenbach C<< <patrick.hochstenbach at ugent.be> >>

Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

Simeon Warner C<< <simeon.warner at cornell.edu> >>

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
