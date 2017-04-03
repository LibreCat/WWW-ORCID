package WWW::ORCID::API::v2_0;

use strict;
use warnings;

our $VERSION = 0.02;

use utf8;
use JSON qw(decode_json encode_json);
use Sub::Quote qw(quote_sub);
use Moo;
use namespace::clean;

with 'WWW::ORCID::MemberAPI';

our %GET_RECORD_PARTS = (
    activities => 'get_activities',
    address => 'get_address',
    biography => 'get_biography',
    educations => 'get_educations',
    email => 'get_email',
    employments => 'get_employments',
    'external-identifiers' => 'get_external_identifiers',
    fundings => 'get_fundings',
    keywords => 'get_keywords',
    'other-names' => 'get_other_names',
    'peer-reviews' => 'get_peer_reviews',
    person => 'get_person',
    'personal-details' => 'get_personal_details',
    'researcher-urls' => 'get_researcher_urls',
    works => 'get_works',
);

our %GET_RECORD_PUT_CODE_PARTS = (
    education => 'get_education',
    'education/summary' => 'get_education_summary',
    employment => 'get_employment',
    'employment/summary' => 'get_employment_summary',
    'external-identifiers' => 'get_external_identifier',
    funding => 'get_funding',
    'funding/summary' => 'get_funding_summary',
    keywords => 'get_keyword',
    'other-names' => 'get_other_name',
    'peer-review' => 'get_peer_review',
    'peer-review/summary' => 'get_peer_review_summary',
    'researcher-urls' => 'get_researcher_url',
    'work' => 'get_work',
    'work/summary' => 'get_work_summary',
);

our %ADD_RECORD_PARTS = (
    address => 'add_address',
);

sub _build_api_url {
    $_[0]->sandbox ? 'https://api.sandbox.orcid.org/v2.0'
                   : 'https://api.orcid.org/v2.0';
}

sub search {
    my $self = shift;
    my $token = shift;
    my $opts = ref $_[0] ? $_[0] : @_ == 1 ? {q => $_[0]} : {@_};
    my $url = $self->api_url;
    $token = $token->{access_token} if ref $token;
    my $headers = {
        'Accept' => 'application/orcid+json',
        'Authorization' => "Bearer $token",
    };
    my ($res_code, $res_headers, $res_body) =
        $self->_t->get("$url/search", $opts, $headers);
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

sub _add_record_part {
    my ($self, $token, $orcid, $path, $body) = @_;
    my $url = $self->api_url;
    $token = $token->{access_token} if ref $token;
    my $headers = {
        'Accept' => 'application/orcid+json',
        'Authorization' => "Bearer $token",
    };
    my ($res_code, $res_headers, $res_body) =
        $self->_t->post("$url/$orcid/$path", encode_json($body), $headers);
    decode_json($res_body);
}

for my $part (keys %GET_RECORD_PARTS) {
    my $pkg = __PACKAGE__;
    my $sym = $GET_RECORD_PARTS{$part};
    quote_sub("${pkg}::${sym}",
        qq|\$_[0]->_get_record_part(\$_[1], \$_[2], '${part}')|);
}

for my $part (keys %GET_RECORD_PUT_CODE_PARTS) {
    my $pkg = __PACKAGE__;
    my $sym = $GET_RECORD_PUT_CODE_PARTS{$part};
    quote_sub("${pkg}::${sym}",
        qq|\$_[0]->_get_record_part(\$_[1], \$_[2], join('/', '${part}', \$_[3]))|);
}

for my $part (keys %ADD_RECORD_PARTS) {
    my $pkg = __PACKAGE__;
    my $sym = $ADD_RECORD_PARTS{$part};
    quote_sub("${pkg}::${sym}",
        qq|\$_[0]->_add_record_part(\$_[1], \$_[2], '${part}', \$_[3])|);
}

1;
