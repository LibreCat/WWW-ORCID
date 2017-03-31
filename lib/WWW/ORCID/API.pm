package WWW::ORCID::API;

use strict;
use warnings;

our $VERSION = 0.02;

use Class::Load qw(try_load_class);
use JSON qw(decode_json);
use Carp;
use Moo::Role;
use namespace::clean;

my $DEFAULT_TRANSPORT = 'LWP';

requires '_build_api_url';

has debug => (
    is => 'ro',
);

has sandbox => (
    is => 'ro',
);

has transport => (
    is => 'lazy',
);

has api_url => (
    is => 'lazy',
);

has oauth_url => (
    is => 'lazy',
);

has _t => (
    is => 'lazy',
);

sub _build_oauth_url {
    my ($self) = @_;
    $self->sandbox ? 'https://sandbox.orcid.org/oauth/token'
                   : 'https://orcid.org/oauth/token';
}

sub _build_transport {
    $DEFAULT_TRANSPORT;
}

sub _build__t {
    my ($self) = @_;
    my $transport = $self->transport;
    my $transport_class = "WWW::ORCID::Transport::${transport}";
    try_load_class($transport_class)
      or croak("Could not load $transport_class: $!");
    $transport_class->new(debug => $self->debug);
}

sub new_access_token {
    my ($self, $client_id, $client_secret, %opts) = @_;

    my $grant_type = $opts{grant_type} || 'client_credentials';
    my $headers = {'Accept' => 'application/json'};
    my $form = {
        client_id => $client_id,
        client_secret => $client_secret,
        grant_type => $grant_type,
    };
    $form->{scope} = $opts{scope} if defined $opts{scope};
    $form->{code}  = $opts{code}  if defined $opts{code};
    my ($res_code, $res_headers, $res_body) =
        $self->_t->post_form($self->oauth_url, $form, $headers);
    decode_json($res_body);
}

1;
