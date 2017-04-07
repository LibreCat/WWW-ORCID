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
    $self->_clear_last_error;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{client_id} = $self->client_id;
    $opts->{client_secret} = $self->client_secret;
    my $url = join('/', $self->oauth_url, 'token');
    my $headers = {'Accept' => 'application/json'};
    my $res = $self->_t->post_form($url, $opts, $headers);
    if ($res->[0] eq '200') {
        return decode_json($res->[2]);
    }
    $self->_set_last_error($res);
    return;
}

sub authorize_url {
    my $self = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{client_id} = $self->client_id;
    $self->_param_url(join('/', $self->oauth_url, 'authorize'), $opts);
}

1;

