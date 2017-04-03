package WWW::ORCID::API;

use strict;
use warnings;

our $VERSION = 0.02;

use Class::Load qw(try_load_class);
use JSON qw(decode_json);
use Carp;
use Moo::Role;
use namespace::clean;

with 'WWW::ORCID::Base';

requires '_build_api_url';

has sandbox => (
    is => 'ro',
);

has transport => (
    is => 'lazy',
);

has api_url => (
    is => 'lazy',
);

has _t => (
    is => 'lazy',
);

sub _build_transport {
    'LWP';
}

sub _build__t {
    my ($self) = @_;
    my $transport = $self->transport;
    my $transport_class = "WWW::ORCID::Transport::${transport}";
    try_load_class($transport_class)
      or croak("Could not load $transport_class: $!");
    $transport_class->new;
}

1;
