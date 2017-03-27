package WWW::ORCID;

use strict;
use warnings;

our $VERSION = 0.02;

use Class::Load qw(try_load_class);
use namespace::clean;

my $DEFAULT_VERSION = '2.0';

sub new {
    my $self = shift;
    my $opts = ref $_[0] ? {%{$_[0]}} : {@_};
    my $version = $opts->{version} ||= $DEFAULT_VERSION;
    $version =~ s/\./_/g;
    my $class = "WWW::ORCID::API::v${version}";
    try_load_class($class)
      or croak("Could not load $class: $!");
    $class->new($opts);
}

1;

__END__

=pod

=head1 NAME

WWW::ORCID - Module to interface with the ORCID webservice

=head1 SYNOPSIS

    use WWW::ORCID;

    my $orcid   = WWW::ORCID->new(version => '1.0');
    my $id      = '0000-0001-8390-6171';

    my $profile = $orcid->get_profile($id);
    my $bio     = $orcid->get_bio($id);
    my $works   = $orcid->get_works($id);

    my $result  = $orcid->search_bio({q => "johnson"});

    # Fielded search
    ############################################################
    # Fields
    #   - orcid
    #   - given-names
    #   - family-name
    #   - credit-name
    #   - other-names
    #   - email
    #   - external-id-reference
    #   - digital-object-ids
    #   - work-titles
    #   - keywords
    #   - creation date
    #   - last modified date
    #   - text
    # The query string follow the Lucene query syntax
    # See also: http://members.orcid.org/api/tutorial-searching-api-12-and-earlier
    my $result  = $orcid->search_bio({q => "family-name:johnson"});

    my $found   = $result->{'orcid-search-results'}->{'num-found'};

    # paging search results

    my $result2 = $orcid->search_bio({q => "family-name:hochstenbach", start => 10, rows => 10});

=head1 DESCRIPTION

Module to interface with the ORCID webservice.

=head1 SEE ALSO

L<http://members.orcid.org/api>

=head1 AUTHOR

Patrick Hochstenbach C<< <patrick.hochstenbach at ugent.be> >>

Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

Simeon Warner C<< <simeon.warner at cornell.edu> >>

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
