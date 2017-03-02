#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

my $pkg;
BEGIN {
    $pkg = 'WWW::ORCID::API::v2';
    use_ok $pkg;
}
require_ok $pkg;

done_testing;
