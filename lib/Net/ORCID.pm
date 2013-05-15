package Net::ORCID;

use warnings;
use strict;

our $VERSION = 0.01;

use JSON qw(decode_json);
use URI ();
use Moo;

has url => (
    is => 'ro',
    builder => 'default_url',
);

has transport => (
    is => 'ro',
    builder => 'default_transport',
);

has _t => (
    is => 'ro',
    init_arg => 0,
    lazy => 1,
    builder => '_build_t',
);

sub default_url {
    'http://pub.orcid.org';
}

sub default_transport {
    'LWP';
}

sub _build_t {
    my ($self) = @_;
    my $transport = $self->transport;
    my $transport_class = "Net::ORCID::Transport::${transport}";
    eval "require $transport_class;1;" or die;
    $transport_class->new;
}

sub get_profile {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my $res = $self->_t->get("$url/$orcid/orcid-profile");
    decode_json($res);
}

sub get_bio {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my $res = $self->_t->get("$url/$orcid/orcid-bio");
    decode_json($res);
}

sub get_works {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my $res = $self->_t->get("$url/$orcid/orcid-works");
    decode_json($res);
}

sub search_bio {
    my ($self, %params) = @_;
    my $url = $self->_param_url($self->url."/search/orcid-bio", \%params);
    my $res = $self->_t->get($url);
    decode_json($res);
}

sub _param_url {
    my ($self, $url, $params) = @_;
    $url = URI->new($url);
    $url->query_form($params);
    $url->as_string;
}

1;
