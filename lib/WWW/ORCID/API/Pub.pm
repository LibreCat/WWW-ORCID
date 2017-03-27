package WWW::ORCID::API::Pub;

use strict;
use warnings;

our $VERSION = 0.02;

use utf8;
use JSON qw(decode_json);
use Moo;
use namespace::clean;

with 'WWW::ORCID::API';

sub _build_url {
    my ($self) = @_;
    $self->sandbox ? 'http://pub.sandbox-1.orcid.org'
                   : 'http://pub.orcid.org';
}

sub get_profile {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/$orcid/orcid-profile", undef, {'Accept' => 'application/orcid+json'});
    decode_json($res_body);
}

sub get_bio {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/$orcid/orcid-bio", undef, {'Accept' => 'application/orcid+json'});
    decode_json($res_body);
}

sub get_works {
    my ($self, $orcid) = @_;
    my $url = $self->url;
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/$orcid/orcid-works", undef, {'Accept' => 'application/orcid+json'});
    decode_json($res_body);
}

sub search_bio {
    my ($self, $params) = @_;
    my $url = $self->url;
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/search/orcid-bio", $params, {'Accept' => 'application/orcid+json'});
    decode_json($res_body);
}

1;
