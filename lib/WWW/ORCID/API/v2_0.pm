package WWW::ORCID::API::v2_0;

use strict;
use warnings;

our $VERSION = 0.02;

use utf8;
use JSON qw(decode_json);
use XML::Writer;
use Sub::Quote qw(quote_sub);
use Moo;
use namespace::clean;

with 'WWW::ORCID::API';

my @GET_RECORD_PARTS = qw(
    activities
    address
    biography
    educations
    email
    employments
    external-identifiers
    fundings
    keywords
    other-names
    peer-reviews
    person
    personal-details
    researcher-urls
    works
);

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

sub _get_record_part {
    my ($self, $token, $orcid, $path) = @_;
    my $url = $self->api_url;
    $token = $token->{access_token} if ref $token;
    my $headers = {
        'Accept' => 'application/orcid+json',
        'Authorization' => "Bearer $token",
    };
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/$orcid/$path", undef, $headers);
    decode_json($res_body);
}

for my $part (@GET_RECORD_PARTS) {
    my $pkg = __PACKAGE__;
    my $sym = "get_${part}";
    $sym =~ s/-/_/g;
    quote_sub("${pkg}::${sym}",
        "\$_[0]->_get_record_part(\$_[1], \$_[2], '${part}')");
}

1;
