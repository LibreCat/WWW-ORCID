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

has read_public_token => (is => 'lazy');
has read_limited_token => (is => 'lazy');

my $OPS = {
    'group-id-record' => {get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'search' => {get => 1},
    'activities' => {orcid => 1, get => 1},
    'address' => {orcid => 1, get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'biography' => {orcid => 1, get => 1},
    'education' => {orcid => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'education/summary' => {orcid => 1, get_pc => 1},
    'educations' => {orcid => 1, get => 1},
    'email' => {orcid => 1, get => 1},
    'employment' => {orcid => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'employment/summary' => {orcid => 1, get_pc => 1},
    'employments' => {orcid => 1, get => 1},
    'external-identifiers' => {orcid => 1, get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'funding' => {orcid => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'funding/summary' => {orcid => 1, get_pc => 1},
    'fundings' => {orcid => 1, get => 1},
    'keywords' => {orcid => 1, get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'other-names' => {orcid => 1, get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'peer-review' => {orcid => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'peer-review/summary' => {orcid => 1, get_pc => 1},
    'peer-reviews' => {orcid => 1, get => 1},
    'person' => {orcid => 1, get => 1},
    'personal-details' => {orcid => 1, get => 1},
    'researcher-urls' => {orcid => 1, get => 1, add => 1, delete => 1, get_pc => 1, update => 1},
    'work' => {orcid => 1, add => 1, delete => 1, get_pc => 1, update => 1},
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

sub _build_read_public_token {
    $_[0]->access_token(grant_type => 'client_credentials', scope => '/read-public');
}

sub _build_read_limited_token {
    $_[0]->access_token(grant_type => 'client_credentials', scope => '/read-limited');
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

sub _headers {
    my ($opts, $add_accept, $add_content_type) = @_;
    my $token = $opts->{token};
    $token = $token->{access_token} if ref $token;
    my $headers = {
        'Authorization' => "Bearer $token",
    };
    if ($add_accept) {
        $headers->{'Accept'} = 'application/vnd.orcid+json';
    }
    if ($add_content_type) {
        $headers->{'Content-Type'} = 'application/vnd.orcid+json';
    }
    $headers;
}

sub _clean {
    my ($opts) = @_;
    delete $opts->{$_} for qw(orcid token put_code);
    $opts;
}

sub client_details {
    my $self = shift;
    $self->_clear_last_error;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{token} ||= $self->read_public_token;
    my $url = join('/', $self->api_url, 'client', $self->client_id);
    my $res = $self->_t->get($url, undef, _headers($opts, 1, 0));
    if ($res->[0] eq '200') {
        return decode_json($res->[2]);
    }
    $self->_set_last_error($res);
    return;
}

sub get {
    my $self = shift;
    $self->_clear_last_error;
    my $path = shift;
    my $opts = ref $_[0] ? $_[0] : {@_};
    $opts->{token} ||= $self->read_public_token;
    my $url = _url($self->api_url, $path, $opts);
    my $headers = _headers($opts, 1, 0);
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
    my $res = $self->_t->post($url, $body, _headers($opts, 0, 1));
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
    # put code needs to be in both path and body
    $data->{'put-code'} ||= $opts->{put_code} if $opts->{put_code};
    $opts->{put_code} ||= $data->{'put-code'} if $data->{'put-code'};
    my $body = encode_json($data);
    my $url = _url($self->api_url, $path, $opts);
    my $res = $self->_t->put($url, $body, _headers($opts, 1, 1));
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
    my $res = $self->_t->delete($url, undef, _headers($opts, 1));
    if ($res->[0] eq '204') {
        return 1;
    }
    $self->_set_last_error($res);
    return;
}

for my $op (keys %$OPS) {
    my $spec = $OPS->{$op};
    my $pkg = __PACKAGE__;
    my $sym = $op;
    $sym =~ s|[-/]|_|g;

    if ($spec->{get} || $spec->{get_pc} || $spec->{get_pc_bulk}) {
        quote_sub("${pkg}::${sym}",
            qq|shift->get('${op}', \@_)|);
    }

    if ($spec->{add}) {
        quote_sub("${pkg}::add_${sym}",
            qq|shift->add('${op}', \@_)|);
    }

    if ($spec->{update}) {
        quote_sub("${pkg}::update_${sym}",
            qq|shift->update('${op}', \@_)|);
    }

    if ($spec->{delete}) {
        quote_sub("${pkg}::delete_${sym}",
            qq|shift->delete('${op}', \@_)|);
    }
}

1;

__END__

=pod

=head1 NAME

WWW::ORCID::API::v2_0 - A client for the ORCID 2.0 API

=cut
