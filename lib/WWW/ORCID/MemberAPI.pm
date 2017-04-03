package WWW::ORCID::MemberAPI;

use strict;
use warnings;

our $VERSION = 0.02;

use Moo::Role;
use JSON qw(decode_json);
use namespace::clean;

with 'WWW::ORCID::API';

has client_id => (is => 'ro', required => 1);
has client_secret => (is => 'ro', required => 1);
has oauth_url => (is => 'lazy');

sub _build_oauth_url {
    $_[0]->sandbox ? 'https://sandbox.orcid.org/oauth'
                   : 'https://orcid.org/oauth';
}

sub access_token {
    my $self = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{client_id} = $self->client_id;
    $opts->{client_secret} = $self->client_secret;
    my $url = join('/', $self->oauth_url, 'token');
    my $headers = {'Accept' => 'application/json'};
    my ($res_code, $res_headers, $res_body) =
        $self->_t->post_form($url, $opts, $headers);
    decode_json($res_body);
}

sub authorize_url {
    my $self = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{client_id} = $self->client_id;
    $self->_param_url(join('/', $self->oauth_url, 'authorize'), $opts);
}

1;

