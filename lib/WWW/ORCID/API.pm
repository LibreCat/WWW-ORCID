package WWW::ORCID::API;

use strict;
use warnings;

our $VERSION = 0.02;

use Class::Load qw(try_load_class);
use Carp;
use Moo::Role;
use namespace::clean;

my $DEFAULT_TRANSPORT = 'LWP';

requires '_build_url';

has debug => (
    is => 'ro',
);

has sandbox => (
    is => 'ro',
);

has transport => (
    is => 'lazy',
);

has url => (
    is => 'lazy',
    init_arg => 0,
);

has _t => (
    is => 'lazy',
    init_arg => 0,
);

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

1;
