package Net::ORCID::Transport::LWP;

use strict;
use warnings;
use Moo;
use LWP::UserAgent ();

with 'Net::ORCID::Transport';

has _client => (
    is => 'ro',
    init_arg => 0,
    lazy => 1,
    builder => '_build_client',
);

sub _build_client {
    my $client = LWP::UserAgent->new;
    $client->default_header('Accept' => 'application/orcid+json');
    $client;
}

sub get {
    my ($self, $uri) = @_;
    my $res = $self->_client->get($uri);
    $res->content;
}

1;
