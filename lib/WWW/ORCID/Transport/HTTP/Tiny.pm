package WWW::ORCID::Transport::HTTP::Tiny;

use strict;
use warnings;

our $VERSION = 0.02;

use Moo;
use HTTP::Tiny;
use namespace::clean;

with 'WWW::ORCID::Transport';

has _client =>
    (is => 'ro', init_arg => 0, lazy => 1, builder => '_build_client',);

sub _build_client {
    HTTP::Tiny->new;
}

sub get {
    my ($self, $url, $params, $headers) = @_;
    if ($params) {
        $url = $self->_param_url($url, $params);
    }
    my $res = $self->_client->get($url, {headers => $headers});
    [$res->{status}, $res->{headers}, $res->{content}];
}

sub post_form {
    my ($self, $url, $form, $headers) = @_;
    my $res = $self->_client->post_form($url, $form, {headers => $headers});
    [$res->{status}, $res->{headers}, $res->{content}];
}

sub post {
    my ($self, $url, $body, $headers) = @_;
    my $res
        = $self->_client->post($url, {content => $body, headers => $headers});
    [$res->{status}, $res->{headers}, $res->{content}];
}

sub put {
    die 'TODO';
}

sub delete {
    die 'TODO';
}

1;
