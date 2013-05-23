package WWW::ORCID::Transport::LWP;

use strict;
use warnings;
use namespace::clean;
use Moo;
use LWP::UserAgent ();

with 'WWW::ORCID::Transport';

has _client => (
    is => 'ro',
    init_arg => 0,
    lazy => 1,
    builder => '_build_client',
);

sub _build_client {
    LWP::UserAgent->new;
}

sub get {
    my ($self, $url, $params, $headers) = @_;
    if ($params) {
        $url = $self->_param_url($url, $params);
    }
    my $res = $self->_client->get($url, %$headers);
    $res->content;
}

sub post_form {
    my ($self, $url, $form, $headers) = @_;
    my $res = $self->_client->post($url, $form, %$headers);
    $res->content;
}

sub post {
    my ($self, $url, $body, $headers) = @_;
    my $res = $self->_client->post($url, %$headers, Content => $body);
    my $res_headers = {};
    for my $key ($res->header_field_names) {
        $res_headers->{$key} = $res->header($key);
    }
    $res->content, $res_headers;
}

1;
