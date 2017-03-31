package WWW::ORCID::API::v2_0;

use strict;
use warnings;

our $VERSION = 0.02;

use utf8;
use JSON qw(decode_json);
use XML::Writer;
use Moo;
use namespace::clean;

with 'WWW::ORCID::API';

sub _build_api_url {
    my ($self) = @_;
    $self->sandbox ? 'https://api.sandbox.orcid.org/v2.0'
                   : 'https://api.orcid.org/v2.0';
}

sub search {
    my ($self, $token, $params) = @_;
    my $url = $self->api_url;
    $token = $token->{access_token} if ref $token;
    $params = {q => $params} if $params && !ref $params;
    my $headers = {
        'Accept' => 'application/orcid+json',
        'Authorization' => "Bearer $token",
    };
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/search", $params, $headers);
    decode_json($res_body);
}

1;
