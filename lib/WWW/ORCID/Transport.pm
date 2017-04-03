package WWW::ORCID::Transport;

use strict;
use warnings;

our $VERSION = 0.02;

use Moo::Role;
use namespace::clean;

with 'WWW::ORCID::Base';

requires 'get';
requires 'post_form';
requires 'post';

1;
