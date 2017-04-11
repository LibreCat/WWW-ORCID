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

my $OPS = {
    'search' => {get => 1},
    'activities' => {orcid => 1, get => 1},
    'address' => {orcid => 1, get => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'biography' => {orcid => 1, get => 1},
    'education' => {orcid => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'education/summary' => {orcid => 1, get_pc => 1},
    'educations' => {orcid => 1, get => 1},
    'email' => {orcid => 1, get => 1},
    'employment' => {orcid => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'employment/summary' => {orcid => 1, get_pc => 1},
    'employments' => {orcid => 1, get => 1},
    'external-identifiers' => {orcid => 1, get => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'funding' => {orcid => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'funding/summary' => {orcid => 1, get_pc => 1},
    'fundings' => {orcid => 1, get => 1},
    'keywords' => {orcid => 1, get => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'other-names' => {orcid => 1, get => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'peer-review' => {orcid => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'peer-review/summary' => {orcid => 1, get_pc => 1},
    'peer-reviews' => {orcid => 1, get => 1},
    'person' => {orcid => 1, get => 1},
    'personal-details' => {orcid => 1, get => 1},
    'researcher-urls' => {orcid => 1, get => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'work' => {orcid => 1, post => 1, del_pc => 1, get_pc => 1, put_pc => 1},
    'work/summary' => {orcid => 1, get_pc => 1},
    'works' => {orcid => 1, get => 1, get_pc_bulk => 1},
};

sub ops {
    $OPS;
}

sub _build_api_url {
    $_[0]->sandbox ? 'https://api.sandbox.orcid.org/v2.0'
                   : 'https://api.orcid.org/v2.0';
}

sub _url {
    my ($host, $path, $opts) = @_;
    $path = join('/', @$path) if ref $path;
    $path =~ s|_summary$|/summary|;
    $path =~ s|_|-|g;
    if (defined(my $orcid = $opts->{orcid})) {
        $path = "$orcid/$path";
    }
    if (defined(my $put_code = $opts->{put_code})) {
        $put_code = join(',', @$put_code) if ref $put_code;
        $path = "$path/$put_code";
    }
    join('/', $host, $path);
}

sub _token {
    my ($opts) = @_;
    my $token = $opts->{token};
    ref $token ? $token->{access_token} : $token;
}

sub _clean {
    my ($opts) = @_;
    delete $opts->{$_} for qw(orcid token put_code);
    $opts;
}

sub get {
    my $self = shift;
    $self->_clear_last_error;
    my $path = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    my $url = _url($self->api_url, $path, $opts);
    my $token = _token($opts);
    my $headers = {
        'Accept' => 'application/vnd.orcid+json',
        'Authorization' => "Bearer $token",
    };
    my $res = $self->_t->get($url, _clean($opts), $headers);
    if ($res->[0] eq '200') {
        return decode_json($res->[2]);
    }
    $self->_set_last_error($res);
    return;
}

sub add {
    my $self = shift;
    $self->_clear_last_error;
    my $path = shift;
    my $data = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    my $body = encode_json($data);
    my $url = _url($self->api_url, $path, $opts);
    my $token = _token($opts);
    my $headers = {
        'Content-Type' => 'application/vnd.orcid+json',
        'Authorization' => "Bearer $token",
    };
    my $res = $self->_t->post($url, $body, $headers);
    if ($res->[0] eq '201') {
        my $loc = $res->[1]->{location};
        my ($put_code) = $loc =~ m|([^/]+)$|;
        return $put_code;
    }
    $self->_set_last_error($res);
    return;
}

sub update {
    my $self = shift;
    $self->_clear_last_error;
    my $path = shift;
    my $data = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $data->{'put-code'} ||= $opts->{put_code} if $opts->{put_code};
    $opts->{put_code} ||= $data->{'put-code'} if $data->{'put-code'};
    my $body = encode_json($data);
    my $url = _url($self->api_url, $path, $opts);
    my $token = _token($opts);
    my $headers = {
        'Content-Type' => 'application/vnd.orcid+json',
        'Accept' => 'application/vnd.orcid+json',
        'Authorization' => "Bearer $token",
    };
    my $res = $self->_t->put($url, $body, $headers);
    if ($res->[0] eq '200') {
        return decode_json($res->[2]);
    }
    $self->_set_last_error($res);
    return;
}

sub delete {
    my $self = shift;
    $self->_clear_last_error;
    my $path = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    my $url = _url($self->api_url, $path, $opts);
    my $token = _token($opts);
    my $headers = {
        'Content-Type' => 'application/vnd.orcid+json',
        'Authorization' => "Bearer $token",
    };
    my $res = $self->_t->delete($url, undef, $headers);
    if ($res->[0] eq '204') {
        return 1;
    }
    $self->_set_last_error($res);
    return;
}

sub search {
    my $self = shift;
    $self->get('search', @_);
}

#our %GET = (
    #activities => 'get_activities',
    #address => 'get_address',
    #biography => 'get_biography',
    #educations => 'get_educations',
    #email => 'get_email',
    #employments => 'get_employments',
    #'external-identifiers' => 'get_external_identifiers',
    #fundings => 'get_fundings',
    #keywords => 'get_keywords',
    #'other-names' => 'get_other_names',
    #'peer-reviews' => 'get_peer_reviews',
    #person => 'get_person',
    #'personal-details' => 'get_personal_details',
    #'researcher-urls' => 'get_researcher_urls',
    #works => 'get_works',
#);

#our %GET_PUT_CODE = (
    #education => 'get_education',
    #'education/summary' => 'get_education_summary',
    #employment => 'get_employment',
    #'employment/summary' => 'get_employment_summary',
    #'external-identifiers' => 'get_external_identifier',
    #funding => 'get_funding',
    #'funding/summary' => 'get_funding_summary',
    #keywords => 'get_keyword',
    #'other-names' => 'get_other_name',
    #'peer-review' => 'get_peer_review',
    #'peer-review/summary' => 'get_peer_review_summary',
    #'researcher-urls' => 'get_researcher_url',
    #'work' => 'get_work',
    #'work/summary' => 'get_work_summary',
#);

#our %ADD = (
    #address => 'add_address',
    #education => 'add_education',
    #employment => 'add_employment',
    #'external-identifiers' => 'add_external_identifier',
    #funding => 'add_funding',
    #keywords => 'add_keyword',
    #'other-names' => 'add_other_name',
    #'peer-review' => 'add_peer_review',
    #'researcher-urls' => 'add_researcher_url',
    #work => 'add_work',
#);

#our %DELETE_PUT_CODE = (
    #address => 'delete_address',
    #education => 'delete_education',
    #employment => 'delete_employment',
    #'external-identifiers' => 'delete_external_identifier',
    #funding => 'delete_funding',
    #keywords => 'delete_keyword',
    #'other-names' => 'delete_other_name',
    #'peer-review' => 'delete_peer_review',
    #'researcher-urls' => 'delete_researcher_url',
    #work => 'delete_work',
#);

#sub search {
    #my $self = shift;
    #my $token = shift;
    #my $opts = ref $_[0] ? $_[0] : @_ == 1 ? {q => $_[0]} : {@_};
    #my $url = $self->api_url;
    #$token = $token->{access_token} if ref $token;
    #my $headers = {
        #'Accept' => 'application/orcid+json',
        #'Authorization' => "Bearer $token",
    #};
    #my ($res_code, $res_headers, $res_body) =
        #$self->_t->get("$url/search", $opts, $headers);
    #decode_json($res_body);
#}

#sub _get {
    #my ($self, $token, $orcid, $path) = @_;
    #my $url = $self->api_url;
    #$token = $token->{access_token} if ref $token;
    #my $headers = {
        #'Accept' => 'application/orcid+json',
        #'Authorization' => "Bearer $token",
    #};
    #my ($res_code, $res_headers, $res_body) =
        #$self->_t->get("$url/$orcid/$path", undef, $headers);
    #decode_json($res_body);
#}

#sub _add {
    #my ($self, $token, $orcid, $path, $body) = @_;
    #my $url = $self->api_url;
    #$token = $token->{access_token} if ref $token;
    #my $headers = {
        #'Content-Type' => 'application/json',
        #'Accept' => 'text/html',
        #'Authorization' => "Bearer $token",
    #};
    #[$self->_t->post("$url/$orcid/$path", encode_json($body), $headers)];
#}

#for my $part (keys %GET) {
    #my $pkg = __PACKAGE__;
    #my $sym = $GET{$part};
    #quote_sub("${pkg}::${sym}",
        #qq|\$_[0]->_get(\$_[1], \$_[2], '${part}')|);
#}

#for my $part (keys %GET_PUT_CODE) {
    #my $pkg = __PACKAGE__;
    #my $sym = $GET_PUT_CODE{$part};
    #quote_sub("${pkg}::${sym}",
        #qq|\$_[0]->_get(\$_[1], \$_[2], join('/', '${part}', \$_[3]))|);
#}

#for my $part (keys %ADD) {
    #my $pkg = __PACKAGE__;
    #my $sym = $ADD{$part};
    #quote_sub("${pkg}::${sym}",
        #qq|\$_[0]->_add(\$_[1], \$_[2], '${part}', \$_[3])|);
#}

1;
