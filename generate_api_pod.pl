#!perl

use strict;
use warnings;
use WWW::ORCID::API::v2_0;

my $ops = WWW::ORCID::API::v2_0->ops;

print "\n";

for my $op (sort keys %$ops) {
    my $spec = $ops->{$op};
    my $sym = $op;
    $sym =~ s|[-/]|_|g;

    if ($spec->{get} || $spec->{get_pc} || $spec->{get_pc_bulk}) {
        print "=head2 C<${sym}>\n\n";

        if ($spec->{get} && ($spec->{get_pc} || $spec->{get_pc_bulk})) {
            print "    my \$recs = \$client->${sym}(token => \$token);\n";
        }
        elsif ($spec->{get}) {
            print "    my \$rec = \$client->${sym}(token => \$token);\n";
        }
        if ($spec->{get_pc}) {
            print "    my \$rec = \$client->${sym}(token => \$token, put_code => '123');\n";
        }
        if ($spec->{get_pc_bulk}) {
            print "    my \$recs = \$client->${sym}(token => \$token, put_code => ['123', '456']);\n";
        }
        print "\nEquivalent to:\n\n    \$client->get('${op}', \%opts)\n\n";
    }

    if ($spec->{add}) {
        print "=head2 C<add_${sym}>\n\n";
        print "    \$client->add_${sym}(\$data, token => \$token);\n";
        print "\nEquivalent to:\n\n    \$client->add('${op}', \$data, \%opts)\n\n";
    }

    if ($spec->{update}) {
        print "=head2 C<update_${sym}>\n\n";
        print "    \$client->update_${sym}(\$data, token => \$token, put_code => '123');\n";
        print "\nEquivalent to:\n\n    \$client->update('${op}', \$data, \%opts)\n\n";
    }

    if ($spec->{delete}) {
        print "=head2 C<delete_${sym}>\n\n";
        print "    my \$ok = \$client->delete_${sym}(token => \$token, put_code => '123');\n";
        print "\nEquivalent to:\n\n    \$client->delete('${op}', \%opts)\n\n";
    }

}
