package Net::ORCID::API::Common;

use strict;
use warnings;
use namespace::clean;
use Module::Load qw(load);
use Moo::Role;

requires '_build_url';

has sandbox => (
    is => 'ro',
);

has transport => (
    is => 'ro',
    builder => '_build_transport',
);

has url => (
    is => 'ro',
    init_arg => 0,
    lazy => 1,
    builder => '_build_url',
);

has _t => (
    is => 'ro',
    init_arg => 0,
    lazy => 1,
    builder => '_build_t',
);

sub _build_transport {
    'LWP';
}

sub _build_t {
    my ($self) = @_;
    my $transport = $self->transport;
    my $transport_class = "Net::ORCID::Transport::${transport}";
    load $transport_class;
    $transport_class->new;
}

1;
