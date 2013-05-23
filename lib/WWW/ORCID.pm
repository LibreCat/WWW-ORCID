package WWW::ORCID;

use strict;
use warnings;

=head1 NAME

WWW::ORCID - Module to interface with the ORCID webservice

=head1 DESCRIPTION

Module to interface with the ORCID webservice.

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

use WWW::ORCID::API::Pub ();
use WWW::ORCID::API ();


=head1 SEE ALSO

L<http://orcid.org>

=head1 AUTHOR

Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
