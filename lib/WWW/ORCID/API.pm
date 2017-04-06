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

has sandbox => (is => 'ro',);
has transport => (is => 'lazy',);
has api_url => (is => 'lazy',);
has last_error => (is => 'rwp', init_arg => undef, clearer => '_clear_last_error', trigger => 1);
has _t => (is => 'lazy',);

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
sub _trigger_last_error {
    my ($self, $res) = @_;
    $self->log->errorf("%s", $res) if $self->log->is_error;
}

1;
