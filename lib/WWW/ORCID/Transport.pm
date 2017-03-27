package WWW::ORCID::Transport;

use strict;
use warnings;

our $VERSION = 0.02;

use URI ();
use Moo::Role;
use namespace::clean;

requires 'get';
requires 'post_form';
requires 'post';

has debug => (is => 'ro');

sub _param_url {
    my ($self, $url, $params) = @_;
    $url = URI->new($url);
    $url->query_form($params);
    $url->as_string;
}

1;
