# -*- cperl -*-

=head1 pdt_c_m

Macros for annotation of the morphological layer of PDT-C.

=over 4

=cut

#include <contrib/pml/PML_M.mak>
#key-binding-adopt PML_M
#menu-binding-adopt PML_M

#encoding iso-8859-2


package pdt_c_m;
use strict;
use List::MoreUtils qw{ any };
use List::Util qw{ first };
use File::Spec;
use TrEd::Config qw( $font );

BEGIN { 'PML_M'->import }

use constant {
    SAVE_ANYWAY => 'Save anyway',
    TAG_LENGTH  => 15,
};

push @TredMacro::AUTO_CONTEXT_GUESSING, sub {
    my $schema = PML::SchemaName();
    my $description = PML::SchemaDescription();
    return 'pdt_c_m' if defined $schema && $schema eq 'mdata'
                     && defined $description
                     && $description eq 'PDT 3.6 morphological annotation';

    return
};

unshift @TrEd::Config::open_types, [
    'PDT-like morphological layer',
    [ '.m' ],
] unless $TrEd::Config::open_types[0][0] eq 'PDT-like morphological layer';

my %VALID_TAGS;
undef @VALID_TAGS{qw(
    A.------------- A2--------A---- A2--------A---1 A2--------N----
    AAFD7----1A---- AAFD7----1A---6 AAFD7----1N---- AAFD7----1N---6
    AAFD7----2A---- AAFD7----2A---1 AAFD7----2A---6 AAFD7----2N----
    AAFD7----2N---1 AAFD7----2N---6 AAFD7----3A---- AAFD7----3A---1
    AAFD7----3A---6 AAFD7----3N---- AAFD7----3N---1 AAFD7----3N---6
    AAFP1----1A---- AAFP1----1A---6 AAFP1----1N---- AAFP1----1N---6
    AAFP1----2A---- AAFP1----2A---1 AAFP1----2A---6 AAFP1----2N----
    AAFP1----2N---1 AAFP1----2N---6 AAFP1----3A---- AAFP1----3A---1
    AAFP1----3A---6 AAFP1----3N---- AAFP1----3N---1 AAFP1----3N---6
    AAFP2----1A---- AAFP2----1A---6 AAFP2----1N---- AAFP2----1N---6
    AAFP2----2A---- AAFP2----2A---1 AAFP2----2A---6 AAFP2----2N----
    AAFP2----2N---1 AAFP2----2N---6 AAFP2----3A---- AAFP2----3A---1
    AAFP2----3A---6 AAFP2----3N---- AAFP2----3N---1 AAFP2----3N---6
    AAFP3----1A---- AAFP3----1A---6 AAFP3----1N---- AAFP3----1N---6
    AAFP3----2A---- AAFP3----2A---1 AAFP3----2A---6 AAFP3----2A---7
    AAFP3----2N---- AAFP3----2N---1 AAFP3----2N---6 AAFP3----2N---7
    AAFP3----3A---- AAFP3----3A---1 AAFP3----3A---6 AAFP3----3A---7
    AAFP3----3N---- AAFP3----3N---1 AAFP3----3N---6 AAFP3----3N---7
    AAFP4----1A---- AAFP4----1A---6 AAFP4----1N---- AAFP4----1N---6
    AAFP4----2A---- AAFP4----2A---1 AAFP4----2A---6 AAFP4----2N----
    AAFP4----2N---1 AAFP4----2N---6 AAFP4----3A---- AAFP4----3A---1
    AAFP4----3A---6 AAFP4----3N---- AAFP4----3N---1 AAFP4----3N---6
    AAFP5----1A---- AAFP5----1A---6 AAFP5----1N---- AAFP5----1N---6
    AAFP5----2A---- AAFP5----2A---1 AAFP5----2A---6 AAFP5----2N----
    AAFP5----2N---1 AAFP5----2N---6 AAFP5----3A---- AAFP5----3A---1
    AAFP5----3A---6 AAFP5----3N---- AAFP5----3N---1 AAFP5----3N---6
    AAFP6----1A---- AAFP6----1A---6 AAFP6----1N---- AAFP6----1N---6
    AAFP6----2A---- AAFP6----2A---1 AAFP6----2A---6 AAFP6----2N----
    AAFP6----2N---1 AAFP6----2N---6 AAFP6----3A---- AAFP6----3A---1
    AAFP6----3A---6 AAFP6----3N---- AAFP6----3N---1 AAFP6----3N---6
    AAFP7----1A---- AAFP7----1A---6 AAFP7----1A---7 AAFP7----1N----
    AAFP7----1N---6 AAFP7----1N---7 AAFP7----2A---- AAFP7----2A---1
    AAFP7----2A---6 AAFP7----2A---7 AAFP7----2N---- AAFP7----2N---1
    AAFP7----2N---6 AAFP7----2N---7 AAFP7----3A---- AAFP7----3A---1
    AAFP7----3A---6 AAFP7----3A---7 AAFP7----3N---- AAFP7----3N---1
    AAFP7----3N---6 AAFP7----3N---7 AAFS1----1A---- AAFS1----1A---6
    AAFS1----1N---- AAFS1----1N---6 AAFS1----2A---- AAFS1----2A---1
    AAFS1----2A---6 AAFS1----2N---- AAFS1----2N---1 AAFS1----2N---6
    AAFS1----3A---- AAFS1----3A---1 AAFS1----3A---6 AAFS1----3N----
    AAFS1----3N---1 AAFS1----3N---6 AAFS2----1A---- AAFS2----1A---6
    AAFS2----1N---- AAFS2----1N---6 AAFS2----2A---- AAFS2----2A---1
    AAFS2----2A---6 AAFS2----2N---- AAFS2----2N---1 AAFS2----2N---6
    AAFS2----3A---- AAFS2----3A---1 AAFS2----3A---6 AAFS2----3N----
    AAFS2----3N---1 AAFS2----3N---6 AAFS3----1A---- AAFS3----1A---6
    AAFS3----1N---- AAFS3----1N---6 AAFS3----2A---- AAFS3----2A---1
    AAFS3----2A---6 AAFS3----2N---- AAFS3----2N---1 AAFS3----2N---6
    AAFS3----3A---- AAFS3----3A---1 AAFS3----3A---6 AAFS3----3N----
    AAFS3----3N---1 AAFS3----3N---6 AAFS4----1A---- AAFS4----1A---6
    AAFS4----1N---- AAFS4----1N---6 AAFS4----2A---- AAFS4----2A---1
    AAFS4----2A---6 AAFS4----2N---- AAFS4----2N---1 AAFS4----2N---6
    AAFS4----3A---- AAFS4----3A---1 AAFS4----3A---6 AAFS4----3N----
    AAFS4----3N---1 AAFS4----3N---6 AAFS5----1A---- AAFS5----1A---6
    AAFS5----1N---- AAFS5----1N---6 AAFS5----2A---- AAFS5----2A---1
    AAFS5----2A---6 AAFS5----2N---- AAFS5----2N---1 AAFS5----2N---6
    AAFS5----3A---- AAFS5----3A---1 AAFS5----3A---6 AAFS5----3N----
    AAFS5----3N---1 AAFS5----3N---6 AAFS6----1A---- AAFS6----1A---6
    AAFS6----1N---- AAFS6----1N---6 AAFS6----2A---- AAFS6----2A---1
    AAFS6----2A---6 AAFS6----2N---- AAFS6----2N---1 AAFS6----2N---6
    AAFS6----3A---- AAFS6----3A---1 AAFS6----3A---6 AAFS6----3N----
    AAFS6----3N---1 AAFS6----3N---6 AAFS7----1A---- AAFS7----1A---6
    AAFS7----1N---- AAFS7----1N---6 AAFS7----2A---- AAFS7----2A---1
    AAFS7----2A---6 AAFS7----2N---- AAFS7----2N---1 AAFS7----2N---6
    AAFS7----3A---- AAFS7----3A---1 AAFS7----3A---6 AAFS7----3N----
    AAFS7----3N---1 AAFS7----3N---6 AAFXX----1A---- AAFXX----1A---8
    AAFXX----1N---8 AAIP1----1A---- AAIP1----1A---6 AAIP1----1N----
    AAIP1----1N---6 AAIP1----2A---- AAIP1----2A---1 AAIP1----2A---6
    AAIP1----2N---- AAIP1----2N---1 AAIP1----2N---6 AAIP1----3A----
    AAIP1----3A---1 AAIP1----3A---6 AAIP1----3N---- AAIP1----3N---1
    AAIP1----3N---6 AAIP2----1A---- AAIP2----1A---6 AAIP2----1N----
    AAIP2----1N---6 AAIP2----2A---- AAIP2----2A---1 AAIP2----2A---6
    AAIP2----2N---- AAIP2----2N---1 AAIP2----2N---6 AAIP2----3A----
    AAIP2----3A---1 AAIP2----3A---6 AAIP2----3N---- AAIP2----3N---1
    AAIP2----3N---6 AAIP3----1A---- AAIP3----1A---6 AAIP3----1N----
    AAIP3----1N---6 AAIP3----2A---- AAIP3----2A---1 AAIP3----2A---6
    AAIP3----2A---7 AAIP3----2N---- AAIP3----2N---1 AAIP3----2N---6
    AAIP3----2N---7 AAIP3----3A---- AAIP3----3A---1 AAIP3----3A---6
    AAIP3----3A---7 AAIP3----3N---- AAIP3----3N---1 AAIP3----3N---6
    AAIP3----3N---7 AAIP4----1A---- AAIP4----1A---6 AAIP4----1N----
    AAIP4----1N---6 AAIP4----2A---- AAIP4----2A---1 AAIP4----2A---6
    AAIP4----2N---- AAIP4----2N---1 AAIP4----2N---6 AAIP4----3A----
    AAIP4----3A---1 AAIP4----3A---6 AAIP4----3N---- AAIP4----3N---1
    AAIP4----3N---6 AAIP5----1A---- AAIP5----1A---6 AAIP5----1N----
    AAIP5----1N---6 AAIP5----2A---- AAIP5----2A---1 AAIP5----2A---6
    AAIP5----2N---- AAIP5----2N---1 AAIP5----2N---6 AAIP5----3A----
    AAIP5----3A---1 AAIP5----3A---6 AAIP5----3N---- AAIP5----3N---1
    AAIP5----3N---6 AAIP6----1A---- AAIP6----1A---6 AAIP6----1N----
    AAIP6----1N---6 AAIP6----2A---- AAIP6----2A---1 AAIP6----2A---6
    AAIP6----2N---- AAIP6----2N---1 AAIP6----2N---6 AAIP6----3A----
    AAIP6----3A---1 AAIP6----3A---6 AAIP6----3N---- AAIP6----3N---1
    AAIP6----3N---6 AAIP7----1A---- AAIP7----1A---6 AAIP7----1A---7
    AAIP7----1N---- AAIP7----1N---6 AAIP7----1N---7 AAIP7----2A----
    AAIP7----2A---1 AAIP7----2A---6 AAIP7----2A---7 AAIP7----2N----
    AAIP7----2N---1 AAIP7----2N---6 AAIP7----2N---7 AAIP7----3A----
    AAIP7----3A---1 AAIP7----3A---6 AAIP7----3A---7 AAIP7----3N----
    AAIP7----3N---1 AAIP7----3N---6 AAIP7----3N---7 AAIPX----1A----
    AAIPX----1N---- AAIPX----2A---- AAIPX----2N---- AAIPX----3A----
    AAIPX----3N---- AAIS1----1A---- AAIS1----1A---1 AAIS1----1A---6
    AAIS1----1N---- AAIS1----1N---1 AAIS1----1N---6 AAIS1----2A----
    AAIS1----2A---1 AAIS1----2A---6 AAIS1----2N---- AAIS1----2N---1
    AAIS1----2N---6 AAIS1----3A---- AAIS1----3A---1 AAIS1----3A---6
    AAIS1----3N---- AAIS1----3N---1 AAIS1----3N---6 AAIS2----1A----
    AAIS2----1A---6 AAIS2----1N---- AAIS2----1N---6 AAIS2----2A----
    AAIS2----2A---1 AAIS2----2A---6 AAIS2----2N---- AAIS2----2N---1
    AAIS2----2N---6 AAIS2----3A---- AAIS2----3A---1 AAIS2----3A---6
    AAIS2----3N---- AAIS2----3N---1 AAIS2----3N---6 AAIS3----1A----
    AAIS3----1A---6 AAIS3----1N---- AAIS3----1N---6 AAIS3----2A----
    AAIS3----2A---1 AAIS3----2A---6 AAIS3----2N---- AAIS3----2N---1
    AAIS3----2N---6 AAIS3----3A---- AAIS3----3A---1 AAIS3----3A---6
    AAIS3----3N---- AAIS3----3N---1 AAIS3----3N---6 AAIS4----1A----
    AAIS4----1A---1 AAIS4----1A---6 AAIS4----1N---- AAIS4----1N---1
    AAIS4----1N---6 AAIS4----2A---- AAIS4----2A---1 AAIS4----2A---6
    AAIS4----2N---- AAIS4----2N---1 AAIS4----2N---6 AAIS4----3A----
    AAIS4----3A---1 AAIS4----3A---6 AAIS4----3N---- AAIS4----3N---1
    AAIS4----3N---6 AAIS5----1A---- AAIS5----1A---1 AAIS5----1A---6
    AAIS5----1N---- AAIS5----1N---1 AAIS5----1N---6 AAIS5----2A----
    AAIS5----2A---1 AAIS5----2A---6 AAIS5----2N---- AAIS5----2N---1
    AAIS5----2N---6 AAIS5----3A---- AAIS5----3A---1 AAIS5----3A---6
    AAIS5----3N---- AAIS5----3N---1 AAIS5----3N---6 AAIS6----1A----
    AAIS6----1A---6 AAIS6----1A---7 AAIS6----1N---- AAIS6----1N---6
    AAIS6----1N---7 AAIS6----2A---- AAIS6----2A---1 AAIS6----2A---6
    AAIS6----2A---7 AAIS6----2N---- AAIS6----2N---1 AAIS6----2N---6
    AAIS6----2N---7 AAIS6----3A---- AAIS6----3A---1 AAIS6----3A---6
    AAIS6----3A---7 AAIS6----3N---- AAIS6----3N---1 AAIS6----3N---6
    AAIS6----3N---7 AAIS7----1A---- AAIS7----1A---2 AAIS7----1A---6
    AAIS7----1N---- AAIS7----1N---2 AAIS7----1N---6 AAIS7----2A----
    AAIS7----2A---1 AAIS7----2A---6 AAIS7----2A---7 AAIS7----2N----
    AAIS7----2N---1 AAIS7----2N---6 AAIS7----2N---7 AAIS7----3A----
    AAIS7----3A---1 AAIS7----3A---6 AAIS7----3A---7 AAIS7----3N----
    AAIS7----3N---1 AAIS7----3N---6 AAIS7----3N---7 AAIXX----1A----
    AAMP1----1A---- AAMP1----1A---6 AAMP1----1N---- AAMP1----1N---6
    AAMP1----2A---- AAMP1----2A---1 AAMP1----2A---6 AAMP1----2N----
    AAMP1----2N---1 AAMP1----2N---6 AAMP1----3A---- AAMP1----3A---1
    AAMP1----3A---6 AAMP1----3N---- AAMP1----3N---1 AAMP1----3N---6
    AAMP2----1A---- AAMP2----1A---6 AAMP2----1N---- AAMP2----1N---6
    AAMP2----2A---- AAMP2----2A---1 AAMP2----2A---6 AAMP2----2N----
    AAMP2----2N---1 AAMP2----2N---6 AAMP2----3A---- AAMP2----3A---1
    AAMP2----3A---6 AAMP2----3N---- AAMP2----3N---1 AAMP2----3N---6
    AAMP3----1A---- AAMP3----1A---6 AAMP3----1N---- AAMP3----1N---6
    AAMP3----2A---- AAMP3----2A---1 AAMP3----2A---6 AAMP3----2A---7
    AAMP3----2N---- AAMP3----2N---1 AAMP3----2N---6 AAMP3----2N---7
    AAMP3----3A---- AAMP3----3A---1 AAMP3----3A---6 AAMP3----3A---7
    AAMP3----3N---- AAMP3----3N---1 AAMP3----3N---6 AAMP3----3N---7
    AAMP4----1A---- AAMP4----1A---6 AAMP4----1N---- AAMP4----1N---6
    AAMP4----2A---- AAMP4----2A---1 AAMP4----2A---6 AAMP4----2N----
    AAMP4----2N---1 AAMP4----2N---6 AAMP4----3A---- AAMP4----3A---1
    AAMP4----3A---6 AAMP4----3N---- AAMP4----3N---1 AAMP4----3N---6
    AAMP5----1A---- AAMP5----1A---6 AAMP5----1N---- AAMP5----1N---6
    AAMP5----2A---- AAMP5----2A---1 AAMP5----2A---6 AAMP5----2N----
    AAMP5----2N---1 AAMP5----2N---6 AAMP5----3A---- AAMP5----3A---1
    AAMP5----3A---6 AAMP5----3N---- AAMP5----3N---1 AAMP5----3N---6
    AAMP6----1A---- AAMP6----1A---6 AAMP6----1N---- AAMP6----1N---6
    AAMP6----2A---- AAMP6----2A---1 AAMP6----2A---6 AAMP6----2N----
    AAMP6----2N---1 AAMP6----2N---6 AAMP6----3A---- AAMP6----3A---1
    AAMP6----3A---6 AAMP6----3N---- AAMP6----3N---1 AAMP6----3N---6
    AAMP7----1A---- AAMP7----1A---6 AAMP7----1A---7 AAMP7----1N----
    AAMP7----1N---6 AAMP7----1N---7 AAMP7----2A---- AAMP7----2A---1
    AAMP7----2A---6 AAMP7----2A---7 AAMP7----2N---- AAMP7----2N---1
    AAMP7----2N---6 AAMP7----2N---7 AAMP7----3A---- AAMP7----3A---1
    AAMP7----3A---6 AAMP7----3A---7 AAMP7----3N---- AAMP7----3N---1
    AAMP7----3N---6 AAMP7----3N---7 AAMS1----1A---- AAMS1----1A---6
    AAMS1----1N---- AAMS1----1N---6 AAMS1----2A---- AAMS1----2A---1
    AAMS1----2A---6 AAMS1----2N---- AAMS1----2N---1 AAMS1----2N---6
    AAMS1----3A---- AAMS1----3A---1 AAMS1----3A---6 AAMS1----3N----
    AAMS1----3N---1 AAMS1----3N---6 AAMS2----1A---- AAMS2----1A---6
    AAMS2----1N---- AAMS2----1N---6 AAMS2----2A---- AAMS2----2A---1
    AAMS2----2A---6 AAMS2----2N---- AAMS2----2N---1 AAMS2----2N---6
    AAMS2----3A---- AAMS2----3A---1 AAMS2----3A---6 AAMS2----3N----
    AAMS2----3N---1 AAMS2----3N---6 AAMS3----1A---- AAMS3----1A---6
    AAMS3----1N---- AAMS3----1N---6 AAMS3----2A---- AAMS3----2A---1
    AAMS3----2A---6 AAMS3----2N---- AAMS3----2N---1 AAMS3----2N---6
    AAMS3----3A---- AAMS3----3A---1 AAMS3----3A---6 AAMS3----3N----
    AAMS3----3N---1 AAMS3----3N---6 AAMS4----1A---- AAMS4----1A---6
    AAMS4----1N---- AAMS4----1N---6 AAMS4----2A---- AAMS4----2A---1
    AAMS4----2A---6 AAMS4----2N---- AAMS4----2N---1 AAMS4----2N---6
    AAMS4----3A---- AAMS4----3A---1 AAMS4----3A---6 AAMS4----3N----
    AAMS4----3N---1 AAMS4----3N---6 AAMS5----1A---- AAMS5----1A---6
    AAMS5----1N---- AAMS5----1N---6 AAMS5----2A---- AAMS5----2A---1
    AAMS5----2A---6 AAMS5----2N---- AAMS5----2N---1 AAMS5----2N---6
    AAMS5----3A---- AAMS5----3A---1 AAMS5----3A---6 AAMS5----3N----
    AAMS5----3N---1 AAMS5----3N---6 AAMS6----1A---- AAMS6----1A---6
    AAMS6----1A---7 AAMS6----1N---- AAMS6----1N---6 AAMS6----1N---7
    AAMS6----2A---- AAMS6----2A---1 AAMS6----2A---6 AAMS6----2A---7
    AAMS6----2N---- AAMS6----2N---1 AAMS6----2N---6 AAMS6----2N---7
    AAMS6----3A---- AAMS6----3A---1 AAMS6----3A---6 AAMS6----3A---7
    AAMS6----3N---- AAMS6----3N---1 AAMS6----3N---6 AAMS6----3N---7
    AAMS7----1A---- AAMS7----1A---6 AAMS7----1N---- AAMS7----1N---6
    AAMS7----2A---- AAMS7----2A---1 AAMS7----2A---6 AAMS7----2A---7
    AAMS7----2N---- AAMS7----2N---1 AAMS7----2N---6 AAMS7----2N---7
    AAMS7----3A---- AAMS7----3A---1 AAMS7----3A---6 AAMS7----3A---7
    AAMS7----3N---- AAMS7----3N---1 AAMS7----3N---6 AAMS7----3N---7
    AAND7----1A---- AAND7----1A---6 AAND7----1N---- AAND7----1N---6
    AAND7----2A---- AAND7----2A---6 AAND7----2N---- AAND7----2N---6
    AAND7----3A---- AAND7----3A---6 AAND7----3N---- AAND7----3N---6
    AANP1----1A---- AANP1----1A---6 AANP1----1A---7 AANP1----1N----
    AANP1----1N---6 AANP1----1N---7 AANP1----2A---- AANP1----2A---1
    AANP1----2A---6 AANP1----2N---- AANP1----2N---1 AANP1----2N---6
    AANP1----3A---- AANP1----3A---1 AANP1----3A---6 AANP1----3N----
    AANP1----3N---1 AANP1----3N---6 AANP2----1A---- AANP2----1A---6
    AANP2----1N---- AANP2----1N---6 AANP2----2A---- AANP2----2A---1
    AANP2----2A---6 AANP2----2N---- AANP2----2N---1 AANP2----2N---6
    AANP2----3A---- AANP2----3A---1 AANP2----3A---6 AANP2----3N----
    AANP2----3N---1 AANP2----3N---6 AANP3----1A---- AANP3----1A---6
    AANP3----1N---- AANP3----1N---6 AANP3----2A---- AANP3----2A---1
    AANP3----2A---6 AANP3----2A---7 AANP3----2N---- AANP3----2N---1
    AANP3----2N---6 AANP3----2N---7 AANP3----3A---- AANP3----3A---1
    AANP3----3A---6 AANP3----3A---7 AANP3----3N---- AANP3----3N---1
    AANP3----3N---6 AANP3----3N---7 AANP4----1A---- AANP4----1A---6
    AANP4----1A---7 AANP4----1N---- AANP4----1N---6 AANP4----1N---7
    AANP4----2A---- AANP4----2A---1 AANP4----2A---6 AANP4----2N----
    AANP4----2N---1 AANP4----2N---6 AANP4----3A---- AANP4----3A---1
    AANP4----3A---6 AANP4----3N---- AANP4----3N---1 AANP4----3N---6
    AANP5----1A---- AANP5----1A---6 AANP5----1A---7 AANP5----1N----
    AANP5----1N---6 AANP5----1N---7 AANP5----2A---- AANP5----2A---1
    AANP5----2A---6 AANP5----2N---- AANP5----2N---1 AANP5----2N---6
    AANP5----3A---- AANP5----3A---1 AANP5----3A---6 AANP5----3N----
    AANP5----3N---1 AANP5----3N---6 AANP6----1A---- AANP6----1A---6
    AANP6----1N---- AANP6----1N---6 AANP6----2A---- AANP6----2A---1
    AANP6----2A---6 AANP6----2N---- AANP6----2N---1 AANP6----2N---6
    AANP6----3A---- AANP6----3A---1 AANP6----3A---6 AANP6----3N----
    AANP6----3N---1 AANP6----3N---6 AANP7----1A---- AANP7----1A---6
    AANP7----1A---7 AANP7----1N---- AANP7----1N---6 AANP7----1N---7
    AANP7----2A---- AANP7----2A---1 AANP7----2A---6 AANP7----2A---7
    AANP7----2N---- AANP7----2N---1 AANP7----2N---6 AANP7----2N---7
    AANP7----3A---- AANP7----3A---1 AANP7----3A---6 AANP7----3A---7
    AANP7----3N---- AANP7----3N---1 AANP7----3N---6 AANP7----3N---7
    AANS1----1A---- AANS1----1A---6 AANS1----1N---- AANS1----1N---6
    AANS1----2A---- AANS1----2A---1 AANS1----2A---6 AANS1----2N----
    AANS1----2N---1 AANS1----2N---6 AANS1----3A---- AANS1----3A---1
    AANS1----3A---6 AANS1----3N---- AANS1----3N---1 AANS1----3N---6
    AANS2----1A---- AANS2----1A---6 AANS2----1N---- AANS2----1N---6
    AANS2----2A---- AANS2----2A---1 AANS2----2A---6 AANS2----2N----
    AANS2----2N---1 AANS2----2N---6 AANS2----3A---- AANS2----3A---1
    AANS2----3A---6 AANS2----3N---- AANS2----3N---1 AANS2----3N---6
    AANS3----1A---- AANS3----1A---6 AANS3----1N---- AANS3----1N---6
    AANS3----2A---- AANS3----2A---1 AANS3----2A---6 AANS3----2N----
    AANS3----2N---1 AANS3----2N---6 AANS3----3A---- AANS3----3A---1
    AANS3----3A---6 AANS3----3N---- AANS3----3N---1 AANS3----3N---6
    AANS4----1A---- AANS4----1A---6 AANS4----1N---- AANS4----1N---6
    AANS4----2A---- AANS4----2A---1 AANS4----2A---6 AANS4----2N----
    AANS4----2N---1 AANS4----2N---6 AANS4----3A---- AANS4----3A---1
    AANS4----3A---6 AANS4----3N---- AANS4----3N---1 AANS4----3N---6
    AANS5----1A---- AANS5----1A---6 AANS5----1N---- AANS5----1N---6
    AANS5----2A---- AANS5----2A---1 AANS5----2A---6 AANS5----2N----
    AANS5----2N---1 AANS5----2N---6 AANS5----3A---- AANS5----3A---1
    AANS5----3A---6 AANS5----3N---- AANS5----3N---1 AANS5----3N---6
    AANS6----1A---- AANS6----1A---6 AANS6----1A---7 AANS6----1N----
    AANS6----1N---6 AANS6----1N---7 AANS6----2A---- AANS6----2A---1
    AANS6----2A---6 AANS6----2A---7 AANS6----2N---- AANS6----2N---1
    AANS6----2N---6 AANS6----2N---7 AANS6----3A---- AANS6----3A---1
    AANS6----3A---6 AANS6----3A---7 AANS6----3N---- AANS6----3N---1
    AANS6----3N---6 AANS6----3N---7 AANS7----1A---- AANS7----1A---6
    AANS7----1N---- AANS7----1N---6 AANS7----2A---- AANS7----2A---1
    AANS7----2A---6 AANS7----2A---7 AANS7----2N---- AANS7----2N---1
    AANS7----2N---6 AANS7----2N---7 AANS7----3A---- AANS7----3A---1
    AANS7----3A---6 AANS7----3A---7 AANS7----3N---- AANS7----3N---1
    AANS7----3N---6 AANS7----3N---7 AAXPX----1A---- AAXPX----1N----
    AAXXX----1A---- AAXXX----1A---1 AAXXX----1A---8 AAXXX----1A---9
    AAXXX----1N---- AAXXX----1N---8 AAXXX----2A---8 AAXXX----3A---8
    ACFS4-----A---- ACFS4-----N---- ACMP------A---- ACMP------N----
    ACNS------A---- ACNS------N---- ACQW------A---- ACQW------N----
    ACTP------A---- ACTP------N---- ACYS------A---- ACYS------N----
    AGFD7-----A---- AGFD7-----A---6 AGFD7-----N---- AGFD7-----N---6
    AGFP1-----A---- AGFP1-----A---6 AGFP1-----N---- AGFP1-----N---6
    AGFP2-----A---- AGFP2-----A---6 AGFP2-----N---- AGFP2-----N---6
    AGFP3-----A---- AGFP3-----A---6 AGFP3-----N---- AGFP3-----N---6
    AGFP4-----A---- AGFP4-----A---6 AGFP4-----N---- AGFP4-----N---6
    AGFP5-----A---- AGFP5-----A---6 AGFP5-----N---- AGFP5-----N---6
    AGFP6-----A---- AGFP6-----A---6 AGFP6-----N---- AGFP6-----N---6
    AGFP7-----A---- AGFP7-----A---6 AGFP7-----N---- AGFP7-----N---6
    AGFS1-----A---- AGFS1-----A---6 AGFS1-----N---- AGFS1-----N---6
    AGFS2-----A---- AGFS2-----A---6 AGFS2-----N---- AGFS2-----N---6
    AGFS3-----A---- AGFS3-----A---6 AGFS3-----N---- AGFS3-----N---6
    AGFS4-----A---- AGFS4-----A---6 AGFS4-----N---- AGFS4-----N---6
    AGFS5-----A---- AGFS5-----A---6 AGFS5-----N---- AGFS5-----N---6
    AGFS6-----A---- AGFS6-----A---6 AGFS6-----N---- AGFS6-----N---6
    AGFS7-----A---- AGFS7-----A---6 AGFS7-----N---- AGFS7-----N---6
    AGIP1-----A---- AGIP1-----A---6 AGIP1-----N---- AGIP1-----N---6
    AGIP2-----A---- AGIP2-----A---6 AGIP2-----N---- AGIP2-----N---6
    AGIP3-----A---- AGIP3-----A---6 AGIP3-----N---- AGIP3-----N---6
    AGIP4-----A---- AGIP4-----A---6 AGIP4-----N---- AGIP4-----N---6
    AGIP5-----A---- AGIP5-----A---6 AGIP5-----N---- AGIP5-----N---6
    AGIP6-----A---- AGIP6-----A---6 AGIP6-----N---- AGIP6-----N---6
    AGIP7-----A---- AGIP7-----A---6 AGIP7-----N---- AGIP7-----N---6
    AGIS1-----A---- AGIS1-----A---6 AGIS1-----N---- AGIS1-----N---6
    AGIS2-----A---- AGIS2-----A---6 AGIS2-----N---- AGIS2-----N---6
    AGIS3-----A---- AGIS3-----A---6 AGIS3-----N---- AGIS3-----N---6
    AGIS4-----A---- AGIS4-----A---6 AGIS4-----N---- AGIS4-----N---6
    AGIS5-----A---- AGIS5-----A---6 AGIS5-----N---- AGIS5-----N---6
    AGIS6-----A---- AGIS6-----A---6 AGIS6-----A---7 AGIS6-----N----
    AGIS6-----N---6 AGIS6-----N---7 AGIS7-----A---- AGIS7-----A---6
    AGIS7-----N---- AGIS7-----N---6 AGMP1-----A---- AGMP1-----A---6
    AGMP1-----N---- AGMP1-----N---6 AGMP2-----A---- AGMP2-----A---6
    AGMP2-----N---- AGMP2-----N---6 AGMP3-----A---- AGMP3-----A---6
    AGMP3-----N---- AGMP3-----N---6 AGMP4-----A---- AGMP4-----A---6
    AGMP4-----N---- AGMP4-----N---6 AGMP5-----A---- AGMP5-----A---6
    AGMP5-----N---- AGMP5-----N---6 AGMP6-----A---- AGMP6-----A---6
    AGMP6-----N---- AGMP6-----N---6 AGMP7-----A---- AGMP7-----A---6
    AGMP7-----N---- AGMP7-----N---6 AGMS1-----A---- AGMS1-----A---6
    AGMS1-----N---- AGMS1-----N---6 AGMS2-----A---- AGMS2-----A---6
    AGMS2-----N---- AGMS2-----N---6 AGMS3-----A---- AGMS3-----A---6
    AGMS3-----N---- AGMS3-----N---6 AGMS4-----A---- AGMS4-----A---6
    AGMS4-----N---- AGMS4-----N---6 AGMS5-----A---- AGMS5-----A---6
    AGMS5-----N---- AGMS5-----N---6 AGMS6-----A---- AGMS6-----A---6
    AGMS6-----A---7 AGMS6-----N---- AGMS6-----N---6 AGMS6-----N---7
    AGMS7-----A---- AGMS7-----A---6 AGMS7-----N---- AGMS7-----N---6
    AGND7-----A---- AGND7-----A---6 AGND7-----N---- AGND7-----N---6
    AGNP1-----A---- AGNP1-----A---6 AGNP1-----N---- AGNP1-----N---6
    AGNP2-----A---- AGNP2-----A---6 AGNP2-----N---- AGNP2-----N---6
    AGNP3-----A---- AGNP3-----A---6 AGNP3-----N---- AGNP3-----N---6
    AGNP4-----A---- AGNP4-----A---6 AGNP4-----N---- AGNP4-----N---6
    AGNP5-----A---- AGNP5-----A---6 AGNP5-----N---- AGNP5-----N---6
    AGNP6-----A---- AGNP6-----A---6 AGNP6-----N---- AGNP6-----N---6
    AGNP7-----A---- AGNP7-----A---6 AGNP7-----N---- AGNP7-----N---6
    AGNS1-----A---- AGNS1-----A---6 AGNS1-----N---- AGNS1-----N---6
    AGNS2-----A---- AGNS2-----A---6 AGNS2-----N---- AGNS2-----N---6
    AGNS3-----A---- AGNS3-----A---6 AGNS3-----N---- AGNS3-----N---6
    AGNS4-----A---- AGNS4-----A---6 AGNS4-----N---- AGNS4-----N---6
    AGNS5-----A---- AGNS5-----A---6 AGNS5-----N---- AGNS5-----N---6
    AGNS6-----A---- AGNS6-----A---6 AGNS6-----A---7 AGNS6-----N----
    AGNS6-----N---6 AGNS6-----N---7 AGNS7-----A---- AGNS7-----A---6
    AGNS7-----N---- AGNS7-----N---6 AMFD7-----A---- AMFD7-----A---1
    AMFD7-----A---2 AMFD7-----A---6 AMFD7-----N---- AMFD7-----N---1
    AMFD7-----N---2 AMFD7-----N---6 AMFP1-----A---- AMFP1-----A---1
    AMFP1-----A---2 AMFP1-----A---6 AMFP1-----N---- AMFP1-----N---1
    AMFP1-----N---2 AMFP1-----N---6 AMFP2-----A---- AMFP2-----A---1
    AMFP2-----A---2 AMFP2-----A---6 AMFP2-----N---- AMFP2-----N---1
    AMFP2-----N---2 AMFP2-----N---6 AMFP3-----A---- AMFP3-----A---1
    AMFP3-----A---2 AMFP3-----A---6 AMFP3-----A---7 AMFP3-----A---9
    AMFP3-----N---- AMFP3-----N---1 AMFP3-----N---2 AMFP3-----N---6
    AMFP3-----N---7 AMFP3-----N---9 AMFP4-----A---- AMFP4-----A---1
    AMFP4-----A---2 AMFP4-----A---6 AMFP4-----N---- AMFP4-----N---1
    AMFP4-----N---2 AMFP4-----N---6 AMFP5-----A---- AMFP5-----A---1
    AMFP5-----A---2 AMFP5-----A---6 AMFP5-----N---- AMFP5-----N---1
    AMFP5-----N---2 AMFP5-----N---6 AMFP6-----A---- AMFP6-----A---1
    AMFP6-----A---2 AMFP6-----A---6 AMFP6-----N---- AMFP6-----N---1
    AMFP6-----N---2 AMFP6-----N---6 AMFP7-----A---- AMFP7-----A---1
    AMFP7-----A---2 AMFP7-----A---6 AMFP7-----A---7 AMFP7-----A---9
    AMFP7-----N---- AMFP7-----N---1 AMFP7-----N---2 AMFP7-----N---6
    AMFP7-----N---7 AMFP7-----N---9 AMFS1-----A---- AMFS1-----A---1
    AMFS1-----A---2 AMFS1-----A---6 AMFS1-----N---- AMFS1-----N---1
    AMFS1-----N---2 AMFS1-----N---6 AMFS2-----A---- AMFS2-----A---1
    AMFS2-----A---2 AMFS2-----A---6 AMFS2-----N---- AMFS2-----N---1
    AMFS2-----N---2 AMFS2-----N---6 AMFS3-----A---- AMFS3-----A---1
    AMFS3-----A---2 AMFS3-----A---6 AMFS3-----N---- AMFS3-----N---1
    AMFS3-----N---2 AMFS3-----N---6 AMFS4-----A---- AMFS4-----A---1
    AMFS4-----A---2 AMFS4-----A---6 AMFS4-----N---- AMFS4-----N---1
    AMFS4-----N---2 AMFS4-----N---6 AMFS5-----A---- AMFS5-----A---1
    AMFS5-----A---2 AMFS5-----A---6 AMFS5-----N---- AMFS5-----N---1
    AMFS5-----N---2 AMFS5-----N---6 AMFS6-----A---- AMFS6-----A---1
    AMFS6-----A---2 AMFS6-----A---6 AMFS6-----N---- AMFS6-----N---1
    AMFS6-----N---2 AMFS6-----N---6 AMFS7-----A---- AMFS7-----A---1
    AMFS7-----A---2 AMFS7-----A---6 AMFS7-----N---- AMFS7-----N---1
    AMFS7-----N---2 AMFS7-----N---6 AMIP1-----A---- AMIP1-----A---1
    AMIP1-----A---2 AMIP1-----A---6 AMIP1-----N---- AMIP1-----N---1
    AMIP1-----N---2 AMIP1-----N---6 AMIP2-----A---- AMIP2-----A---1
    AMIP2-----A---2 AMIP2-----A---6 AMIP2-----N---- AMIP2-----N---1
    AMIP2-----N---2 AMIP2-----N---6 AMIP3-----A---- AMIP3-----A---1
    AMIP3-----A---2 AMIP3-----A---6 AMIP3-----A---7 AMIP3-----A---9
    AMIP3-----N---- AMIP3-----N---1 AMIP3-----N---2 AMIP3-----N---6
    AMIP3-----N---7 AMIP3-----N---9 AMIP4-----A---- AMIP4-----A---1
    AMIP4-----A---2 AMIP4-----A---6 AMIP4-----N---- AMIP4-----N---1
    AMIP4-----N---2 AMIP4-----N---6 AMIP5-----A---- AMIP5-----A---1
    AMIP5-----A---2 AMIP5-----A---6 AMIP5-----N---- AMIP5-----N---1
    AMIP5-----N---2 AMIP5-----N---6 AMIP6-----A---- AMIP6-----A---1
    AMIP6-----A---2 AMIP6-----A---6 AMIP6-----N---- AMIP6-----N---1
    AMIP6-----N---2 AMIP6-----N---6 AMIP7-----A---- AMIP7-----A---1
    AMIP7-----A---2 AMIP7-----A---6 AMIP7-----A---7 AMIP7-----A---9
    AMIP7-----N---- AMIP7-----N---1 AMIP7-----N---2 AMIP7-----N---6
    AMIP7-----N---7 AMIP7-----N---9 AMIS1-----A---- AMIS1-----A---1
    AMIS1-----A---2 AMIS1-----A---6 AMIS1-----N---- AMIS1-----N---1
    AMIS1-----N---2 AMIS1-----N---6 AMIS2-----A---- AMIS2-----A---1
    AMIS2-----A---2 AMIS2-----A---6 AMIS2-----N---- AMIS2-----N---1
    AMIS2-----N---2 AMIS2-----N---6 AMIS3-----A---- AMIS3-----A---1
    AMIS3-----A---2 AMIS3-----A---6 AMIS3-----N---- AMIS3-----N---1
    AMIS3-----N---2 AMIS3-----N---6 AMIS4-----A---- AMIS4-----A---1
    AMIS4-----A---2 AMIS4-----A---6 AMIS4-----N---- AMIS4-----N---1
    AMIS4-----N---2 AMIS4-----N---6 AMIS5-----A---- AMIS5-----A---1
    AMIS5-----A---2 AMIS5-----A---6 AMIS5-----N---- AMIS5-----N---1
    AMIS5-----N---2 AMIS5-----N---6 AMIS6-----A---- AMIS6-----A---1
    AMIS6-----A---2 AMIS6-----A---6 AMIS6-----A---7 AMIS6-----A---9
    AMIS6-----N---- AMIS6-----N---1 AMIS6-----N---2 AMIS6-----N---6
    AMIS6-----N---7 AMIS6-----N---9 AMIS7-----A---- AMIS7-----A---1
    AMIS7-----A---2 AMIS7-----A---6 AMIS7-----A---7 AMIS7-----A---9
    AMIS7-----N---- AMIS7-----N---1 AMIS7-----N---2 AMIS7-----N---6
    AMIS7-----N---7 AMIS7-----N---9 AMMP1-----A---- AMMP1-----A---1
    AMMP1-----A---2 AMMP1-----A---6 AMMP1-----N---- AMMP1-----N---1
    AMMP1-----N---2 AMMP1-----N---6 AMMP2-----A---- AMMP2-----A---1
    AMMP2-----A---2 AMMP2-----A---6 AMMP2-----N---- AMMP2-----N---1
    AMMP2-----N---2 AMMP2-----N---6 AMMP3-----A---- AMMP3-----A---1
    AMMP3-----A---2 AMMP3-----A---6 AMMP3-----A---7 AMMP3-----A---9
    AMMP3-----N---- AMMP3-----N---1 AMMP3-----N---2 AMMP3-----N---6
    AMMP3-----N---7 AMMP3-----N---9 AMMP4-----A---- AMMP4-----A---1
    AMMP4-----A---2 AMMP4-----A---6 AMMP4-----N---- AMMP4-----N---1
    AMMP4-----N---2 AMMP4-----N---6 AMMP5-----A---- AMMP5-----A---1
    AMMP5-----A---2 AMMP5-----A---6 AMMP5-----N---- AMMP5-----N---1
    AMMP5-----N---2 AMMP5-----N---6 AMMP6-----A---- AMMP6-----A---1
    AMMP6-----A---2 AMMP6-----A---6 AMMP6-----N---- AMMP6-----N---1
    AMMP6-----N---2 AMMP6-----N---6 AMMP7-----A---- AMMP7-----A---1
    AMMP7-----A---2 AMMP7-----A---6 AMMP7-----A---7 AMMP7-----A---9
    AMMP7-----N---- AMMP7-----N---1 AMMP7-----N---2 AMMP7-----N---6
    AMMP7-----N---7 AMMP7-----N---9 AMMS1-----A---- AMMS1-----A---1
    AMMS1-----A---2 AMMS1-----A---6 AMMS1-----N---- AMMS1-----N---1
    AMMS1-----N---2 AMMS1-----N---6 AMMS2-----A---- AMMS2-----A---1
    AMMS2-----A---2 AMMS2-----A---6 AMMS2-----N---- AMMS2-----N---1
    AMMS2-----N---2 AMMS2-----N---6 AMMS3-----A---- AMMS3-----A---1
    AMMS3-----A---2 AMMS3-----A---6 AMMS3-----N---- AMMS3-----N---1
    AMMS3-----N---2 AMMS3-----N---6 AMMS4-----A---- AMMS4-----A---1
    AMMS4-----A---2 AMMS4-----A---6 AMMS4-----N---- AMMS4-----N---1
    AMMS4-----N---2 AMMS4-----N---6 AMMS5-----A---- AMMS5-----A---1
    AMMS5-----A---2 AMMS5-----A---6 AMMS5-----N---- AMMS5-----N---1
    AMMS5-----N---2 AMMS5-----N---6 AMMS6-----A---- AMMS6-----A---1
    AMMS6-----A---2 AMMS6-----A---6 AMMS6-----A---7 AMMS6-----A---9
    AMMS6-----N---- AMMS6-----N---1 AMMS6-----N---2 AMMS6-----N---6
    AMMS6-----N---7 AMMS6-----N---9 AMMS7-----A---- AMMS7-----A---1
    AMMS7-----A---2 AMMS7-----A---6 AMMS7-----A---7 AMMS7-----A---9
    AMMS7-----N---- AMMS7-----N---1 AMMS7-----N---2 AMMS7-----N---6
    AMMS7-----N---7 AMMS7-----N---9 AMND7-----A---- AMND7-----A---6
    AMND7-----N---- AMND7-----N---6 AMNP1-----A---- AMNP1-----A---1
    AMNP1-----A---2 AMNP1-----A---6 AMNP1-----N---- AMNP1-----N---1
    AMNP1-----N---2 AMNP1-----N---6 AMNP2-----A---- AMNP2-----A---1
    AMNP2-----A---2 AMNP2-----A---6 AMNP2-----N---- AMNP2-----N---1
    AMNP2-----N---2 AMNP2-----N---6 AMNP3-----A---- AMNP3-----A---1
    AMNP3-----A---2 AMNP3-----A---6 AMNP3-----A---7 AMNP3-----A---9
    AMNP3-----N---- AMNP3-----N---1 AMNP3-----N---2 AMNP3-----N---6
    AMNP3-----N---7 AMNP3-----N---9 AMNP4-----A---- AMNP4-----A---1
    AMNP4-----A---2 AMNP4-----A---6 AMNP4-----N---- AMNP4-----N---1
    AMNP4-----N---2 AMNP4-----N---6 AMNP5-----A---- AMNP5-----A---1
    AMNP5-----A---2 AMNP5-----A---6 AMNP5-----N---- AMNP5-----N---1
    AMNP5-----N---2 AMNP5-----N---6 AMNP6-----A---- AMNP6-----A---1
    AMNP6-----A---2 AMNP6-----A---6 AMNP6-----N---- AMNP6-----N---1
    AMNP6-----N---2 AMNP6-----N---6 AMNP7-----A---- AMNP7-----A---1
    AMNP7-----A---2 AMNP7-----A---6 AMNP7-----A---7 AMNP7-----A---9
    AMNP7-----N---- AMNP7-----N---1 AMNP7-----N---2 AMNP7-----N---6
    AMNP7-----N---7 AMNP7-----N---9 AMNS1-----A---- AMNS1-----A---1
    AMNS1-----A---2 AMNS1-----A---6 AMNS1-----N---- AMNS1-----N---1
    AMNS1-----N---2 AMNS1-----N---6 AMNS2-----A---- AMNS2-----A---1
    AMNS2-----A---2 AMNS2-----A---6 AMNS2-----N---- AMNS2-----N---1
    AMNS2-----N---2 AMNS2-----N---6 AMNS3-----A---- AMNS3-----A---1
    AMNS3-----A---2 AMNS3-----A---6 AMNS3-----N---- AMNS3-----N---1
    AMNS3-----N---2 AMNS3-----N---6 AMNS4-----A---- AMNS4-----A---1
    AMNS4-----A---2 AMNS4-----A---6 AMNS4-----N---- AMNS4-----N---1
    AMNS4-----N---2 AMNS4-----N---6 AMNS5-----A---- AMNS5-----A---1
    AMNS5-----A---2 AMNS5-----A---6 AMNS5-----N---- AMNS5-----N---1
    AMNS5-----N---2 AMNS5-----N---6 AMNS6-----A---- AMNS6-----A---1
    AMNS6-----A---2 AMNS6-----A---6 AMNS6-----A---7 AMNS6-----A---9
    AMNS6-----N---- AMNS6-----N---1 AMNS6-----N---2 AMNS6-----N---6
    AMNS6-----N---7 AMNS6-----N---9 AMNS7-----A---- AMNS7-----A---1
    AMNS7-----A---2 AMNS7-----A---6 AMNS7-----A---7 AMNS7-----A---9
    AMNS7-----N---- AMNS7-----N---1 AMNS7-----N---2 AMNS7-----N---6
    AMNS7-----N---7 AMNS7-----N---9 AOFP----------- AOFP----------1
    AOFP----------6 AOFS----------- AOFS----------1 AOIP-----------
    AOIP----------1 AOIP----------6 AOMP----------- AOMP----------1
    AOMP----------6 AONP----------- AONP----------1 AONP----------6
    AONS----------- AONS----------1 AONS----------6 AOYS-----------
    AOYS----------6 AUFD7F--------- AUFD7F--------6 AUFD7M---------
    AUFD7M--------6 AUFP1F--------- AUFP1F--------6 AUFP1M---------
    AUFP1M--------5 AUFP1M--------6 AUFP2F--------- AUFP2F--------6
    AUFP2M--------- AUFP2M--------6 AUFP3F--------- AUFP3F--------6
    AUFP3M--------- AUFP3M--------6 AUFP4F--------- AUFP4F--------6
    AUFP4M--------- AUFP4M--------6 AUFP5F--------- AUFP5F--------6
    AUFP5M--------- AUFP5M--------6 AUFP6F--------- AUFP6F--------6
    AUFP6M--------- AUFP6M--------6 AUFP7F--------- AUFP7F--------6
    AUFP7F--------7 AUFP7M--------- AUFP7M--------6 AUFP7M--------7
    AUFS1F--------- AUFS1F--------6 AUFS1M--------- AUFS1M--------6
    AUFS2F--------- AUFS2F--------6 AUFS2M--------- AUFS2M--------6
    AUFS3F--------- AUFS3F--------6 AUFS3M--------- AUFS3M--------6
    AUFS4F--------- AUFS4F--------6 AUFS4M--------- AUFS4M--------6
    AUFS5F--------- AUFS5F--------6 AUFS5M--------- AUFS5M--------6
    AUFS6F--------- AUFS6F--------6 AUFS6M--------- AUFS6M--------6
    AUFS7F--------- AUFS7F--------6 AUFS7M--------- AUFS7M--------6
    AUIP1F--------- AUIP1F--------6 AUIP1M--------- AUIP1M--------6
    AUIP2F--------- AUIP2F--------6 AUIP2M--------- AUIP2M--------6
    AUIP3F--------- AUIP3F--------6 AUIP3M--------- AUIP3M--------6
    AUIP4F--------- AUIP4F--------6 AUIP4M--------- AUIP4M--------6
    AUIP5F--------- AUIP5F--------6 AUIP5M--------- AUIP5M--------6
    AUIP6F--------- AUIP6F--------6 AUIP6M--------- AUIP6M--------6
    AUIP7F--------- AUIP7F--------6 AUIP7F--------7 AUIP7M---------
    AUIP7M--------6 AUIP7M--------7 AUIS1F--------- AUIS1F--------6
    AUIS1M--------- AUIS1M--------6 AUIS2F--------- AUIS2F--------6
    AUIS2M--------- AUIS2M--------6 AUIS3F--------- AUIS3F--------6
    AUIS3M--------- AUIS3M--------6 AUIS4F--------- AUIS4F--------6
    AUIS4M--------- AUIS4M--------6 AUIS5F--------- AUIS5F--------6
    AUIS5M--------- AUIS5M--------6 AUIS6F--------- AUIS6F--------1
    AUIS6F--------6 AUIS6F--------7 AUIS6M--------- AUIS6M--------1
    AUIS6M--------6 AUIS7F--------- AUIS7F--------6 AUIS7M---------
    AUIS7M--------6 AUMP1F--------- AUMP1F--------6 AUMP1M---------
    AUMP1M--------6 AUMP2F--------- AUMP2F--------6 AUMP2M---------
    AUMP2M--------6 AUMP3F--------- AUMP3F--------6 AUMP3M---------
    AUMP3M--------6 AUMP4F--------- AUMP4F--------6 AUMP4M---------
    AUMP4M--------6 AUMP5F--------- AUMP5F--------6 AUMP5M---------
    AUMP5M--------6 AUMP6F--------- AUMP6F--------6 AUMP6M---------
    AUMP6M--------6 AUMP7F--------- AUMP7F--------6 AUMP7F--------7
    AUMP7M--------- AUMP7M--------6 AUMP7M--------7 AUMS1F---------
    AUMS1F--------6 AUMS1M--------- AUMS1M--------6 AUMS2F---------
    AUMS2F--------6 AUMS2M--------- AUMS2M--------6 AUMS3F---------
    AUMS3F--------6 AUMS3M--------- AUMS3M--------6 AUMS4F---------
    AUMS4F--------6 AUMS4M--------- AUMS4M--------6 AUMS5F---------
    AUMS5F--------6 AUMS5M--------- AUMS5M--------6 AUMS6F---------
    AUMS6F--------1 AUMS6F--------6 AUMS6F--------7 AUMS6M---------
    AUMS6M--------1 AUMS6M--------6 AUMS7F--------- AUMS7F--------6
    AUMS7M--------- AUMS7M--------6 AUND7F--------- AUND7F--------6
    AUND7M--------- AUND7M--------6 AUNP1F--------- AUNP1F--------6
    AUNP1M--------- AUNP1M--------6 AUNP2F--------- AUNP2F--------6
    AUNP2M--------- AUNP2M--------6 AUNP3F--------- AUNP3F--------6
    AUNP3M--------- AUNP3M--------6 AUNP4F--------- AUNP4F--------6
    AUNP4M--------- AUNP4M--------6 AUNP5F--------- AUNP5F--------6
    AUNP5M--------- AUNP5M--------6 AUNP6F--------- AUNP6F--------6
    AUNP6M--------- AUNP6M--------6 AUNP7F--------- AUNP7F--------6
    AUNP7F--------7 AUNP7M--------- AUNP7M--------6 AUNP7M--------7
    AUNS1F--------- AUNS1F--------6 AUNS1M--------- AUNS1M--------6
    AUNS2F--------- AUNS2F--------6 AUNS2M--------- AUNS2M--------6
    AUNS3F--------- AUNS3F--------6 AUNS3M--------- AUNS3M--------6
    AUNS4F--------- AUNS4F--------6 AUNS4M--------- AUNS4M--------6
    AUNS5F--------- AUNS5F--------6 AUNS5M--------- AUNS5M--------6
    AUNS6F--------- AUNS6F--------1 AUNS6F--------6 AUNS6F--------7
    AUNS6M--------- AUNS6M--------1 AUNS6M--------6 AUNS7F---------
    AUNS7F--------6 AUNS7M--------- AUNS7M--------6 AUXXXF--------7
    AUXXXF--------8 AUXXXM--------- AUXXXM--------5 AUXXXM--------6
    AUXXXM--------7 AUXXXM--------8 AUXXXM--------9 C=-------------
    C}------------- C?--1---------- C}------------1 C?--1---------1
    C?--2---------- C}------------2 C?--3---------- C3-------------
    C?--4---------- C?--4---------1 C?--6---------- C?--7----------
    Ca--1---------- Ca--2---------- Ca--2---------1 Ca--3----------
    Ca--4---------- Ca--5---------- Ca--6---------- Ca--7----------
    Ca--X---------- Ca--X---------1 CdFD7---------- CdFD7---------6
    CdFP1---------- CdFP1---------6 CdFP2---------- CdFP2---------6
    CdFP3---------- CdFP3---------6 CdFP4---------- CdFP4---------6
    CdFP5---------- CdFP5---------6 CdFP6---------- CdFP6---------6
    CdFP7---------- CdFP7---------6 CdFP7---------7 CdFS1----------
    CdFS2---------- CdFS2---------6 CdFS3---------- CdFS3---------6
    CdFS4---------- CdFS4---------2 CdFS5---------- CdFS6----------
    CdFS6---------6 CdFS7---------- CdIP1---------- CdIP1---------6
    CdIP2---------- CdIP2---------6 CdIP3---------- CdIP3---------6
    CdIP4---------- CdIP4---------6 CdIP5---------- CdIP5---------6
    CdIP6---------- CdIP6---------6 CdIP7---------- CdIP7---------6
    CdIP7---------7 CdIS1---------- CdIS1---------6 CdIS2----------
    CdIS2---------6 CdIS3---------- CdIS3---------6 CdIS4----------
    CdIS4---------6 CdIS5---------- CdIS5---------6 CdIS6----------
    CdIS6---------6 CdIS7---------- CdIS7---------6 CdMP1----------
    CdMP1---------6 CdMP2---------- CdMP2---------6 CdMP3----------
    CdMP3---------6 CdMP4---------- CdMP4---------6 CdMP5----------
    CdMP5---------6 CdMP6---------- CdMP6---------6 CdMP7----------
    CdMP7---------6 CdMP7---------7 CdMS1---------- CdMS1---------6
    CdMS2---------- CdMS2---------6 CdMS3---------- CdMS3---------6
    CdMS4---------- CdMS4---------6 CdMS5---------- CdMS5---------6
    CdMS6---------- CdMS6---------6 CdMS7---------- CdMS7---------6
    CdND7---------- CdNP1---------- CdNP1---------6 CdNP2----------
    CdNP2---------6 CdNP3---------- CdNP3---------6 CdNP4----------
    CdNP4---------6 CdNP5---------- CdNP5---------6 CdNP6----------
    CdNP6---------6 CdNP7---------- CdNP7---------6 CdNP7---------7
    CdNS1---------- CdNS1---------1 CdNS1---------6 CdNS2----------
    CdNS2---------6 CdNS3---------- CdNS3---------6 CdNS4----------
    CdNS4---------1 CdNS4---------6 CdNS5---------- CdNS5---------6
    CdNS6---------- CdNS6---------6 CdNS7---------- CdNS7---------6
    CdXP1---------- CdXP1---------1 CdXP2---------- CdXP3----------
    CdXP4---------- CdXP4---------1 CdXP5---------- CdXP5---------1
    CdXP6---------- CdXP7---------- CdXS1---------- CdXS5----------
    CdYS2---------- CdYS3---------- CdYS6---------- CdYS7----------
    ChFD7---------- ChFP1---------- ChFP4---------- ChFP5----------
    ChIP1---------- ChIP5---------- ChMP1---------- ChMP5----------
    ChNP1---------- ChNP4---------- ChNP5---------- ChXP2----------
    ChXP3---------- ChXP6---------- ChXP7---------- ChYP4----------
    Cj-S1---------- Cj-S2---------- Cj-S2---------1 Cj-S3----------
    Cj-S3---------1 Cj-S4---------- Cj-S5---------- Cj-S6----------
    Cj-S6---------1 Cj-S7---------- Cj-S7---------1 Ck-P1----------
    Ck-P2---------- Ck-P3---------- Ck-P4---------- Ck-P5----------
    Ck-P6---------- Ck-P7---------- ClFD7---------- ClFD7---------6
    ClFD7---------7 ClFD7---------9 ClFS1---------- ClFS2----------
    ClFS2---------6 ClFS3---------- ClFS3---------6 ClFS4----------
    ClFS5---------- ClFS6---------- ClFS6---------6 ClFS7----------
    ClHP1---------- ClHP4---------- ClHP5---------- ClIS4----------
    ClMS4---------- ClMS4---------6 ClNP2---------- ClNS1----------
    ClNS4---------- ClNS5---------- ClXP1---------- ClXP1---------1
    ClXP1---------6 ClXP1---------7 ClXP2---------- ClXP2---------1
    ClXP2---------6 ClXP2---------7 ClXP3---------- ClXP3---------1
    ClXP3---------2 ClXP3---------6 ClXP3---------7 ClXP3---------9
    ClXP4---------- ClXP4---------1 ClXP4---------6 ClXP4---------7
    ClXP5---------- ClXP5---------6 ClXP5---------7 ClXP6----------
    ClXP6---------1 ClXP6---------2 ClXP6---------6 ClXP6---------7
    ClXP7---------- ClXP7---------1 ClXP7---------2 ClXP7---------6
    ClXP7---------7 ClXP7---------9 ClXPX---------- ClXS1----------
    ClXS1---------7 ClXS2---------- ClXS2---------7 ClXS3----------
    ClXS3---------7 ClXS4---------- ClXS4---------7 ClXS5----------
    ClXS6---------- ClXS6---------7 ClXS7---------- ClXS7---------7
    ClXSX---------- ClXXX---------- ClYP1---------- ClYP4----------
    ClYP5---------- ClYS1---------- ClYS5---------- ClZS2----------
    ClZS2---------6 ClZS3---------- ClZS3---------6 ClZS6----------
    ClZS7---------- ClZS7---------6 Cn-P2---------- Cn-P2---------1
    Cn-P3---------- Cn-P3---------1 Cn-P6---------- Cn-P6---------1
    Cn-P7---------- Cn-P7---------1 Cn-S1---------- Cn-S1---------1
    Cn-S1---------2 Cn-S1---------6 Cn-S1---------7 Cn-S4----------
    Cn-S4---------1 Cn-S4---------2 Cn-S4---------6 Cn-S4---------7
    Cn-S5---------- Cn-S5---------1 Cn-S5---------2 Cn-S5---------6
    Cn-S5---------7 Cn-SX---------- Cn-XX---------- Cn-XX---------1
    Co------------- Co------------1 CrFD7---------- CrFD7---------6
    CrFP1---------- CrFP1---------6 CrFP1---------7 CrFP2----------
    CrFP2---------6 CrFP3---------- CrFP3---------6 CrFP3---------7
    CrFP4---------- CrFP4---------6 CrFP4---------7 CrFP5----------
    CrFP5---------6 CrFP5---------7 CrFP6---------- CrFP6---------6
    CrFP7---------- CrFP7---------6 CrFP7---------7 CrFS1----------
    CrFS1---------7 CrFS2---------- CrFS2---------6 CrFS2---------7
    CrFS3---------- CrFS3---------6 CrFS3---------7 CrFS4----------
    CrFS4---------7 CrFS5---------- CrFS5---------7 CrFS6----------
    CrFS6---------6 CrFS6---------7 CrFS7---------- CrFS7---------7
    CrIP1---------- CrIP1---------6 CrIP1---------7 CrIP2----------
    CrIP2---------6 CrIP3---------- CrIP3---------6 CrIP3---------7
    CrIP4---------- CrIP4---------6 CrIP4---------7 CrIP5----------
    CrIP5---------6 CrIP5---------7 CrIP6---------- CrIP6---------6
    CrIP7---------- CrIP7---------6 CrIP7---------7 CrIS1----------
    CrIS1---------6 CrIS1---------7 CrIS2---------- CrIS2---------6
    CrIS3---------- CrIS3---------6 CrIS4---------- CrIS4---------6
    CrIS4---------7 CrIS5---------- CrIS5---------6 CrIS5---------7
    CrIS6---------- CrIS6---------6 CrIS6---------7 CrIS7----------
    CrIS7---------6 CrIS7---------7 CrMP1---------- CrMP1---------6
    CrMP1---------7 CrMP2---------- CrMP2---------6 CrMP3----------
    CrMP3---------6 CrMP3---------7 CrMP4---------- CrMP4---------6
    CrMP4---------7 CrMP5---------- CrMP5---------6 CrMP5---------7
    CrMP6---------- CrMP6---------6 CrMP7---------- CrMP7---------6
    CrMP7---------7 CrMS1---------- CrMS1---------6 CrMS1---------7
    CrMS2---------- CrMS2---------6 CrMS3---------- CrMS3---------6
    CrMS4---------- CrMS4---------6 CrMS5---------- CrMS5---------6
    CrMS5---------7 CrMS6---------- CrMS6---------6 CrMS6---------7
    CrMS7---------- CrMS7---------6 CrMS7---------7 CrND7----------
    CrNP1---------- CrNP1---------6 CrNP1---------7 CrNP2----------
    CrNP2---------6 CrNP3---------- CrNP3---------6 CrNP3---------7
    CrNP4---------- CrNP4---------6 CrNP4---------7 CrNP5----------
    CrNP5---------6 CrNP5---------7 CrNP6---------- CrNP6---------6
    CrNP7---------- CrNP7---------6 CrNP7---------7 CrNS1----------
    CrNS1---------6 CrNS1---------7 CrNS2---------- CrNS2---------6
    CrNS3---------- CrNS3---------6 CrNS4---------- CrNS4---------6
    CrNS4---------7 CrNS5---------- CrNS5---------6 CrNS5---------7
    CrNS6---------- CrNS6---------6 CrNS6---------7 CrNS7----------
    CrNS7---------6 CrNS7---------7 CrXXX---------- Cu-------------
    Cv------------- Cv------------1 Cv------------6 Cv------------7
    CwFD7---------- CwFP1---------- CwFP4---------- CwFP5----------
    CwFS1---------- CwFS2---------- CwFS3---------- CwFS4----------
    CwFS5---------- CwFS6---------- CwFS7---------- CwIP1----------
    CwIP5---------- CwIS4---------- CwMP1---------- CwMP5----------
    CwMS4---------- CwNP1---------- CwNP1---------6 CwNP4----------
    CwNP4---------6 CwNP5---------- CwNP5---------6 CwNS1----------
    CwNS4---------- CwNS5---------- CwXP2---------- CwXP3----------
    CwXP6---------- CwXP7---------- CwYP4---------- CwYS1----------
    CwYS5---------- CwZS2---------- CwZS3---------- CwZS6----------
    CwZS7---------- CyFP1---------- CyFP2---------- CyFP3----------
    CyFP4---------- CyFP5---------- CyFP6---------- CyFP7----------
    CyFP7---------6 CyFS1---------- CyFS2---------- CyFS3----------
    CyFS4---------- CyFS5---------- CyFS6---------- CyFS7----------
    CzFD7---------- CzFP1---------- CzFP4---------- CzFS1----------
    CzFS2---------- CzFS3---------- CzFS4---------- CzFS6----------
    CzFS7---------- CzIP1---------- CzIS4---------- CzMP1----------
    CzMS4---------- CzMS4---------6 CzNP1---------- CzNP1---------6
    CzNP4---------- CzNP4---------6 CzNS1---------- CzNS4----------
    CzXP2---------- CzXP3---------- CzXP6---------- CzXP7----------
    CzYP4---------- CzYS1---------- CzZS2---------- CzZS2---------6
    CzZS3---------- CzZS6---------- CzZS6---------7 CzZS7----------
    D!------------- Db------------- Db------------1 Db------------2
    Db------------3 Db------------4 Db------------5 Db------------6
    Db------------7 Db------------8 Dg-------1A---- Dg-------1A---1
    Dg-------1A---4 Dg-------1A---6 Dg-------1A---7 Dg-------1A---8
    Dg-------1N---- Dg-------1N---1 Dg-------1N---6 Dg-------1N---8
    Dg-------2A---- Dg-------2A---1 Dg-------2A---2 Dg-------2A---3
    Dg-------2A---4 Dg-------2A---5 Dg-------2A---6 Dg-------2A---7
    Dg-------2N---- Dg-------2N---1 Dg-------2N---2 Dg-------2N---3
    Dg-------2N---6 Dg-------3A---- Dg-------3A---1 Dg-------3A---2
    Dg-------3A---3 Dg-------3A---5 Dg-------3A---6 Dg-------3A---7
    Dg-------3N---- Dg-------3N---1 Dg-------3N---2 Dg-------3N---3
    Dg-------3N---6 F%------------- II------------- II------------1
    II------------6 II------------7 J^------------- J,-------------
    J*------------- J^------------1 J,------------1 J*------------1
    J^------------2 J^------------6 J,------------6 J^------------7
    J,------------7 J,------------8 J,-P---1------- J,-P---1------6
    J,-P---1------7 J,-P---2------- J,-P---2------6 J,-S---1-------
    J,-S---1------6 J,-S---1------7 J,-S---2------- J,-S---2------6
    N;------------- NNFD7-----A---- NNFD7-----N---- NNFP1-----A----
    NNFP1-----A---1 NNFP1-----A---2 NNFP1-----A---3 NNFP1-----A---4
    NNFP1-----A---6 NNFP1-----A---7 NNFP1-----A---8 NNFP1-----N----
    NNFP1-----N---1 NNFP1-----N---2 NNFP1-----N---3 NNFP1-----N---4
    NNFP1-----N---6 NNFP1-----N---7 NNFP1-----N---8 NNFP2-----A----
    NNFP2-----A---1 NNFP2-----A---2 NNFP2-----A---6 NNFP2-----A---7
    NNFP2-----A---8 NNFP2-----N---- NNFP2-----N---1 NNFP2-----N---2
    NNFP2-----N---6 NNFP2-----N---7 NNFP2-----N---8 NNFP3-----A----
    NNFP3-----A---1 NNFP3-----A---2 NNFP3-----A---6 NNFP3-----A---8
    NNFP3-----N---- NNFP3-----N---1 NNFP3-----N---2 NNFP3-----N---6
    NNFP3-----N---8 NNFP4-----A---- NNFP4-----A---1 NNFP4-----A---2
    NNFP4-----A---4 NNFP4-----A---6 NNFP4-----A---7 NNFP4-----A---8
    NNFP4-----N---- NNFP4-----N---1 NNFP4-----N---2 NNFP4-----N---4
    NNFP4-----N---6 NNFP4-----N---7 NNFP4-----N---8 NNFP5-----A----
    NNFP5-----A---1 NNFP5-----A---2 NNFP5-----A---4 NNFP5-----A---6
    NNFP5-----A---7 NNFP5-----A---8 NNFP5-----N---- NNFP5-----N---1
    NNFP5-----N---2 NNFP5-----N---4 NNFP5-----N---6 NNFP5-----N---7
    NNFP5-----N---8 NNFP6-----A---- NNFP6-----A---1 NNFP6-----A---2
    NNFP6-----A---6 NNFP6-----A---7 NNFP6-----A---8 NNFP6-----N----
    NNFP6-----N---1 NNFP6-----N---2 NNFP6-----N---6 NNFP6-----N---7
    NNFP6-----N---8 NNFP7-----A---- NNFP7-----A---1 NNFP7-----A---2
    NNFP7-----A---3 NNFP7-----A---5 NNFP7-----A---6 NNFP7-----A---7
    NNFP7-----A---8 NNFP7-----N---- NNFP7-----N---1 NNFP7-----N---2
    NNFP7-----N---3 NNFP7-----N---5 NNFP7-----N---6 NNFP7-----N---7
    NNFP7-----N---8 NNFPX-----A---- NNFPX-----A---8 NNFPX-----N----
    NNFPX-----N---8 NNFS1-----A---- NNFS1-----A---1 NNFS1-----A---2
    NNFS1-----A---4 NNFS1-----A---6 NNFS1-----A---7 NNFS1-----A---8
    NNFS1-----N---- NNFS1-----N---1 NNFS1-----N---2 NNFS1-----N---4
    NNFS1-----N---6 NNFS1-----N---7 NNFS1-----N---8 NNFS2-----A----
    NNFS2-----A---1 NNFS2-----A---2 NNFS2-----A---6 NNFS2-----A---8
    NNFS2-----N---- NNFS2-----N---1 NNFS2-----N---2 NNFS2-----N---6
    NNFS2-----N---8 NNFS3-----A---- NNFS3-----A---1 NNFS3-----A---2
    NNFS3-----A---4 NNFS3-----A---6 NNFS3-----A---8 NNFS3-----N----
    NNFS3-----N---1 NNFS3-----N---2 NNFS3-----N---4 NNFS3-----N---6
    NNFS3-----N---8 NNFS4-----A---- NNFS4-----A---1 NNFS4-----A---2
    NNFS4-----A---4 NNFS4-----A---6 NNFS4-----A---7 NNFS4-----A---8
    NNFS4-----N---- NNFS4-----N---1 NNFS4-----N---2 NNFS4-----N---4
    NNFS4-----N---6 NNFS4-----N---7 NNFS4-----N---8 NNFS5-----A----
    NNFS5-----A---1 NNFS5-----A---2 NNFS5-----A---6 NNFS5-----A---7
    NNFS5-----A---8 NNFS5-----N---- NNFS5-----N---1 NNFS5-----N---2
    NNFS5-----N---6 NNFS5-----N---7 NNFS5-----N---8 NNFS6-----A----
    NNFS6-----A---1 NNFS6-----A---2 NNFS6-----A---3 NNFS6-----A---6
    NNFS6-----A---8 NNFS6-----N---- NNFS6-----N---1 NNFS6-----N---2
    NNFS6-----N---3 NNFS6-----N---6 NNFS6-----N---8 NNFS7-----A----
    NNFS7-----A---1 NNFS7-----A---2 NNFS7-----A---3 NNFS7-----A---6
    NNFS7-----A---8 NNFS7-----N---- NNFS7-----N---1 NNFS7-----N---2
    NNFS7-----N---3 NNFS7-----N---6 NNFS7-----N---8 NNFSX-----A----
    NNFSX-----A---1 NNFSX-----A---6 NNFSX-----A---8 NNFSX-----N----
    NNFSX-----N---1 NNFSX-----N---6 NNFSX-----N---8 NNFXX-----A----
    NNFXX-----A---1 NNFXX-----A---2 NNFXX-----A---6 NNFXX-----A---8
    NNFXX-----A---9 NNFXX-----N---- NNFXX-----N---1 NNFXX-----N---2
    NNFXX-----N---6 NNFXX-----N---8 NNFXX-----N---9 NNIP1-----A----
    NNIP1-----A---1 NNIP1-----A---2 NNIP1-----A---3 NNIP1-----A---6
    NNIP1-----A---7 NNIP1-----A---8 NNIP1-----A---9 NNIP1-----N----
    NNIP1-----N---1 NNIP1-----N---2 NNIP1-----N---3 NNIP1-----N---6
    NNIP1-----N---8 NNIP1-----N---9 NNIP2-----A---- NNIP2-----A---1
    NNIP2-----A---2 NNIP2-----A---3 NNIP2-----A---6 NNIP2-----A---7
    NNIP2-----A---8 NNIP2-----A---9 NNIP2-----N---- NNIP2-----N---1
    NNIP2-----N---2 NNIP2-----N---3 NNIP2-----N---6 NNIP2-----N---8
    NNIP2-----N---9 NNIP3-----A---- NNIP3-----A---1 NNIP3-----A---2
    NNIP3-----A---6 NNIP3-----A---7 NNIP3-----A---8 NNIP3-----A---9
    NNIP3-----N---- NNIP3-----N---1 NNIP3-----N---2 NNIP3-----N---6
    NNIP3-----N---7 NNIP3-----N---8 NNIP3-----N---9 NNIP4-----A----
    NNIP4-----A---1 NNIP4-----A---2 NNIP4-----A---3 NNIP4-----A---6
    NNIP4-----A---7 NNIP4-----A---8 NNIP4-----A---9 NNIP4-----N----
    NNIP4-----N---1 NNIP4-----N---2 NNIP4-----N---3 NNIP4-----N---6
    NNIP4-----N---8 NNIP4-----N---9 NNIP5-----A---- NNIP5-----A---1
    NNIP5-----A---2 NNIP5-----A---3 NNIP5-----A---6 NNIP5-----A---8
    NNIP5-----A---9 NNIP5-----N---- NNIP5-----N---1 NNIP5-----N---2
    NNIP5-----N---3 NNIP5-----N---6 NNIP5-----N---8 NNIP5-----N---9
    NNIP6-----A---- NNIP6-----A---1 NNIP6-----A---2 NNIP6-----A---3
    NNIP6-----A---4 NNIP6-----A---6 NNIP6-----A---8 NNIP6-----A---9
    NNIP6-----N---- NNIP6-----N---1 NNIP6-----N---2 NNIP6-----N---3
    NNIP6-----N---4 NNIP6-----N---6 NNIP6-----N---8 NNIP6-----N---9
    NNIP7-----A---- NNIP7-----A---1 NNIP7-----A---2 NNIP7-----A---6
    NNIP7-----A---7 NNIP7-----A---8 NNIP7-----A---9 NNIP7-----N----
    NNIP7-----N---1 NNIP7-----N---2 NNIP7-----N---6 NNIP7-----N---7
    NNIP7-----N---8 NNIP7-----N---9 NNIPX-----A---- NNIPX-----A---1
    NNIPX-----A---8 NNIPX-----N---- NNIPX-----N---1 NNIPX-----N---8
    NNIS1-----A---- NNIS1-----A---1 NNIS1-----A---2 NNIS1-----A---5
    NNIS1-----A---6 NNIS1-----A---8 NNIS1-----N---- NNIS1-----N---1
    NNIS1-----N---2 NNIS1-----N---5 NNIS1-----N---6 NNIS1-----N---8
    NNIS2-----A---- NNIS2-----A---1 NNIS2-----A---2 NNIS2-----A---3
    NNIS2-----A---4 NNIS2-----A---5 NNIS2-----A---6 NNIS2-----A---7
    NNIS2-----A---8 NNIS2-----A---9 NNIS2-----N---- NNIS2-----N---1
    NNIS2-----N---2 NNIS2-----N---3 NNIS2-----N---4 NNIS2-----N---5
    NNIS2-----N---6 NNIS2-----N---7 NNIS2-----N---8 NNIS2-----N---9
    NNIS3-----A---- NNIS3-----A---1 NNIS3-----A---2 NNIS3-----A---5
    NNIS3-----A---6 NNIS3-----A---7 NNIS3-----A---8 NNIS3-----A---9
    NNIS3-----N---- NNIS3-----N---1 NNIS3-----N---2 NNIS3-----N---5
    NNIS3-----N---6 NNIS3-----N---8 NNIS3-----N---9 NNIS4-----A----
    NNIS4-----A---1 NNIS4-----A---2 NNIS4-----A---4 NNIS4-----A---6
    NNIS4-----A---7 NNIS4-----A---8 NNIS4-----N---- NNIS4-----N---1
    NNIS4-----N---2 NNIS4-----N---4 NNIS4-----N---6 NNIS4-----N---7
    NNIS4-----N---8 NNIS5-----A---- NNIS5-----A---1 NNIS5-----A---2
    NNIS5-----A---5 NNIS5-----A---6 NNIS5-----A---8 NNIS5-----A---9
    NNIS5-----N---- NNIS5-----N---1 NNIS5-----N---2 NNIS5-----N---5
    NNIS5-----N---6 NNIS5-----N---8 NNIS5-----N---9 NNIS6-----A----
    NNIS6-----A---1 NNIS6-----A---2 NNIS6-----A---4 NNIS6-----A---5
    NNIS6-----A---6 NNIS6-----A---7 NNIS6-----A---8 NNIS6-----A---9
    NNIS6-----N---- NNIS6-----N---1 NNIS6-----N---2 NNIS6-----N---4
    NNIS6-----N---5 NNIS6-----N---6 NNIS6-----N---7 NNIS6-----N---8
    NNIS6-----N---9 NNIS7-----A---- NNIS7-----A---1 NNIS7-----A---2
    NNIS7-----A---6 NNIS7-----A---8 NNIS7-----A---9 NNIS7-----N----
    NNIS7-----N---1 NNIS7-----N---2 NNIS7-----N---6 NNIS7-----N---8
    NNIS7-----N---9 NNISX-----A---- NNISX-----A---1 NNISX-----A---6
    NNISX-----A---8 NNISX-----N---- NNISX-----N---1 NNISX-----N---6
    NNISX-----N---8 NNIXX-----A---- NNIXX-----A---1 NNIXX-----A---8
    NNIXX-----A---9 NNIXX-----N---- NNIXX-----N---1 NNIXX-----N---8
    NNMP1-----A---- NNMP1-----A---1 NNMP1-----A---2 NNMP1-----A---3
    NNMP1-----A---6 NNMP1-----A---7 NNMP1-----A---8 NNMP1-----N----
    NNMP1-----N---1 NNMP1-----N---2 NNMP1-----N---3 NNMP1-----N---6
    NNMP1-----N---7 NNMP1-----N---8 NNMP2-----A---- NNMP2-----A---1
    NNMP2-----A---2 NNMP2-----A---4 NNMP2-----A---6 NNMP2-----A---8
    NNMP2-----N---- NNMP2-----N---1 NNMP2-----N---2 NNMP2-----N---4
    NNMP2-----N---6 NNMP2-----N---8 NNMP3-----A---- NNMP3-----A---1
    NNMP3-----A---2 NNMP3-----A---6 NNMP3-----A---7 NNMP3-----A---8
    NNMP3-----N---- NNMP3-----N---1 NNMP3-----N---2 NNMP3-----N---6
    NNMP3-----N---7 NNMP3-----N---8 NNMP4-----A---- NNMP4-----A---1
    NNMP4-----A---2 NNMP4-----A---6 NNMP4-----A---7 NNMP4-----A---8
    NNMP4-----N---- NNMP4-----N---1 NNMP4-----N---2 NNMP4-----N---6
    NNMP4-----N---7 NNMP4-----N---8 NNMP5-----A---- NNMP5-----A---1
    NNMP5-----A---2 NNMP5-----A---3 NNMP5-----A---5 NNMP5-----A---6
    NNMP5-----A---7 NNMP5-----A---8 NNMP5-----N---- NNMP5-----N---1
    NNMP5-----N---2 NNMP5-----N---3 NNMP5-----N---5 NNMP5-----N---6
    NNMP5-----N---7 NNMP5-----N---8 NNMP6-----A---- NNMP6-----A---1
    NNMP6-----A---2 NNMP6-----A---6 NNMP6-----A---7 NNMP6-----A---8
    NNMP6-----N---- NNMP6-----N---1 NNMP6-----N---2 NNMP6-----N---6
    NNMP6-----N---7 NNMP6-----N---8 NNMP7-----A---- NNMP7-----A---1
    NNMP7-----A---2 NNMP7-----A---6 NNMP7-----A---7 NNMP7-----A---8
    NNMP7-----N---- NNMP7-----N---1 NNMP7-----N---2 NNMP7-----N---6
    NNMP7-----N---7 NNMP7-----N---8 NNMPX-----A---- NNMPX-----A---8
    NNMPX-----N---- NNMPX-----N---8 NNMS1-----A---- NNMS1-----A---1
    NNMS1-----A---2 NNMS1-----A---3 NNMS1-----A---6 NNMS1-----A---7
    NNMS1-----A---8 NNMS1-----N---- NNMS1-----N---1 NNMS1-----N---2
    NNMS1-----N---3 NNMS1-----N---6 NNMS1-----N---7 NNMS1-----N---8
    NNMS2-----A---- NNMS2-----A---1 NNMS2-----A---2 NNMS2-----A---3
    NNMS2-----A---6 NNMS2-----A---7 NNMS2-----A---8 NNMS2-----N----
    NNMS2-----N---1 NNMS2-----N---2 NNMS2-----N---3 NNMS2-----N---6
    NNMS2-----N---7 NNMS2-----N---8 NNMS3-----A---- NNMS3-----A---1
    NNMS3-----A---2 NNMS3-----A---3 NNMS3-----A---6 NNMS3-----A---7
    NNMS3-----A---8 NNMS3-----N---- NNMS3-----N---1 NNMS3-----N---2
    NNMS3-----N---3 NNMS3-----N---6 NNMS3-----N---7 NNMS3-----N---8
    NNMS4-----A---- NNMS4-----A---1 NNMS4-----A---2 NNMS4-----A---4
    NNMS4-----A---6 NNMS4-----A---7 NNMS4-----A---8 NNMS4-----N----
    NNMS4-----N---1 NNMS4-----N---2 NNMS4-----N---4 NNMS4-----N---6
    NNMS4-----N---7 NNMS4-----N---8 NNMS5-----A---- NNMS5-----A---1
    NNMS5-----A---2 NNMS5-----A---3 NNMS5-----A---4 NNMS5-----A---5
    NNMS5-----A---6 NNMS5-----A---7 NNMS5-----A---8 NNMS5-----N----
    NNMS5-----N---1 NNMS5-----N---2 NNMS5-----N---3 NNMS5-----N---4
    NNMS5-----N---5 NNMS5-----N---6 NNMS5-----N---7 NNMS5-----N---8
    NNMS6-----A---- NNMS6-----A---1 NNMS6-----A---2 NNMS6-----A---3
    NNMS6-----A---6 NNMS6-----A---7 NNMS6-----A---8 NNMS6-----N----
    NNMS6-----N---1 NNMS6-----N---2 NNMS6-----N---3 NNMS6-----N---6
    NNMS6-----N---7 NNMS6-----N---8 NNMS7-----A---- NNMS7-----A---1
    NNMS7-----A---2 NNMS7-----A---6 NNMS7-----A---7 NNMS7-----A---8
    NNMS7-----N---- NNMS7-----N---1 NNMS7-----N---2 NNMS7-----N---6
    NNMS7-----N---7 NNMS7-----N---8 NNMSX-----A---- NNMSX-----A---1
    NNMSX-----A---8 NNMSX-----N---- NNMSX-----N---1 NNMSX-----N---8
    NNMXX-----A---- NNMXX-----A---1 NNMXX-----A---8 NNMXX-----A---9
    NNMXX-----N---- NNMXX-----N---1 NNMXX-----N---8 NNND7-----A----
    NNND7-----N---- NNNP1-----A---- NNNP1-----A---1 NNNP1-----A---2
    NNNP1-----A---3 NNNP1-----A---6 NNNP1-----A---8 NNNP1-----N----
    NNNP1-----N---1 NNNP1-----N---2 NNNP1-----N---3 NNNP1-----N---6
    NNNP1-----N---8 NNNP2-----A---- NNNP2-----A---1 NNNP2-----A---2
    NNNP2-----A---3 NNNP2-----A---6 NNNP2-----A---8 NNNP2-----N----
    NNNP2-----N---1 NNNP2-----N---2 NNNP2-----N---3 NNNP2-----N---6
    NNNP2-----N---8 NNNP3-----A---- NNNP3-----A---1 NNNP3-----A---2
    NNNP3-----A---3 NNNP3-----A---6 NNNP3-----A---7 NNNP3-----A---8
    NNNP3-----N---- NNNP3-----N---1 NNNP3-----N---2 NNNP3-----N---3
    NNNP3-----N---6 NNNP3-----N---7 NNNP3-----N---8 NNNP4-----A----
    NNNP4-----A---1 NNNP4-----A---2 NNNP4-----A---3 NNNP4-----A---6
    NNNP4-----A---8 NNNP4-----N---- NNNP4-----N---1 NNNP4-----N---2
    NNNP4-----N---3 NNNP4-----N---6 NNNP4-----N---8 NNNP5-----A----
    NNNP5-----A---1 NNNP5-----A---2 NNNP5-----A---3 NNNP5-----A---6
    NNNP5-----A---8 NNNP5-----N---- NNNP5-----N---1 NNNP5-----N---2
    NNNP5-----N---3 NNNP5-----N---6 NNNP5-----N---8 NNNP6-----A----
    NNNP6-----A---1 NNNP6-----A---2 NNNP6-----A---3 NNNP6-----A---6
    NNNP6-----A---8 NNNP6-----N---- NNNP6-----N---1 NNNP6-----N---2
    NNNP6-----N---3 NNNP6-----N---6 NNNP6-----N---8 NNNP7-----A----
    NNNP7-----A---1 NNNP7-----A---2 NNNP7-----A---3 NNNP7-----A---6
    NNNP7-----A---7 NNNP7-----A---8 NNNP7-----N---- NNNP7-----N---1
    NNNP7-----N---2 NNNP7-----N---3 NNNP7-----N---6 NNNP7-----N---7
    NNNP7-----N---8 NNNPX-----A---- NNNPX-----A---1 NNNPX-----A---8
    NNNPX-----N---- NNNPX-----N---1 NNNPX-----N---8 NNNS1-----A----
    NNNS1-----A---1 NNNS1-----A---2 NNNS1-----A---6 NNNS1-----A---8
    NNNS1-----N---- NNNS1-----N---1 NNNS1-----N---2 NNNS1-----N---6
    NNNS1-----N---8 NNNS2-----A---- NNNS2-----A---1 NNNS2-----A---2
    NNNS2-----A---3 NNNS2-----A---4 NNNS2-----A---6 NNNS2-----A---8
    NNNS2-----N---- NNNS2-----N---1 NNNS2-----N---2 NNNS2-----N---3
    NNNS2-----N---4 NNNS2-----N---6 NNNS2-----N---8 NNNS3-----A----
    NNNS3-----A---1 NNNS3-----A---2 NNNS3-----A---3 NNNS3-----A---6
    NNNS3-----A---8 NNNS3-----N---- NNNS3-----N---1 NNNS3-----N---2
    NNNS3-----N---3 NNNS3-----N---6 NNNS3-----N---8 NNNS4-----A----
    NNNS4-----A---1 NNNS4-----A---2 NNNS4-----A---6 NNNS4-----A---8
    NNNS4-----N---- NNNS4-----N---1 NNNS4-----N---2 NNNS4-----N---6
    NNNS4-----N---8 NNNS5-----A---- NNNS5-----A---1 NNNS5-----A---2
    NNNS5-----A---6 NNNS5-----A---8 NNNS5-----N---- NNNS5-----N---1
    NNNS5-----N---2 NNNS5-----N---6 NNNS5-----N---8 NNNS6-----A----
    NNNS6-----A---1 NNNS6-----A---2 NNNS6-----A---3 NNNS6-----A---4
    NNNS6-----A---6 NNNS6-----A---7 NNNS6-----A---8 NNNS6-----N----
    NNNS6-----N---1 NNNS6-----N---2 NNNS6-----N---3 NNNS6-----N---4
    NNNS6-----N---6 NNNS6-----N---7 NNNS6-----N---8 NNNS7-----A----
    NNNS7-----A---1 NNNS7-----A---2 NNNS7-----A---6 NNNS7-----A---8
    NNNS7-----N---- NNNS7-----N---1 NNNS7-----N---2 NNNS7-----N---6
    NNNS7-----N---8 NNNSX-----A---- NNNSX-----A---1 NNNSX-----A---6
    NNNSX-----A---8 NNNSX-----N---- NNNSX-----N---1 NNNSX-----N---6
    NNNSX-----N---8 NNNXX-----A---- NNNXX-----A---1 NNNXX-----A---2
    NNNXX-----A---6 NNNXX-----A---8 NNNXX-----A---9 NNNXX-----N----
    NNNXX-----N---1 NNNXX-----N---2 NNNXX-----N---6 NNNXX-----N---8
    NNNXX-----N---9 NNXPX-----A---- NNXPX-----N---- NNXS1-----A----
    NNXS1-----N---- NNXSX-----A---- NNXSX-----N---- NNXXX-----A----
    NNXXX-----A---1 NNXXX-----A---6 NNXXX-----A---8 NNXXX-----N----
    NNXXX-----N---1 NNXXX-----N---6 NNXXX-----N---8 P0-------------
    P1FD7FS3------- P1FD7FS3------2 P1FSXFS3------- P1FSXFS3------2
    P1IS4FS3------- P1IS4FS3------2 P1MS4FS3------- P1MS4FS3------2
    P1NS4FS3------- P1NS4FS3------2 P1XP1FS3------- P1XP1FS3------2
    P1XP2FS3------- P1XP2FS3------2 P1XP3FS3------- P1XP3FS3------2
    P1XP4FS3------- P1XP4FS3------2 P1XP6FS3------- P1XP6FS3------2
    P1XP7FS3------- P1XP7FS3------2 P1XXXXP3------- P1XXXXP3------2
    P1XXXZS3------- P1XXXZS3------2 P1ZS1FS3------- P1ZS1FS3------2
    P1ZS2FS3------- P1ZS2FS3------2 P1ZS3FS3------- P1ZS3FS3------2
    P1ZS6FS3------- P1ZS6FS3------2 P1ZS7FS3------- P1ZS7FS3------2
    P4FD7---------- P4FD7---------6 P4FP1---------- P4FP1---------6
    P4FP4---------- P4FP4---------6 P4FP5---------- P4FP5---------6
    P4FS1---------- P4FS1---------6 P4FS2---------- P4FS2---------6
    P4FS3---------- P4FS3---------6 P4FS4---------- P4FS4---------6
    P4FS5---------- P4FS5---------6 P4FS6---------- P4FS6---------6
    P4FS7---------- P4FS7---------6 P4IP1---------- P4IP1---------6
    P4IP5---------- P4IP5---------6 P4IS4---------- P4IS4---------6
    P4IS4---------7 P4MP1---------- P4MP1---------6 P4MP5----------
    P4MP5---------6 P4MS4---------- P4MS4---------6 P4MS4---------7
    P4NP1---------- P4NP1---------6 P4NP1---------7 P4NP4----------
    P4NP4---------6 P4NP5---------- P4NP5---------6 P4NS1----------
    P4NS1---------6 P4NS1---------7 P4NS4---------- P4NS4---------6
    P4NS4---------7 P4NS5---------- P4NS5---------6 P4XD7----------
    P4XP1---------6 P4XP1---------7 P4XP2---------- P4XP2---------6
    P4XP3---------- P4XP3---------6 P4XP3---------7 P4XP4---------6
    P4XP4---------7 P4XP6---------- P4XP6---------6 P4XP7----------
    P4XP7---------6 P4XP7---------7 P4XXX---------- P4YP4----------
    P4YP4---------6 P4YP5---------- P4YS1---------- P4YS1---------6
    P4YS1---------7 P4YS2---------- P4YS3---------- P4YS5----------
    P4YS5---------6 P4ZS2---------- P4ZS2---------6 P4ZS2---------7
    P4ZS3---------- P4ZS3---------6 P4ZS3---------7 P4ZS6----------
    P4ZS6---------6 P4ZS6---------7 P4ZS7---------- P4ZS7---------6
    P4ZS7---------7 P5FS2--3------- P5FS3--3------- P5FS4--3-------
    P5FS4--3------6 P5FS6--3------- P5FS7--3------- P5NS4--3-------
    P5XP2--3------- P5XP3--3------- P5XP4--3------- P5XP6--3-------
    P5XP7--3------- P5XP7--3------6 P5ZS2--3------- P5ZS2--3------1
    P5ZS2--3-----d- P5ZS2--3-----n- P5ZS2--3-----o- P5ZS2--3-----p-
    P5ZS2--3-----z- P5ZS3--3------- P5ZS4--3------- P5ZS4--3------1
    P5ZS6--3------- P5ZS6--3------6 P5ZS7--3------- P6-X2----------
    P6-X3---------- P6-X4---------- P6-X6---------- P6-X7----------
    P7-S3---------- P7-S3--2------- P7-S4---------- P7-S4--2-------
    P7-X3---------- P7-X4---------- P8FD7---------- P8FD7---------6
    P8FP1---------1 P8FP4---------1 P8FS1---------1 P8FS2----------
    P8FS2---------1 P8FS2---------6 P8FS3---------- P8FS3---------1
    P8FS3---------6 P8FS4---------- P8FS4---------1 P8FS4---------6
    P8FS5---------1 P8FS6---------- P8FS6---------1 P8FS6---------6
    P8FS7---------- P8FS7---------1 P8HP1---------- P8HP5----------
    P8HP5---------7 P8HS1---------- P8HS5---------- P8IP1----------
    P8IP1---------1 P8IP1---------7 P8IP5---------- P8IP5---------1
    P8IP5---------7 P8IS4---------- P8IS4---------6 P8MP1----------
    P8MP1---------1 P8MP5---------- P8MP5---------1 P8MS4----------
    P8MS4---------6 P8NP1---------1 P8NP4---------1 P8NP5---------1
    P8NS1---------1 P8NS2---------- P8NS4---------- P8NS4---------1
    P8NS4---------6 P8NS5---------1 P8XP2---------- P8XP2---------6
    P8XP3---------- P8XP3---------6 P8XP4---------- P8XP4---------7
    P8XP6---------- P8XP6---------6 P8XP7---------- P8YP4---------1
    P8YP4---------6 P8YS1---------- P8YS1---------6 P8YS5----------
    P8YS5---------6 P8ZS2---------- P8ZS2---------6 P8ZS3----------
    P8ZS3---------6 P8ZS6---------- P8ZS6---------6 P8ZS6---------7
    P8ZS7---------- P8ZS7---------6 P9FS2---------- P9FS2---------2
    P9FS3---------- P9FS3---------2 P9FS4---------- P9FS4---------2
    P9FS6---------- P9FS6---------2 P9FS7---------- P9FS7---------2
    P9NS4---------- P9NS4---------2 P9XP2---------- P9XP2---------2
    P9XP3---------- P9XP3---------2 P9XP4---------- P9XP4---------2
    P9XP6---------- P9XP6---------2 P9XP7---------- P9XP7---------2
    P9ZS2---------- P9ZS2---------1 P9ZS2---------2 P9ZS2---------3
    P9ZS3---------- P9ZS3---------2 P9ZS4---------- P9ZS4---------1
    P9ZS4---------2 P9ZS4---------3 P9ZS6---------- P9ZS6---------2
    P9ZS7---------- P9ZS7---------2 PDFD7---------- PDFD7---------2
    PDFD7---------5 PDFD7---------6 PDFD7---------7 PDFP1----------
    PDFP1---------1 PDFP1---------5 PDFP1---------6 PDFP1---------7
    PDFP2---------- PDFP2---------1 PDFP3---------- PDFP3---------1
    PDFP4---------- PDFP4---------1 PDFP4---------5 PDFP4---------6
    PDFP4---------7 PDFP5---------- PDFP5---------1 PDFP6----------
    PDFP6---------1 PDFP7---------- PDFP7---------1 PDFS1----------
    PDFS1---------1 PDFS1---------5 PDFS1---------6 PDFS1---------7
    PDFS1---------8 PDFS2---------- PDFS2---------1 PDFS2---------5
    PDFS2---------6 PDFS2---------7 PDFS2---------8 PDFS3----------
    PDFS3---------1 PDFS3---------5 PDFS3---------6 PDFS3---------7
    PDFS3---------8 PDFS4---------- PDFS4---------1 PDFS4---------5
    PDFS4---------6 PDFS4---------7 PDFS4---------8 PDFS5----------
    PDFS5---------1 PDFS6---------- PDFS6---------1 PDFS6---------5
    PDFS6---------6 PDFS6---------7 PDFS6---------8 PDFS7----------
    PDFS7---------1 PDFS7---------5 PDFS7---------6 PDFS7---------8
    PDIP1---------- PDIP1---------1 PDIP1---------5 PDIP1---------6
    PDIP1---------7 PDIP2---------- PDIP2---------1 PDIP3----------
    PDIP3---------1 PDIP4---------- PDIP4---------1 PDIP4---------5
    PDIP4---------6 PDIP4---------7 PDIP5---------- PDIP5---------1
    PDIP6---------- PDIP6---------1 PDIP7---------- PDIP7---------1
    PDIS1---------- PDIS1---------8 PDIS2---------- PDIS2---------1
    PDIS2---------8 PDIS3---------- PDIS3---------1 PDIS3---------8
    PDIS4---------- PDIS4---------1 PDIS4---------5 PDIS4---------6
    PDIS4---------7 PDIS4---------8 PDIS5---------- PDIS5---------1
    PDIS6---------- PDIS6---------1 PDIS6---------8 PDIS7----------
    PDIS7---------1 PDIS7---------8 PDMP1---------- PDMP1---------1
    PDMP1---------5 PDMP1---------6 PDMP2---------- PDMP2---------1
    PDMP3---------- PDMP3---------1 PDMP4---------- PDMP4---------1
    PDMP4---------5 PDMP4---------6 PDMP4---------7 PDMP5----------
    PDMP5---------1 PDMP6---------- PDMP6---------1 PDMP7----------
    PDMP7---------1 PDMS1---------- PDMS1---------1 PDMS1---------8
    PDMS2---------- PDMS2---------1 PDMS2---------8 PDMS3----------
    PDMS3---------1 PDMS3---------8 PDMS4---------- PDMS4---------1
    PDMS4---------5 PDMS4---------6 PDMS4---------7 PDMS4---------8
    PDMS6---------8 PDMS7---------- PDMS7---------1 PDMS7---------6
    PDMS7---------8 PDNP1---------- PDNP1---------1 PDNP1---------5
    PDNP1---------6 PDNP1---------7 PDNP2---------- PDNP2---------1
    PDNP3---------- PDNP3---------1 PDNP4---------- PDNP4---------1
    PDNP4---------5 PDNP4---------6 PDNP4---------7 PDNP5----------
    PDNP5---------1 PDNP6---------- PDNP6---------1 PDNP7----------
    PDNP7---------1 PDNS1---------- PDNS1---------1 PDNS1---------2
    PDNS1---------5 PDNS1---------6 PDNS1---------7 PDNS1---------8
    PDNS2---------- PDNS2---------1 PDNS2---------8 PDNS3----------
    PDNS3---------1 PDNS3---------8 PDNS4---------- PDNS4---------1
    PDNS4---------2 PDNS4---------5 PDNS4---------6 PDNS4---------7
    PDNS4---------8 PDNS5---------- PDNS5---------1 PDNS6----------
    PDNS6---------1 PDNS6---------8 PDNS7---------- PDNS7---------1
    PDNS7---------8 PDTP1---------- PDTP4---------- PDTP5----------
    PDXP1---------6 PDXP2---------- PDXP2---------1 PDXP2---------2
    PDXP2---------5 PDXP2---------6 PDXP2---------7 PDXP3----------
    PDXP3---------1 PDXP3---------2 PDXP3---------5 PDXP3---------6
    PDXP3---------7 PDXP4---------6 PDXP6---------- PDXP6---------1
    PDXP6---------2 PDXP6---------5 PDXP6---------6 PDXP6---------7
    PDXP7---------- PDXP7---------2 PDXP7---------5 PDXP7---------6
    PDXPX---------- PDXPX---------8 PDXS1---------- PDXS1---------1
    PDXS2---------- PDXS2---------1 PDXS3---------- PDXS3---------1
    PDXS4---------- PDXS4---------1 PDXS5---------- PDXS5---------1
    PDXS6---------- PDXS6---------1 PDXS7---------- PDXS7---------1
    PDXSX---------- PDXSX---------8 PDXXX---------- PDXXX---------8
    PDYS1---------- PDYS1---------5 PDYS1---------6 PDYS1---------7
    PDYS4---------- PDZS2---------- PDZS2---------1 PDZS2---------5
    PDZS2---------6 PDZS2---------7 PDZS3---------- PDZS3---------5
    PDZS3---------6 PDZS6---------- PDZS6---------1 PDZS6---------2
    PDZS6---------5 PDZS6---------6 PDZS6---------7 PDZS7----------
    PDZS7---------5 PDZS7---------6 PDZS7---------7 PE--1----------
    PE--2---------- PE--3---------- PE--4---------- PE--6----------
    PE--7---------- PH-S2--1------- PH-S2--2------- PH-S3--1-------
    PH-S3--2------- PH-S4--1------- PH-S4--1------6 PH-S4--2-------
    PHZS2--3------- PHZS3--3------- PHZS4--3------- PJFD7----------
    PJFP1---------- PJFP4---------- PJFS1---------- PJFS1---------2
    PJFS2---------- PJFS2---------2 PJFS3---------- PJFS3---------2
    PJFS4---------- PJFS4---------2 PJFS6---------- PJFS7----------
    PJFS7---------2 PJIP1---------- PJIS4---------- PJIS4---------2
    PJMP1---------- PJMS4---------- PJMS4---------2 PJNP1----------
    PJNP4---------- PJNS1---------- PJNS1---------2 PJNS4----------
    PJNS4---------2 PJXP1---------2 PJXP2---------- PJXP2---------2
    PJXP3---------- PJXP3---------2 PJXP4---------- PJXP4---------2
    PJXP6---------- PJXP7---------- PJXP7---------2 PJYP4----------
    PJYS1---------- PJYS1---------2 PJZS2---------- PJZS2---------1
    PJZS2---------2 PJZS2---------3 PJZS3---------- PJZS3---------2
    PJZS4---------1 PJZS4---------3 PJZS6---------- PJZS7----------
    PJZS7---------2 PKM-1---------- PKM-1---------1 PKM-1---------2
    PKM-1--2------- PKM-2---------- PKM-2---------2 PKM-2--2-------
    PKM-3---------- PKM-3---------2 PKM-3--2------- PKM-4----------
    PKM-4---------2 PKM-4--2------- PKM-6---------- PKM-6---------2
    PKM-6--2------- PKM-6---------6 PKM-7---------- PKM-7---------2
    PKM-7--2------- PKM-7---------6 PLFD7---------- PLFP1----------
    PLFP1---------6 PLFP4---------- PLFP4---------6 PLFP5----------
    PLFP5---------6 PLFS1---------- PLFS1---------4 PLFS2----------
    PLFS3---------- PLFS4---------- PLFS4---------1 PLFS4---------4
    PLFS4---------6 PLFS5---------- PLFS5---------1 PLFS5---------4
    PLFS6---------- PLFS7---------- PLIP1---------- PLIP1---------6
    PLIP5---------- PLIP5---------6 PLIS4---------- PLIS4---------1
    PLIS4---------6 PLMP1---------- PLMP1---------6 PLMP1---------7
    PLMP5---------- PLMP5---------6 PLMP5---------7 PLMS2----------
    PLMS4---------- PLMS4---------6 PLNP1---------- PLNP1---------4
    PLNP1---------6 PLNP4---------- PLNP4---------4 PLNP4---------6
    PLNP5---------- PLNP5---------4 PLNP5---------6 PLNS1----------
    PLNS1---------1 PLNS1---------6 PLNS2---------6 PLNS4----------
    PLNS4---------1 PLNS4---------6 PLNS5---------- PLNS5---------1
    PLNS5---------6 PLXD7---------- PLXD7---------4 PLXD7---------6
    PLXP2---------- PLXP2---------4 PLXP2---------6 PLXP3----------
    PLXP3---------4 PLXP6---------- PLXP6---------4 PLXP6---------6
    PLXP7---------- PLXP7---------4 PLXP7---------6 PLXXX----------
    PLXXX---------8 PLYP4---------- PLYP4---------6 PLYS1----------
    PLYS1---------1 PLYS1---------6 PLYS4---------- PLYS5----------
    PLYS5---------1 PLYS5---------6 PLZS2---------- PLZS2---------3
    PLZS2---------4 PLZS2---------6 PLZS3---------- PLZS3---------4
    PLZS3---------6 PLZS6---------- PLZS6---------4 PLZS6---------6
    PLZS7---------- PLZS7---------6 PPFP1--3------- PPFP1--3------6
    PPFP2--3------- PPFP3--3------- PPFP4--3------- PPFP6--3-------
    PPFP7--3------- PPFPX--3------- PPFS1--3------- PPFS1--3------6
    PPFS2--3------- PPFS3--3------- PPFS4--3------- PPFS4--3------6
    PPFS6--3------- PPFS7--3------- PPFSX--3------- PPIP1--3-------
    PPIP1--3------6 PPIP2--3------- PPIP3--3------- PPIP4--3-------
    PPIP6--3------- PPIP7--3------- PPIS2--3------- PPIS3--3-------
    PPIS4--3------- PPIS6--3------- PPIS7--3------- PPMP1--3-------
    PPMP1--3------6 PPMP2--3------- PPMP3--3------- PPMP4--3-------
    PPMP6--3------- PPMP7--3------- PPMPX--3------- PPMS1--3-------
    PPMS2--3------- PPMS3--3------- PPMS4--3------- PPMS6--3-------
    PPMS7--3------- PPMSX--3------- PPNP1--3------- PPNP1--3------6
    PPNP2--3------- PPNP3--3------- PPNP4--3------- PPNP7--3-------
    PPNPX--3------- PPNS1--3------- PPNS1--3------6 PPNS2--3-------
    PPNS4--3------- PPNS6--3------- PPNS7--3------- PPNSX--3-------
    PP-P1--1------- PP-P1--2------- PP-P2--1------- PP-P2--2-------
    PP-P3--1------- PP-P3--2------- PP-P3--2------6 PP-P4--1-------
    PP-P4--2------- PP-P5--1------- PP-P5--2------- PP-P6--1-------
    PP-P6--2------- PP-P7--1------- PP-P7--1------6 PP-P7--2-------
    PP-P7--2------6 PP-PX--1------- PP-PX--2------- PP-S1--1-------
    PP-S1--1------6 PP-S1--2------- PP-S1--2P-AA--- PP-S2--1-------
    PP-S2--2------- PP-S3--1------- PP-S3--2------- PP-S4--1-------
    PP-S4--2------- PP-S5--2------- PP-S6--1------- PP-S6--2-------
    PP-S7--1------- PP-S7--2------- PP-SX--1------- PP-SX--2-------
    PPXP2--3------- PPXP3--3------- PPXP4--3------- PPXP7--3-------
    PPXP7--3------6 PPXS3--3------- PP-XX--2------- PPYS1--3-------
    PPYS1--3------6 PPYS2--3------- PPYS4--3------- PPZS2--3------1
    PPZS3--3------- PPZS4--3------2 PPZS7--3------- PQ--1----------
    PQ--1--2------- PQ--1---------6 PQ--2---------- PQ--2--2-------
    PQ--2---------9 PQ--3---------- PQ--3--2------- PQ--3---------9
    PQ--4---------- PQ--4--2------- PQ--4---------6 PQ--6----------
    PQ--6--2------- PQ--6---------9 PQ--7---------- PQ--7--2-------
    PQ--7---------6 PQ--7---------9 PQ--X---------- PQ--X---------9
    PSFD7FS3------- PSFD7-P1------- PSFD7-P2------- PSFD7-S1-------
    PSFD7-S1------6 PSFD7-S2------- PSFD7-S2------6 PSFP1-S1------1
    PSFP1-S2------1 PSFP4-S1------1 PSFP4-S2------1 PSFPX-P1-------
    PSFPX-S1------- PSFPX-X1------- PSFS1-S1------1 PSFS1-S2------1
    PSFS2-P1------- PSFS2-P2------- PSFS2-S1------- PSFS2-S1------1
    PSFS2-S1------6 PSFS2-S2------- PSFS2-S2------1 PSFS2-S2------6
    PSFS3-P1------- PSFS3-P2------- PSFS3-S1------- PSFS3-S1------1
    PSFS3-S1------6 PSFS3-S2------- PSFS3-S2------1 PSFS3-S2------6
    PSFS4-P1------- PSFS4-P1------6 PSFS4-P1------7 PSFS4-P2-------
    PSFS4-P2------6 PSFS4-S1------- PSFS4-S1------1 PSFS4-S1------6
    PSFS4-S2------- PSFS4-S2------1 PSFS4-S2------6 PSFS5-S1------1
    PSFS5-S2------1 PSFS6-P1------- PSFS6-P2------- PSFS6-S1-------
    PSFS6-S1------1 PSFS6-S1------6 PSFS6-S2------- PSFS6-S2------1
    PSFS6-S2------6 PSFS7-P1------- PSFS7-P2------- PSFS7-S1-------
    PSFS7-S1------1 PSFS7-S2------- PSFS7-S2------1 PSFSXFS3-------
    PSFSX-P1------- PSFSX-S1------- PSFSX-X1------- PSHP1-P1-------
    PSHP1-P2------- PSHP1-S1------- PSHP1-S2------- PSHP5-S1-------
    PSHP5-S1------7 PSHP5-S2------- PSHP5-S2------7 PSHS1-P1-------
    PSHS1-P2------- PSHS1-S1------- PSHS1-S2------- PSHS5-P1-------
    PSHS5-P2------- PSHS5-S1------- PSHS5-S2------- PSIP1-P1-------
    PSIP1-P2------- PSIP1-S1------- PSIP1-S1------1 PSIP1-S1------7
    PSIP1-S2------- PSIP1-S2------1 PSIP1-S2------7 PSIP5-S1-------
    PSIP5-S1------1 PSIP5-S1------7 PSIP5-S2------- PSIP5-S2------1
    PSIP5-S2------7 PSIPX-P1------- PSIPX-S1------- PSIPX-X1-------
    PSIS4FS3------- PSIS4-P1------- PSIS4-P2------- PSIS4-S1-------
    PSIS4-S1------6 PSIS4-S2------- PSIS4-S2------6 PSISX-P1-------
    PSISX-S1------- PSISX-X1------- PSMP1-P1------- PSMP1-P2-------
    PSMP1-S1------- PSMP1-S1------1 PSMP1-S1------7 PSMP1-S2-------
    PSMP1-S2------1 PSMP5-P1------- PSMP5-P2------- PSMP5-S1-------
    PSMP5-S1------1 PSMP5-S1------7 PSMP5-S2------- PSMP5-S2------1
    PSMPX-P1------- PSMPX-S1------- PSMPX-X1------- PSMS4FS3-------
    PSMS4-P1------- PSMS4-P2------- PSMS4-S1------- PSMS4-S1------6
    PSMS4-S2------- PSMS4-S2------6 PSMSX-P1------- PSMSX-S1-------
    PSMSX-X1------- PSNP1-S1------1 PSNP1-S2------1 PSNP4-S1------1
    PSNP4-S2------1 PSNP5-S1------1 PSNP5-S2------1 PSNPX-P1-------
    PSNPX-S1------- PSNPX-X1------- PSNS1-S1------1 PSNS1-S1------6
    PSNS1-S2------1 PSNS4FS3------- PSNS4-P1------- PSNS4-P2-------
    PSNS4-S1------- PSNS4-S1------1 PSNS4-S1------6 PSNS4-S2-------
    PSNS4-S2------1 PSNS5-S1------1 PSNS5-S1------6 PSNS5-S2------1
    PSNSX-P1------- PSNSX-S1------- PSNSX-X1------- PSXP1FS3-------
    PSXP2FS3------- PSXP2-P1------- PSXP2-P1------6 PSXP2-P2-------
    PSXP2-P2------6 PSXP2-S1------- PSXP2-S1------6 PSXP2-S2-------
    PSXP2-S2------6 PSXP3FS3------- PSXP3FS3------6 PSXP3-P1-------
    PSXP3-P2------- PSXP3-S1------- PSXP3-S1------6 PSXP3-S2-------
    PSXP3-S2------6 PSXP4FS3------- PSXP4-P1------- PSXP4-P2-------
    PSXP4-S1------- PSXP4-S1------7 PSXP4-S2------- PSXP4-S2------7
    PSXP5FS3------- PSXP6FS3------- PSXP6-P1------- PSXP6-P1------6
    PSXP6-P2------- PSXP6-P2------6 PSXP6-S1------- PSXP6-S1------6
    PSXP6-S2------- PSXP6-S2------6 PSXP7FS3------- PSXP7FS3------6
    PSXP7-P1------- PSXP7-P1------6 PSXP7-P1------7 PSXP7-P2-------
    PSXP7-P2------6 PSXP7-P2------7 PSXP7-S1------- PSXP7-S2-------
    PSXXX-S1------- PSXXXXP3------- PSXXXZS3------- PSYP4-S1------1
    PSYP4-S1------7 PSYP4-S2------1 PSYS1-P1------- PSYS1-P2-------
    PSYS1-S1------- PSYS1-S1------6 PSYS1-S2------- PSYS1-S2------6
    PSYS5-P1------- PSYS5-P2------- PSYS5-S1------- PSYS5-S1------6
    PSYS5-S2------- PSYS5-S2------6 PSZS1FS3------- PSZS2FS3-------
    PSZS2-P1------- PSZS2-P1------8 PSZS2-P2------- PSZS2-S1-------
    PSZS2-S1------6 PSZS2-S2------- PSZS2-S2------6 PSZS3FS3-------
    PSZS3-P1------- PSZS3-P2------- PSZS3-S1------- PSZS3-S1------6
    PSZS3-S2------- PSZS3-S2------6 PSZS5FS3------- PSZS6FS3-------
    PSZS6FS3------6 PSZS6-P1------- PSZS6-P1------6 PSZS6-P2-------
    PSZS6-P2------6 PSZS6-S1------- PSZS6-S1------6 PSZS6-S1------7
    PSZS6-S2------- PSZS6-S2------6 PSZS6-S2------7 PSZS7FS3-------
    PSZS7FS3------6 PSZS7-P1------- PSZS7-P1------6 PSZS7-P1------8
    PSZS7-P2------- PSZS7-P2------6 PSZS7-S1------- PSZS7-S1------6
    PSZS7-S2------- PSZS7-S2------6 PW--1---------- PW--2----------
    PW--2---------2 PW--3---------- PW--3---------2 PW--4----------
    PW--6---------- PW--6---------2 PW--6---------6 PW--7----------
    PW--7---------2 PW--7---------6 PWFD7---------- PWFD7---------6
    PWFP1---------- PWFP1---------6 PWFP4---------- PWFP4---------6
    PWFP5---------- PWFP5---------6 PWFS1---------- PWFS2----------
    PWFS2---------6 PWFS3---------- PWFS3---------6 PWFS4----------
    PWFS5---------- PWFS6---------- PWFS6---------6 PWFS7----------
    PWIP1---------- PWIP1---------6 PWIP5---------- PWIP5---------6
    PWIS4---------- PWIS4---------6 PWM-1---------- PWM-2----------
    PWM-3---------- PWM-4---------- PWM-6---------- PWM-7----------
    PWM-7---------6 PWMP1---------- PWMP1---------6 PWMP5----------
    PWMP5---------6 PWMS4---------- PWMS4---------6 PWNP1----------
    PWNP1---------6 PWNP1---------7 PWNP4---------- PWNP4---------6
    PWNP5---------- PWNP5---------6 PWNS1---------- PWNS1---------6
    PWNS4---------- PWNS4---------6 PWNS5---------- PWNS5---------6
    PW--X---------- PWXP2---------- PWXP2---------6 PWXP3----------
    PWXP3---------6 PWXP6---------- PWXP6---------6 PWXP7----------
    PWXP7---------6 PWXP7---------7 PWYP4---------- PWYP4---------6
    PWYS1---------- PWYS1---------6 PWYS5---------- PWYS5---------6
    PWZS2---------- PWZS2---------6 PWZS3---------- PWZS3---------6
    PWZS6---------- PWZS6---------6 PWZS6---------7 PWZS7----------
    PWZS7---------6 PY------------- PZ--1---------- PZ--1---------1
    PZ--1---------2 PZ--1---------4 PZ--1---------6 PZ--2----------
    PZ--2---------1 PZ--2---------2 PZ--2---------6 PZ--3----------
    PZ--3---------1 PZ--3---------2 PZ--4---------- PZ--4---------1
    PZ--4---------2 PZ--4---------4 PZ--4---------6 PZ--5----------
    PZ--5---------1 PZ--6---------- PZ--6---------1 PZ--6---------2
    PZ--6---------6 PZ--6---------7 PZ--7---------- PZ--7---------1
    PZ--7---------2 PZ--7---------6 PZFD7---------- PZFD7---------1
    PZFD7---------6 PZFP1---------- PZFP1---------1 PZFP1---------6
    PZFP4---------- PZFP4---------1 PZFP4---------6 PZFP5----------
    PZFP5---------1 PZFP5---------6 PZFS1---------- PZFS1---------1
    PZFS1---------6 PZFS2---------- PZFS2---------1 PZFS2---------6
    PZFS3---------- PZFS3---------1 PZFS3---------6 PZFS4----------
    PZFS4---------1 PZFS4---------6 PZFS5---------- PZFS5---------1
    PZFS5---------6 PZFS6---------- PZFS6---------1 PZFS6---------6
    PZFS7---------- PZFS7---------1 PZFS7---------6 PZIP1----------
    PZIP1---------1 PZIP1---------6 PZIP5---------- PZIP5---------1
    PZIP5---------6 PZIS4---------- PZIS4---------1 PZIS4---------6
    PZIS6---------7 PZM-1---------- PZM-1---------1 PZM-1---------2
    PZM-2---------- PZM-2---------1 PZM-3---------- PZM-3---------1
    PZM-4---------- PZM-4---------1 PZM-5---------- PZM-5---------1
    PZM-6---------- PZM-6---------1 PZM-7---------- PZM-7---------1
    PZM-7---------6 PZMP1---------- PZMP1---------1 PZMP1---------6
    PZMP1---------7 PZMP5---------- PZMP5---------1 PZMP5---------6
    PZMS4---------- PZMS4---------1 PZMS4---------6 PZMS6---------7
    PZNP1---------- PZNP1---------1 PZNP1---------6 PZNP4----------
    PZNP4---------1 PZNP4---------6 PZNP5---------- PZNP5---------1
    PZNP5---------6 PZNS1---------- PZNS1---------1 PZNS1---------6
    PZNS4---------- PZNS4---------1 PZNS4---------6 PZNS5----------
    PZNS5---------1 PZNS5---------6 PZNS6---------7 PZTP1----------
    PZTP2---------- PZTP3---------- PZTP4---------- PZTP5----------
    PZTP6---------- PZTP7---------- PZ--X---------- PZXP2----------
    PZXP2---------1 PZXP2---------6 PZXP3---------- PZXP3---------1
    PZXP3---------6 PZXP6---------- PZXP6---------1 PZXP6---------6
    PZXP7---------- PZXP7---------1 PZXP7---------6 PZXP7---------7
    PZXXX---------- PZYP4---------- PZYP4---------1 PZYP4---------6
    PZYS1---------- PZYS1---------1 PZYS1---------6 PZYS5----------
    PZYS5---------1 PZYS5---------6 PZZS2---------- PZZS2---------1
    PZZS2---------6 PZZS3---------- PZZS3---------1 PZZS3---------6
    PZZS6---------- PZZS6---------1 PZZS6---------6 PZZS6---------7
    PZZS7---------- PZZS7---------1 PZZS7---------6 RF-------------
    RR--1---------- RR--1---------8 RR--1---------9 RR--2----------
    RR--2---------1 RR--2---------6 RR--2---------8 RR--3----------
    RR--3---------1 RR--3---------6 RR--3---------7 RR--3---------8
    RR--4---------- RR--4---------6 RR--4---------8 RR--6----------
    RR--6---------6 RR--7---------- RR--7---------8 RR--X----------
    RV--1---------- RV--2---------- RV--2---------1 RV--2---------6
    RV--3---------- RV--3---------1 RV--4---------- RV--4---------1
    RV--6---------- RV--7---------- TT------------- TT------------1
    TT------------2 TT------------3 TT------------6 TT------------7
    TT------------8 V~------------- VB-P---1F-AA--- VB-P---1F-AA--5
    VB-P---1F-AA--6 VB-P---1F-AA--7 VB-P---1F-AAB-- VB-P---1F-AAB-6
    VB-P---1F-AAI-- VB-P---1F-AAI-3 VB-P---1F-AAI-5 VB-P---1F-AAI-6
    VB-P---1F-AAI-7 VB-P---1F-AAP-- VB-P---1F-AAP-6 VB-P---1F-NA---
    VB-P---1F-NA--5 VB-P---1F-NA--6 VB-P---1F-NA--7 VB-P---1F-NAB--
    VB-P---1F-NAB-6 VB-P---1F-NAI-- VB-P---1F-NAI-3 VB-P---1F-NAI-5
    VB-P---1F-NAI-6 VB-P---1F-NAI-7 VB-P---1F-NAP-- VB-P---1F-NAP-6
    VB-P---1P-AA--- VB-P---1P-AA--1 VB-P---1P-AA--2 VB-P---1P-AA--3
    VB-P---1P-AA--5 VB-P---1P-AA--6 VB-P---1P-AA--7 VB-P---1P-AAB--
    VB-P---1P-AAB-6 VB-P---1P-AAI-- VB-P---1P-AAI-1 VB-P---1P-AAI-2
    VB-P---1P-AAI-3 VB-P---1P-AAI-5 VB-P---1P-AAI-6 VB-P---1P-AAI-7
    VB-P---1P-AAP-- VB-P---1P-AAP-1 VB-P---1P-AAP-2 VB-P---1P-AAP-3
    VB-P---1P-AAP-5 VB-P---1P-AAP-6 VB-P---1P-AAP-7 VB-P---1P-NA---
    VB-P---1P-NA--1 VB-P---1P-NA--2 VB-P---1P-NA--3 VB-P---1P-NA--5
    VB-P---1P-NA--6 VB-P---1P-NA--7 VB-P---1P-NAB-- VB-P---1P-NAB-6
    VB-P---1P-NAI-- VB-P---1P-NAI-1 VB-P---1P-NAI-2 VB-P---1P-NAI-3
    VB-P---1P-NAI-6 VB-P---1P-NAP-- VB-P---1P-NAP-1 VB-P---1P-NAP-2
    VB-P---1P-NAP-3 VB-P---1P-NAP-5 VB-P---1P-NAP-6 VB-P---1P-NAP-7
    VB-P---2F-AA--- VB-P---2F-AA--7 VB-P---2F-AAB-- VB-P---2F-AAI--
    VB-P---2F-AAI-3 VB-P---2F-AAI-6 VB-P---2F-AAI-7 VB-P---2F-AAP--
    VB-P---2F-NA--- VB-P---2F-NA--7 VB-P---2F-NAB-- VB-P---2F-NAI--
    VB-P---2F-NAI-3 VB-P---2F-NAI-6 VB-P---2F-NAI-7 VB-P---2F-NAP--
    VB-P---2P-AA--- VB-P---2P-AA--1 VB-P---2P-AA--2 VB-P---2P-AA--3
    VB-P---2P-AA--6 VB-P---2P-AAB-- VB-P---2P-AAI-- VB-P---2P-AAI-1
    VB-P---2P-AAI-2 VB-P---2P-AAI-3 VB-P---2P-AAI-6 VB-P---2P-AAP--
    VB-P---2P-AAP-1 VB-P---2P-AAP-2 VB-P---2P-AAP-3 VB-P---2P-AAP-6
    VB-P---2P-NA--- VB-P---2P-NA--1 VB-P---2P-NA--2 VB-P---2P-NA--3
    VB-P---2P-NA--6 VB-P---2P-NAB-- VB-P---2P-NAI-- VB-P---2P-NAI-1
    VB-P---2P-NAI-2 VB-P---2P-NAI-3 VB-P---2P-NAI-6 VB-P---2P-NAP--
    VB-P---2P-NAP-1 VB-P---2P-NAP-2 VB-P---2P-NAP-3 VB-P---2P-NAP-6
    VB-P---3F-AA--- VB-P---3F-AA--1 VB-P---3F-AA--2 VB-P---3F-AA--6
    VB-P---3F-AA--7 VB-P---3F-AAB-- VB-P---3F-AAB-1 VB-P---3F-AAI--
    VB-P---3F-AAI-1 VB-P---3F-AAI-2 VB-P---3F-AAI-6 VB-P---3F-AAI-7
    VB-P---3F-AAP-- VB-P---3F-AAP-1 VB-P---3F-NA--- VB-P---3F-NA--1
    VB-P---3F-NA--2 VB-P---3F-NA--6 VB-P---3F-NA--7 VB-P---3F-NAB--
    VB-P---3F-NAB-1 VB-P---3F-NAI-- VB-P---3F-NAI-1 VB-P---3F-NAI-2
    VB-P---3F-NAI-6 VB-P---3F-NAI-7 VB-P---3F-NAP-- VB-P---3F-NAP-1
    VB-P---3P-AA-- VB-P---3P-AA--- VB-P---3P-AA--1 VB-P---3P-AA--2
    VB-P---3P-AA--3 VB-P---3P-AA--4 VB-P---3P-AA--5 VB-P---3P-AA--6
    VB-P---3P-AA--7 VB-P---3P-AAB-- VB-P---3P-AAB-1 VB-P---3P-AAB-6
    VB-P---3P-AAB-7 VB-P---3P-AAI-- VB-P---3P-AAI-1 VB-P---3P-AAI-2
    VB-P---3P-AAI-3 VB-P---3P-AAI-4 VB-P---3P-AAI-6 VB-P---3P-AAI-7
    VB-P---3P-AAP-- VB-P---3P-AAP-1 VB-P---3P-AAP-2 VB-P---3P-AAP-3
    VB-P---3P-AAP-4 VB-P---3P-AAP-6 VB-P---3P-AAP-7 VB-P---3P-NA--
    VB-P---3P-NA--- VB-P---3P-NA--1 VB-P---3P-NA--2 VB-P---3P-NA--3
    VB-P---3P-NA--4 VB-P---3P-NA--5 VB-P---3P-NA--6 VB-P---3P-NA--7
    VB-P---3P-NAB-- VB-P---3P-NAB-1 VB-P---3P-NAB-6 VB-P---3P-NAB-7
    VB-P---3P-NAI-- VB-P---3P-NAI-1 VB-P---3P-NAI-2 VB-P---3P-NAI-3
    VB-P---3P-NAI-4 VB-P---3P-NAI-6 VB-P---3P-NAI-7 VB-P---3P-NAP--
    VB-P---3P-NAP-1 VB-P---3P-NAP-2 VB-P---3P-NAP-3 VB-P---3P-NAP-4
    VB-P---3P-NAP-6 VB-P---3P-NAP-7 VB-S---1F-AA--- VB-S---1F-AA--1
    VB-S---1F-AA--7 VB-S---1F-AAB-- VB-S---1F-AAB-1 VB-S---1F-AAI--
    VB-S---1F-AAI-1 VB-S---1F-AAI-3 VB-S---1F-AAI-4 VB-S---1F-AAI-6
    VB-S---1F-AAI-7 VB-S---1F-AAP-- VB-S---1F-AAP-1 VB-S---1F-NA---
    VB-S---1F-NA--1 VB-S---1F-NA--7 VB-S---1F-NAB-- VB-S---1F-NAB-1
    VB-S---1F-NAI-- VB-S---1F-NAI-1 VB-S---1F-NAI-3 VB-S---1F-NAI-4
    VB-S---1F-NAI-6 VB-S---1F-NAI-7 VB-S---1F-NAP-- VB-S---1F-NAP-1
    VB-S---1P-AA-- VB-S---1P-AA--- VB-S---1P-AA--1 VB-S---1P-AA--2
    VB-S---1P-AA--3 VB-S---1P-AA--4 VB-S---1P-AA--6 VB-S---1P-AA--7
    VB-S---1P-AAB-- VB-S---1P-AAB-1 VB-S---1P-AAB-6 VB-S---1P-AAI--
    VB-S---1P-AAI-1 VB-S---1P-AAI-2 VB-S---1P-AAI-3 VB-S---1P-AAI-4
    VB-S---1P-AAI-6 VB-S---1P-AAI-7 VB-S---1P-AAP-- VB-S---1P-AAP-1
    VB-S---1P-AAP-2 VB-S---1P-AAP-3 VB-S---1P-AAP-4 VB-S---1P-AAP-6
    VB-S---1P-NA-- VB-S---1P-NA--- VB-S---1P-NA--1 VB-S---1P-NA--2
    VB-S---1P-NA--3 VB-S---1P-NA--4 VB-S---1P-NA--6 VB-S---1P-NA--7
    VB-S---1P-NAB-- VB-S---1P-NAB-1 VB-S---1P-NAB-6 VB-S---1P-NAI--
    VB-S---1P-NAI-1 VB-S---1P-NAI-2 VB-S---1P-NAI-3 VB-S---1P-NAI-6
    VB-S---1P-NAI-7 VB-S---1P-NAP-- VB-S---1P-NAP-1 VB-S---1P-NAP-2
    VB-S---1P-NAP-3 VB-S---1P-NAP-4 VB-S---1P-NAP-6 VB-S---2F-AA---
    VB-S---2F-AA--7 VB-S---2F-AAB-- VB-S---2F-AAI-- VB-S---2F-AAI-3
    VB-S---2F-AAI-6 VB-S---2F-AAI-7 VB-S---2F-AAP-- VB-S---2F-NA---
    VB-S---2F-NA--7 VB-S---2F-NAB-- VB-S---2F-NAI-- VB-S---2F-NAI-3
    VB-S---2F-NAI-6 VB-S---2F-NAI-7 VB-S---2F-NAP-- VB-S---2P-AA---
    VB-S---2P-AA--1 VB-S---2P-AA--2 VB-S---2P-AA--3 VB-S---2P-AA--6
    VB-S---2P-AA--7 VB-S---2P-AAB-- VB-S---2P-AAI-- VB-S---2P-AAI-1
    VB-S---2P-AAI-2 VB-S---2P-AAI-3 VB-S---2P-AAI-6 VB-S---2P-AAI-7
    VB-S---2P-AAP-- VB-S---2P-AAP-1 VB-S---2P-AAP-2 VB-S---2P-AAP-3
    VB-S---2P-AAP-6 VB-S---2P-NA--- VB-S---2P-NA--1 VB-S---2P-NA--2
    VB-S---2P-NA--3 VB-S---2P-NA--6 VB-S---2P-NAB-- VB-S---2P-NAI--
    VB-S---2P-NAI-1 VB-S---2P-NAI-2 VB-S---2P-NAI-3 VB-S---2P-NAI-6
    VB-S---2P-NAP-- VB-S---2P-NAP-1 VB-S---2P-NAP-2 VB-S---2P-NAP-3
    VB-S---2P-NAP-6 VB-S---3F-AA--- VB-S---3F-AA--7 VB-S---3F-AAB--
    VB-S---3F-AAI-- VB-S---3F-AAI-3 VB-S---3F-AAI-6 VB-S---3F-AAI-7
    VB-S---3F-AAP-- VB-S---3F-NA--- VB-S---3F-NA--7 VB-S---3F-NAB--
    VB-S---3F-NAI-- VB-S---3F-NAI-3 VB-S---3F-NAI-6 VB-S---3F-NAI-7
    VB-S---3F-NAP-- VB-S---3P-AA--- VB-S---3P-AA--1 VB-S---3P-AA--2
    VB-S---3P-AA--3 VB-S---3P-AA--4 VB-S---3P-AA--5 VB-S---3P-AA--6
    VB-S---3P-AA--7 VB-S---3P-AAB-- VB-S---3P-AAI-- VB-S---3P-AAI-1
    VB-S---3P-AAI-2 VB-S---3P-AAI-3 VB-S---3P-AAI-4 VB-S---3P-AAI-5
    VB-S---3P-AAI-6 VB-S---3P-AAI-7 VB-S---3P-AAP-- VB-S---3P-AAP-1
    VB-S---3P-AAP-2 VB-S---3P-AAP-3 VB-S---3P-AAP-6 VB-S---3P-NA---
    VB-S---3P-NA--1 VB-S---3P-NA--2 VB-S---3P-NA--3 VB-S---3P-NA--4
    VB-S---3P-NA--5 VB-S---3P-NA--6 VB-S---3P-NA--7 VB-S---3P-NAB--
    VB-S---3P-NAI-- VB-S---3P-NAI-1 VB-S---3P-NAI-2 VB-S---3P-NAI-3
    VB-S---3P-NAI-4 VB-S---3P-NAI-5 VB-S---3P-NAI-6 VB-S---3P-NAI-7
    VB-S---3P-NAP-- VB-S---3P-NAP-1 VB-S---3P-NAP-2 VB-S---3P-NAP-3
    VB-S---3P-NAP-6 VB-X---XF-AA--- VB-X---XF-NA--- VB-X---XP-AA---
    VB-X---XP-NA--- Vc------------- Vc----------I-- Vc-P---1-------
    Vc-P---1------6 Vc-P---1----I-- Vc-P---1----I-6 Vc-P---2-------
    Vc-P---2----I-- Vc-S---1------- Vc-S---1------6 Vc-S---1----I--
    Vc-S---1----I-6 Vc-S---2------- Vc-S---2----I-- VeHS------A----
    VeHS------A---1 VeHS------A---2 VeHS------A-B-- VeHS------A-I--
    VeHS------A-I-1 VeHS------A-I-2 VeHS------A-P-- VeHS------A-P-2
    VeHS------A-P-4 VeHS------A-P-6 VeHS------N---- VeHS------N---1
    VeHS------N---2 VeHS------N-B-- VeHS------N-I-- VeHS------N-I-1
    VeHS------N-I-2 VeHS------N-P-- VeHS------N-P-2 VeHS------N-P-4
    VeHS------N-P-6 VeXP------A---- VeXP------A---1 VeXP------A---2
    VeXP------A-B-- VeXP------A-I-- VeXP------A-I-1 VeXP------A-I-2
    VeXP------A-P-2 VeXP------A-P-4 VeXP------A-P-6 VeXP------N----
    VeXP------N---1 VeXP------N---2 VeXP------N-B-- VeXP------N-I--
    VeXP------N-I-1 VeXP------N-I-2 VeXP------N-P-2 VeXP------N-P-4
    VeXP------N-P-6 VeYS------A---- VeYS------A---1 VeYS------A-B--
    VeYS------A-I-- VeYS------A-I-1 VeYS------A-I-2 VeYS------A-P--
    VeYS------A-P-4 VeYS------A-P-6 VeYS------N---- VeYS------N---1
    VeYS------N-B-- VeYS------N-I-- VeYS------N-I-1 VeYS------N-I-2
    VeYS------N-P-- VeYS------N-P-4 VeYS------N-P-6 Vf--------A----
    Vf--------A---1 Vf--------A---2 Vf--------A---3 Vf--------A---4
    Vf--------A---6 Vf--------A---7 Vf--------A---8 Vf--------A---9
    Vf--------A-B-- Vf--------A-B-2 Vf--------A-B-8 Vf--------A-I--
    Vf--------A-I-1 Vf--------A-I-2 Vf--------A-I-3 Vf--------A-I-6
    Vf--------A-I-7 Vf--------A-P-- Vf--------A-P-1 Vf--------A-P-2
    Vf--------A-P-3 Vf--------A-P-4 Vf--------A-P-6 Vf--------A-P-7
    Vf--------A-P-8 Vf--------N---- Vf--------N---1 Vf--------N---2
    Vf--------N---3 Vf--------N---4 Vf--------N---6 Vf--------N---7
    Vf--------N---9 Vf--------N-B-- Vf--------N-B-2 Vf--------N-I--
    Vf--------N-I-1 Vf--------N-I-2 Vf--------N-I-3 Vf--------N-I-6
    Vf--------N-I-7 Vf--------N-P-- Vf--------N-P-1 Vf--------N-P-2
    Vf--------N-P-3 Vf--------N-P-4 Vf--------N-P-6 Vf--------N-P-7
    Vi-P---1--A---- Vi-P---1--A---1 Vi-P---1--A---2 Vi-P---1--A---3
    Vi-P---1--A---6 Vi-P---1--A-B-- Vi-P---1--A-B-2 Vi-P---1--A-I--
    Vi-P---1--A-I-1 Vi-P---1--A-I-2 Vi-P---1--A-I-3 Vi-P---1--A-I-6
    Vi-P---1--A-P-- Vi-P---1--A-P-1 Vi-P---1--A-P-2 Vi-P---1--A-P-3
    Vi-P---1--A-P-6 Vi-P---1--N---- Vi-P---1--N---1 Vi-P---1--N---2
    Vi-P---1--N---3 Vi-P---1--N---6 Vi-P---1--N-B-- Vi-P---1--N-B-2
    Vi-P---1--N-I-- Vi-P---1--N-I-1 Vi-P---1--N-I-2 Vi-P---1--N-I-3
    Vi-P---1--N-I-6 Vi-P---1--N-P-- Vi-P---1--N-P-1 Vi-P---1--N-P-2
    Vi-P---1--N-P-3 Vi-P---1--N-P-6 Vi-P---2--A---- Vi-P---2--A---1
    Vi-P---2--A---2 Vi-P---2--A---3 Vi-P---2--A---6 Vi-P---2--A-B--
    Vi-P---2--A-B-2 Vi-P---2--A-I-- Vi-P---2--A-I-1 Vi-P---2--A-I-2
    Vi-P---2--A-I-3 Vi-P---2--A-I-6 Vi-P---2--A-P-- Vi-P---2--A-P-1
    Vi-P---2--A-P-2 Vi-P---2--A-P-3 Vi-P---2--A-P-6 Vi-P---2--N----
    Vi-P---2--N---1 Vi-P---2--N---2 Vi-P---2--N---3 Vi-P---2--N---6
    Vi-P---2--N-B-- Vi-P---2--N-B-2 Vi-P---2--N-I-- Vi-P---2--N-I-1
    Vi-P---2--N-I-2 Vi-P---2--N-I-3 Vi-P---2--N-I-6 Vi-P---2--N-P--
    Vi-P---2--N-P-1 Vi-P---2--N-P-2 Vi-P---2--N-P-3 Vi-P---2--N-P-6
    Vi-P---3--A---1 Vi-P---3--A---2 Vi-P---3--A---3 Vi-P---3--A---4
    Vi-P---3--A---9 Vi-P---3--A-B-2 Vi-P---3--A-B-4 Vi-P---3--A-I-2
    Vi-P---3--A-I-3 Vi-P---3--A-I-4 Vi-P---3--A-I-5 Vi-P---3--A-I-9
    Vi-P---3--A-P-1 Vi-P---3--A-P-2 Vi-P---3--A-P-3 Vi-P---3--A-P-4
    Vi-P---3--A-P-5 Vi-P---3--N---1 Vi-P---3--N---2 Vi-P---3--N---3
    Vi-P---3--N---4 Vi-P---3--N---9 Vi-P---3--N-B-2 Vi-P---3--N-B-4
    Vi-P---3--N-I-2 Vi-P---3--N-I-3 Vi-P---3--N-I-4 Vi-P---3--N-I-5
    Vi-P---3--N-I-9 Vi-P---3--N-P-1 Vi-P---3--N-P-2 Vi-P---3--N-P-3
    Vi-P---3--N-P-4 Vi-P---3--N-P-5 Vi-S---2--A---- Vi-S---2--A---1
    Vi-S---2--A---2 Vi-S---2--A---3 Vi-S---2--A---6 Vi-S---2--A---8
    Vi-S---2--A---9 Vi-S---2--A-B-- Vi-S---2--A-B-2 Vi-S---2--A-I--
    Vi-S---2--A-I-1 Vi-S---2--A-I-2 Vi-S---2--A-I-6 Vi-S---2--A-P--
    Vi-S---2--A-P-1 Vi-S---2--A-P-2 Vi-S---2--A-P-3 Vi-S---2--A-P-6
    Vi-S---2--A-P-8 Vi-S---2--A-P-9 Vi-S---2--N---- Vi-S---2--N---1
    Vi-S---2--N---2 Vi-S---2--N---3 Vi-S---2--N---6 Vi-S---2--N---9
    Vi-S---2--N-B-- Vi-S---2--N-B-2 Vi-S---2--N-I-- Vi-S---2--N-I-1
    Vi-S---2--N-I-2 Vi-S---2--N-I-6 Vi-S---2--N-P-- Vi-S---2--N-P-1
    Vi-S---2--N-P-2 Vi-S---2--N-P-3 Vi-S---2--N-P-6 Vi-S---2--N-P-9
    Vi-S---3--A---- Vi-S---3--A---2 Vi-S---3--A---3 Vi-S---3--A---4
    Vi-S---3--A---6 Vi-S---3--A---9 Vi-S---3--A-B-2 Vi-S---3--A-B-4
    Vi-S---3--A-I-- Vi-S---3--A-I-2 Vi-S---3--A-I-4 Vi-S---3--A-I-5
    Vi-S---3--A-I-6 Vi-S---3--A-I-9 Vi-S---3--A-P-1 Vi-S---3--A-P-2
    Vi-S---3--A-P-3 Vi-S---3--A-P-4 Vi-S---3--A-P-5 Vi-S---3--A-P-6
    Vi-S---3--N---- Vi-S---3--N---2 Vi-S---3--N---3 Vi-S---3--N---4
    Vi-S---3--N---6 Vi-S---3--N---9 Vi-S---3--N-B-2 Vi-S---3--N-B-4
    Vi-S---3--N-I-- Vi-S---3--N-I-2 Vi-S---3--N-I-4 Vi-S---3--N-I-5
    Vi-S---3--N-I-6 Vi-S---3--N-I-9 Vi-S---3--N-P-1 Vi-S---3--N-P-2
    Vi-S---3--N-P-3 Vi-S---3--N-P-4 Vi-S---3--N-P-5 Vi-S---3--N-P-6
    Vi-X---2--A---- Vi-X---2--N---- VmHS------A---- VmHS------A---4
    VmHS------A-B-- VmHS------A-I-- VmHS------A-I-6 VmHS------A-P--
    VmHS------A-P-1 VmHS------A-P-2 VmHS------A-P-4 VmHS------N----
    VmHS------N---4 VmHS------N-B-- VmHS------N-I-- VmHS------N-I-6
    VmHS------N-P-- VmHS------N-P-1 VmHS------N-P-2 VmHS------N-P-4
    VmXP------A---- VmXP------A---2 VmXP------A---4 VmXP------A-B--
    VmXP------A-I-- VmXP------A-I-2 VmXP------A-I-6 VmXP------A-P--
    VmXP------A-P-1 VmXP------A-P-2 VmXP------A-P-4 VmXP------N----
    VmXP------N---2 VmXP------N---4 VmXP------N-B-- VmXP------N-I--
    VmXP------N-I-2 VmXP------N-I-6 VmXP------N-P-- VmXP------N-P-1
    VmXP------N-P-2 VmXP------N-P-4 VmYS------A---- VmYS------A---4
    VmYS------A-B-- VmYS------A-I-- VmYS------A-I-6 VmYS------A-P--
    VmYS------A-P-1 VmYS------A-P-2 VmYS------A-P-4 VmYS------N----
    VmYS------N---4 VmYS------N-B-- VmYS------N-I-- VmYS------N-I-6
    VmYS------N-P-- VmYS------N-P-1 VmYS------N-P-2 VmYS------N-P-4
    VpFS---2R-AA--- VpFS---2R-AA--1 VpFS---2R-AA--6 VpFS---2R-AAB--
    VpFS---2R-AAB-1 VpFS---2R-AAI-- VpFS---2R-AAI-1 VpFS---2R-AAI-6
    VpFS---2R-AAP-- VpFS---2R-AAP-1 VpFS---2R-AAP-6 VpFS---2R-NA---
    VpFS---2R-NA--1 VpFS---2R-NA--6 VpFS---2R-NAB-- VpFS---2R-NAB-1
    VpFS---2R-NAI-- VpFS---2R-NAI-1 VpFS---2R-NAI-6 VpFS---2R-NAP--
    VpFS---2R-NAP-1 VpFS---2R-NAP-6 VpMP---XR-AA--- VpMP---XR-AA--1
    VpMP---XR-AA--2 VpMP---XR-AA--3 VpMP---XR-AA--6 VpMP---XR-AA--7
    VpMP---XR-AAB-- VpMP---XR-AAB-1 VpMP---XR-AAI-- VpMP---XR-AAI-1
    VpMP---XR-AAI-3 VpMP---XR-AAI-6 VpMP---XR-AAP-- VpMP---XR-AAP-1
    VpMP---XR-AAP-2 VpMP---XR-AAP-3 VpMP---XR-AAP-6 VpMP---XR-AAP-7
    VpMP---XR-NA--- VpMP---XR-NA--1 VpMP---XR-NA--2 VpMP---XR-NA--3
    VpMP---XR-NA--6 VpMP---XR-NA--7 VpMP---XR-NAB-- VpMP---XR-NAB-1
    VpMP---XR-NAI-- VpMP---XR-NAI-1 VpMP---XR-NAI-3 VpMP---XR-NAI-6
    VpMP---XR-NAP-- VpMP---XR-NAP-1 VpMP---XR-NAP-2 VpMP---XR-NAP-3
    VpMP---XR-NAP-6 VpMP---XR-NAP-7 VpNS---2R-AA--- VpNS---2R-AA--1
    VpNS---2R-AA--6 VpNS---2R-AAB-- VpNS---2R-AAB-1 VpNS---2R-AAI--
    VpNS---2R-AAI-1 VpNS---2R-AAI-6 VpNS---2R-AAP-- VpNS---2R-AAP-1
    VpNS---2R-AAP-6 VpNS---2R-NA--- VpNS---2R-NA--1 VpNS---2R-NA--6
    VpNS---2R-NAB-- VpNS---2R-NAB-1 VpNS---2R-NAI-- VpNS---2R-NAI-1
    VpNS---2R-NAI-6 VpNS---2R-NAP-- VpNS---2R-NAP-1 VpNS---2R-NAP-6
    VpNS---XR-AA--- VpNS---XR-AA--1 VpNS---XR-AA--2 VpNS---XR-AA--3
    VpNS---XR-AA--6 VpNS---XR-AA--7 VpNS---XR-AAB-- VpNS---XR-AAB-1
    VpNS---XR-AAI-- VpNS---XR-AAI-1 VpNS---XR-AAI-3 VpNS---XR-AAI-6
    VpNS---XR-AAP-- VpNS---XR-AAP-1 VpNS---XR-AAP-2 VpNS---XR-AAP-3
    VpNS---XR-AAP-6 VpNS---XR-AAP-7 VpNS---XR-NA--- VpNS---XR-NA--1
    VpNS---XR-NA--2 VpNS---XR-NA--3 VpNS---XR-NA--6 VpNS---XR-NA--7
    VpNS---XR-NAB-- VpNS---XR-NAB-1 VpNS---XR-NAI-- VpNS---XR-NAI-1
    VpNS---XR-NAI-3 VpNS---XR-NAI-6 VpNS---XR-NAP-- VpNS---XR-NAP-1
    VpNS---XR-NAP-2 VpNS---XR-NAP-3 VpNS---XR-NAP-6 VpNS---XR-NAP-7
    VpQW---XR-AA--- VpQW---XR-AA--1 VpQW---XR-AA--2 VpQW---XR-AA--3
    VpQW---XR-AA--6 VpQW---XR-AA--7 VpQW---XR-AAB-- VpQW---XR-AAB-1
    VpQW---XR-AAI-- VpQW---XR-AAI-1 VpQW---XR-AAI-3 VpQW---XR-AAI-6
    VpQW---XR-AAP-- VpQW---XR-AAP-1 VpQW---XR-AAP-2 VpQW---XR-AAP-3
    VpQW---XR-AAP-6 VpQW---XR-AAP-7 VpQW---XR-NA--- VpQW---XR-NA--1
    VpQW---XR-NA--2 VpQW---XR-NA--3 VpQW---XR-NA--6 VpQW---XR-NA--7
    VpQW---XR-NAB-- VpQW---XR-NAB-1 VpQW---XR-NAI-- VpQW---XR-NAI-1
    VpQW---XR-NAI-3 VpQW---XR-NAI-6 VpQW---XR-NAP-- VpQW---XR-NAP-1
    VpQW---XR-NAP-2 VpQW---XR-NAP-3 VpQW---XR-NAP-6 VpQW---XR-NAP-7
    VpTP---XR-AA--- VpTP---XR-AA--1 VpTP---XR-AA--2 VpTP---XR-AA--3
    VpTP---XR-AA--6 VpTP---XR-AA--7 VpTP---XR-AAB-- VpTP---XR-AAB-1
    VpTP---XR-AAI-- VpTP---XR-AAI-1 VpTP---XR-AAI-3 VpTP---XR-AAI-6
    VpTP---XR-AAP-- VpTP---XR-AAP-1 VpTP---XR-AAP-2 VpTP---XR-AAP-3
    VpTP---XR-AAP-6 VpTP---XR-AAP-7 VpTP---XR-NA--- VpTP---XR-NA--1
    VpTP---XR-NA--2 VpTP---XR-NA--3 VpTP---XR-NA--6 VpTP---XR-NA--7
    VpTP---XR-NAB-- VpTP---XR-NAB-1 VpTP---XR-NAI-- VpTP---XR-NAI-1
    VpTP---XR-NAI-3 VpTP---XR-NAI-6 VpTP---XR-NAP-- VpTP---XR-NAP-1
    VpTP---XR-NAP-2 VpTP---XR-NAP-3 VpTP---XR-NAP-6 VpTP---XR-NAP-7
    VpXP---XR-AA--- VpXP---XR-NA--- VpXS---XR-AA--- VpXS---XR-NA---
    VpXX---XR-AA--- VpXX---XR-NA--- VpYS---2R-AA--- VpYS---2R-AA--1
    VpYS---2R-AA--6 VpYS---2R-AAB-- VpYS---2R-AAB-1 VpYS---2R-AAI--
    VpYS---2R-AAI-1 VpYS---2R-AAI-6 VpYS---2R-AAP-- VpYS---2R-AAP-1
    VpYS---2R-NA--- VpYS---2R-NA--1 VpYS---2R-NA--6 VpYS---2R-NAB--
    VpYS---2R-NAB-1 VpYS---2R-NAI-- VpYS---2R-NAI-1 VpYS---2R-NAI-6
    VpYS---2R-NAP-- VpYS---2R-NAP-1 VpYS---XR-AA--- VpYS---XR-AA--1
    VpYS---XR-AA--2 VpYS---XR-AA--6 VpYS---XR-AA--7 VpYS---XR-AA--8
    VpYS---XR-AA--9 VpYS---XR-AAB-- VpYS---XR-AAB-1 VpYS---XR-AAB-6
    VpYS---XR-AAI-- VpYS---XR-AAI-1 VpYS---XR-AAI-6 VpYS---XR-AAP--
    VpYS---XR-AAP-1 VpYS---XR-AAP-2 VpYS---XR-AAP-6 VpYS---XR-AAP-7
    VpYS---XR-NA--- VpYS---XR-NA--1 VpYS---XR-NA--2 VpYS---XR-NA--6
    VpYS---XR-NA--7 VpYS---XR-NA--8 VpYS---XR-NAB-- VpYS---XR-NAB-1
    VpYS---XR-NAB-6 VpYS---XR-NAI-- VpYS---XR-NAI-1 VpYS---XR-NAI-6
    VpYS---XR-NAP-- VpYS---XR-NAP-1 VpYS---XR-NAP-2 VpYS---XR-NAP-6
    VpYS---XR-NAP-7 VqMP---XR-AA--2 VqMP---XR-AA--3 VqMP---XR-AAB-2
    VqMP---XR-AAB-3 VqMP---XR-AAI-2 VqMP---XR-AAI-3 VqMP---XR-AAP-2
    VqMP---XR-AAP-3 VqMP---XR-NA--2 VqMP---XR-NA--3 VqMP---XR-NAB-2
    VqMP---XR-NAB-3 VqMP---XR-NAI-2 VqMP---XR-NAI-3 VqMP---XR-NAP-2
    VqMP---XR-NAP-3 VqNS---XR-AA--2 VqNS---XR-AA--3 VqNS---XR-AAB-2
    VqNS---XR-AAB-3 VqNS---XR-AAI-2 VqNS---XR-AAI-3 VqNS---XR-AAP-2
    VqNS---XR-AAP-3 VqNS---XR-NA--2 VqNS---XR-NA--3 VqNS---XR-NAB-2
    VqNS---XR-NAB-3 VqNS---XR-NAI-2 VqNS---XR-NAI-3 VqNS---XR-NAP-2
    VqNS---XR-NAP-3 VqQW---XR-AA--2 VqQW---XR-AA--3 VqQW---XR-AAB-2
    VqQW---XR-AAB-3 VqQW---XR-AAI-2 VqQW---XR-AAI-3 VqQW---XR-AAP-2
    VqQW---XR-AAP-3 VqQW---XR-NA--2 VqQW---XR-NA--3 VqQW---XR-NAB-2
    VqQW---XR-NAB-3 VqQW---XR-NAI-2 VqQW---XR-NAI-3 VqQW---XR-NAP-2
    VqQW---XR-NAP-3 VqTP---XR-AA--2 VqTP---XR-AA--3 VqTP---XR-AAB-2
    VqTP---XR-AAB-3 VqTP---XR-AAI-2 VqTP---XR-AAI-3 VqTP---XR-AAP-2
    VqTP---XR-AAP-3 VqTP---XR-NA--2 VqTP---XR-NA--3 VqTP---XR-NAB-2
    VqTP---XR-NAB-3 VqTP---XR-NAI-2 VqTP---XR-NAI-3 VqTP---XR-NAP-2
    VqTP---XR-NAP-3 VqYS---XR-AA--2 VqYS---XR-AA--3 VqYS---XR-AAB-2
    VqYS---XR-AAB-3 VqYS---XR-AAI-2 VqYS---XR-AAI-3 VqYS---XR-AAP-2
    VqYS---XR-AAP-3 VqYS---XR-NA--2 VqYS---XR-NA--3 VqYS---XR-NAB-2
    VqYS---XR-NAB-3 VqYS---XR-NAI-2 VqYS---XR-NAI-3 VqYS---XR-NAP-2
    VqYS---XR-NAP-3 VsFS---2H-AP--- VsFS---2H-APB-- VsFS---2H-API--
    VsFS---2H-APP-- VsFS---2H-APP-1 VsFS---2H-NP--- VsFS---2H-NPB--
    VsFS---2H-NPI-- VsFS---2H-NPP-- VsFS---2H-NPP-1 VsFS4--XX-AP---
    VsFS4--XX-AP--2 VsFS4--XX-APB-- VsFS4--XX-API-- VsFS4--XX-API-2
    VsFS4--XX-APP-- VsFS4--XX-APP-1 VsFS4--XX-APP-2 VsFS4--XX-NP---
    VsFS4--XX-NP--2 VsFS4--XX-NPB-- VsFS4--XX-NPI-- VsFS4--XX-NPI-2
    VsFS4--XX-NPP-- VsFS4--XX-NPP-1 VsFS4--XX-NPP-2 VsMP---XX-AP---
    VsMP---XX-AP--2 VsMP---XX-APB-- VsMP---XX-API-- VsMP---XX-API-2
    VsMP---XX-APP-- VsMP---XX-APP-1 VsMP---XX-APP-2 VsMP---XX-NP---
    VsMP---XX-NP--2 VsMP---XX-NPB-- VsMP---XX-NPI-- VsMP---XX-NPI-2
    VsMP---XX-NPP-- VsMP---XX-NPP-1 VsMP---XX-NPP-2 VsNS---2H-AP---
    VsNS---2H-APB-- VsNS---2H-API-- VsNS---2H-APP-- VsNS---2H-APP-1
    VsNS---2H-NP--- VsNS---2H-NPB-- VsNS---2H-NPI-- VsNS---2H-NPP--
    VsNS---2H-NPP-1 VsNS---XX-AP--- VsNS---XX-AP--2 VsNS---XX-AP--6
    VsNS---XX-APB-- VsNS---XX-API-- VsNS---XX-API-2 VsNS---XX-API-6
    VsNS---XX-APP-- VsNS---XX-APP-1 VsNS---XX-APP-2 VsNS---XX-APP-6
    VsNS---XX-APP-7 VsNS---XX-NP--- VsNS---XX-NP--2 VsNS---XX-NP--6
    VsNS---XX-NPB-- VsNS---XX-NPI-- VsNS---XX-NPI-2 VsNS---XX-NPI-6
    VsNS---XX-NPP-- VsNS---XX-NPP-1 VsNS---XX-NPP-2 VsNS---XX-NPP-6
    VsNS---XX-NPP-7 VsQW---XX-AP--- VsQW---XX-AP--2 VsQW---XX-AP--6
    VsQW---XX-APB-- VsQW---XX-API-- VsQW---XX-API-2 VsQW---XX-APP--
    VsQW---XX-APP-1 VsQW---XX-APP-2 VsQW---XX-APP-6 VsQW---XX-NP---
    VsQW---XX-NP--2 VsQW---XX-NP--6 VsQW---XX-NPB-- VsQW---XX-NPI--
    VsQW---XX-NPI-2 VsQW---XX-NPP-- VsQW---XX-NPP-1 VsQW---XX-NPP-2
    VsQW---XX-NPP-6 VsTP---XX-AP--- VsTP---XX-AP--2 VsTP---XX-AP--6
    VsTP---XX-APB-- VsTP---XX-API-- VsTP---XX-API-2 VsTP---XX-APP--
    VsTP---XX-APP-1 VsTP---XX-APP-2 VsTP---XX-APP-6 VsTP---XX-NP---
    VsTP---XX-NP--2 VsTP---XX-NP--6 VsTP---XX-NPB-- VsTP---XX-NPI--
    VsTP---XX-NPI-2 VsTP---XX-NPP-- VsTP---XX-NPP-1 VsTP---XX-NPP-2
    VsTP---XX-NPP-6 VsYS---2H-AP--- VsYS---2H-API-- VsYS---2H-NP---
    VsYS---2H-NPI-- VsYS---XX-AP--- VsYS---XX-AP--2 VsYS---XX-APB--
    VsYS---XX-API-- VsYS---XX-API-2 VsYS---XX-APP-- VsYS---XX-APP-1
    VsYS---XX-APP-2 VsYS---XX-NP--- VsYS---XX-NP--2 VsYS---XX-NPB--
    VsYS---XX-NPI-- VsYS---XX-NPI-2 VsYS---XX-NPP-- VsYS---XX-NPP-1
    VsYS---XX-NPP-2 Vt-P---1F-AA--2 Vt-P---1F-AA--3 Vt-P---1F-AAB-2
    Vt-P---1F-AAB-3 Vt-P---1F-AAI-2 Vt-P---1F-AAI-3 Vt-P---1F-AAP-2
    Vt-P---1F-AAP-3 Vt-P---1F-NA--2 Vt-P---1F-NA--3 Vt-P---1F-NAB-2
    Vt-P---1F-NAB-3 Vt-P---1F-NAI-2 Vt-P---1F-NAI-3 Vt-P---1F-NAP-2
    Vt-P---1F-NAP-3 Vt-P---1P-AA--2 Vt-P---1P-AA--3 Vt-P---1P-AAB-2
    Vt-P---1P-AAB-3 Vt-P---1P-AAI-2 Vt-P---1P-AAI-3 Vt-P---1P-AAP-2
    Vt-P---1P-AAP-3 Vt-P---1P-NA--2 Vt-P---1P-NA--3 Vt-P---1P-NAB-2
    Vt-P---1P-NAB-3 Vt-P---1P-NAI-2 Vt-P---1P-NAI-3 Vt-P---1P-NAP-2
    Vt-P---1P-NAP-3 Vt-P---2F-AA--2 Vt-P---2F-AAB-2 Vt-P---2F-AAI-2
    Vt-P---2F-AAP-2 Vt-P---2F-NA--2 Vt-P---2F-NAB-2 Vt-P---2F-NAI-2
    Vt-P---2F-NAP-2 Vt-P---2P-AA--2 Vt-P---2P-AAB-2 Vt-P---2P-AAI-2
    Vt-P---2P-AAP-2 Vt-P---2P-NA--2 Vt-P---2P-NAB-2 Vt-P---2P-NAI-2
    Vt-P---2P-NAP-2 Vt-P---3F-AA--2 Vt-P---3F-AA--3 Vt-P---3F-AAB-2
    Vt-P---3F-AAB-3 Vt-P---3F-AAI-2 Vt-P---3F-AAI-3 Vt-P---3F-AAP-2
    Vt-P---3F-AAP-3 Vt-P---3F-NA--2 Vt-P---3F-NA--3 Vt-P---3F-NAB-2
    Vt-P---3F-NAB-3 Vt-P---3F-NAI-2 Vt-P---3F-NAI-3 Vt-P---3F-NAP-2
    Vt-P---3F-NAP-3 Vt-P---3P-AA--2 Vt-P---3P-AA--3 Vt-P---3P-AA--4
    Vt-P---3P-AA--9 Vt-P---3P-AAB-2 Vt-P---3P-AAB-3 Vt-P---3P-AAB-9
    Vt-P---3P-AAI-2 Vt-P---3P-AAI-3 Vt-P---3P-AAI-9 Vt-P---3P-AAP-2
    Vt-P---3P-AAP-3 Vt-P---3P-AAP-9 Vt-P---3P-NA--2 Vt-P---3P-NA--3
    Vt-P---3P-NA--4 Vt-P---3P-NA--9 Vt-P---3P-NAB-2 Vt-P---3P-NAB-3
    Vt-P---3P-NAB-9 Vt-P---3P-NAI-2 Vt-P---3P-NAI-3 Vt-P---3P-NAI-9
    Vt-P---3P-NAP-2 Vt-P---3P-NAP-3 Vt-P---3P-NAP-9 Vt-S---1F-AA--2
    Vt-S---1F-AA--3 Vt-S---1F-AAB-2 Vt-S---1F-AAB-3 Vt-S---1F-AAI-2
    Vt-S---1F-AAI-3 Vt-S---1F-AAP-2 Vt-S---1F-AAP-3 Vt-S---1F-NA--2
    Vt-S---1F-NA--3 Vt-S---1F-NAB-2 Vt-S---1F-NAB-3 Vt-S---1F-NAI-2
    Vt-S---1F-NAI-3 Vt-S---1F-NAP-2 Vt-S---1F-NAP-3 Vt-S---1P-AA--2
    Vt-S---1P-AA--3 Vt-S---1P-AAB-2 Vt-S---1P-AAB-3 Vt-S---1P-AAI-2
    Vt-S---1P-AAI-3 Vt-S---1P-AAP-2 Vt-S---1P-AAP-3 Vt-S---1P-NA--2
    Vt-S---1P-NA--3 Vt-S---1P-NAB-2 Vt-S---1P-NAB-3 Vt-S---1P-NAI-2
    Vt-S---1P-NAI-3 Vt-S---1P-NAP-2 Vt-S---1P-NAP-3 Vt-S---2F-AA--2
    Vt-S---2F-AAB-2 Vt-S---2F-AAI-2 Vt-S---2F-AAP-2 Vt-S---2F-NA--2
    Vt-S---2F-NAB-2 Vt-S---2F-NAI-2 Vt-S---2F-NAP-2 Vt-S---2P-AA--2
    Vt-S---2P-AAB-2 Vt-S---2P-AAI-2 Vt-S---2P-AAP-2 Vt-S---2P-NA--2
    Vt-S---2P-NAB-2 Vt-S---2P-NAI-2 Vt-S---2P-NAP-2 Vt-S---3F-AA--2
    Vt-S---3F-AAB-2 Vt-S---3F-AAI-2 Vt-S---3F-AAP-2 Vt-S---3F-NA--2
    Vt-S---3F-NAB-2 Vt-S---3F-NAI-2 Vt-S---3F-NAP-2 Vt-S---3P-AA--2
    Vt-S---3P-AA--4 Vt-S---3P-AAB-2 Vt-S---3P-AAI-2 Vt-S---3P-AAI-4
    Vt-S---3P-AAP-2 Vt-S---3P-NA--2 Vt-S---3P-NAB-2 Vt-S---3P-NAI-2
    Vt-S---3P-NAP-2 X@------------- X@------------0 X@------------1
    Xx------------- XX------------- Z:------------- Z#-------------
    VpQW----R-AAP-6 VpQW----R-NAP-6 VpYS----R-AAP-6 VpYS----R-NAP-6
    VsNS----X-APP-6 VsNS----X-NPP-6 VsNS----X-AP--- VsNS----X-NP---
    VsNS----X-AP--6 VsNS----X-NP--6 VsMP----X-APP-1 VsMP----X-NPP-1
    VsQW----X-APP-1 VsQW----X-NPP-1 VsFS4---X-APP-1 VsFS4---X-NPP-1
    VsFS----H-APPs1 VsFS----H-NPPs1 VsNS----H-APPs1 VsNS----H-NPPs1
    VsYS----X-APP-1 VsYS----X-NPP-1 VsTP----X-APP-1 VsTP----X-NPP-1
    VsNS----X-APP-1 VsNS----X-NPP-1 VpFS----R-AAIs- VpMP----R-AAI--
    VpNS----R-AAIs- VpNS----R-AAI-- VpQW----R-AAI-- VpTP----R-AAI--
    VpYS----R-AAIs- VpYS----R-AAI-- VpMP----R-AAP-6 VpMP----R-NAP-6
    VpNS----R-AAP-6 VpNS----R-NAP-6 VpTP----R-AAP-6 VpTP----R-NAP-6
    VpFS----R-AAPs6 VpFS----R-NAPs6 VpNS----R-AAPs6 VpNS----R-NAPs6
    VpNS----R-AAP-- VsFS----H-APIs- VsFS----H-NPIs- VsFS4---X-API--
    VsFS4---X-NPI-- VsFS4---X-API-2 VsFS4---X-NPI-2 VsMP----X-API--
    VsMP----X-NPI-- VsMP----X-API-2 VsMP----X-NPI-2 VsNS----H-APIs-
    VsNS----H-NPIs- VsNS----X-API-- VsNS----X-NPI-- VsNS----X-API-2
    VsNS----X-NPI-2 VsQW----X-API-- VsQW----X-NPI-- VsQW----X-API-2
    VsQW----X-NPI-2 VsTP----X-API-- VsTP----X-NPI-- VsTP----X-API-2
    VsTP----X-NPI-2 VsYS----X-API-- VsYS----X-NPI-- VsYS----X-API-2
    VsYS----X-NPI-2 VpMP----R-AAP-1 VpMP----R-NAP-1 VpMP----R-AAP-3
    VpMP----R-NAP-3 VpNS----R-AAP-1 VpNS----R-NAP-1 VpNS----R-AAP-3
    VpNS----R-NAP-3 VpQW----R-AAP-1 VpQW----R-NAP-1 VpQW----R-AAP-3
    VpQW----R-NAP-3 VpTP----R-AAP-1 VpTP----R-NAP-1 VpTP----R-AAP-3
    VpTP----R-NAP-3 VpNS----R-AAI-1 VpNS----R-NAI-1 VpQW----R-AAI-1
    VpQW----R-NAI-1 VpTP----R-AAI-1 VpTP----R-NAI-1 VpYS----R-AAI-1
    VpYS----R-NAI-1 VpMP----R-AAI-6 VpMP----R-NAI-6 VpNS----R-AAI-6
    VpNS----R-NAI-6 VpQW----R-AAI-6 VpQW----R-NAI-6 VpTP----R-AAI-6
    VpTP----R-NAI-6 VpYS----R-AAI-6 VpYS----R-NAI-6 VpMP----R-AAP-7
    VpMP----R-NAP-7 VpQW----R-AAP-7 VpQW----R-NAP-7 VpTP----R-AAP-7
    VpTP----R-NAP-7 VsNS----X-APP-- VsNS----X-NPP-- VsNS----X-API-6
    VsNS----X-NPI-6 VpYS----R-AAP-1 VpYS----R-NAP-1 VsNS----X-APP-7
    VsNS----X-NPP-7 VpNS----R-AAP-7 VpNS----R-NAP-7 VpFS----R-NAIs-
    VpMP----R-NAI-- VpNS----R-NAIs- VpNS----R-NAI-- VpQW----R-NAI--
    VpTP----R-NAI-- VpYS----R-NAIs- VpYS----R-NAI-- VsYS----H-APIs-
    VsYS----H-NPIs- VsYS----X-APP-- VsYS----X-NPP-- VpNS----R-AAP-2
    VpNS----R-NAP-2 VpMP----R-AAP-2 VpMP----R-NAP-2 VpQW----R-AAP-2
    VpQW----R-NAP-2 VpTP----R-AAP-2 VpTP----R-NAP-2 VpYS----R-AAP-2
    VpYS----R-NAP-2 VpFS----R-AAPs1 VpFS----R-NAPs1 VpNS----R-AAPs1
    VpNS----R-NAPs1 VpYS----R-AAPs1 VpYS----R-NAPs1 VqMP----R-AAP-3
    VqMP----R-NAP-3 VqNS----R-AAP-3 VqNS----R-NAP-3 VqQW----R-AAP-3
    VqQW----R-NAP-3 VqTP----R-AAP-3 VqTP----R-NAP-3 VqYS----R-AAP-3
    VqYS----R-NAP-3 VpMP----R-AAP-- VpMP----R-NAP-- VpNS----R-NAP--
    VpQW----R-AAP-- VpQW----R-NAP-- VpTP----R-AAP-- VpTP----R-NAP--
    VsQW----X-APP-6 VsQW----X-NPP-6 VsTP----X-APP-6 VsTP----X-NPP-6
    VpYS----R-AAP-7 VpYS----R-NAP-7 VsFS----H-APPs- VsFS----H-NPPs-
    VsFS4---X-APP-- VsFS4---X-NPP-- VsFS4---X-APP-2 VsFS4---X-NPP-2
    VsMP----X-APP-- VsMP----X-NPP-- VsMP----X-APP-2 VsMP----X-NPP-2
    VsNS----H-APPs- VsNS----H-NPPs- VsNS----X-APP-2 VsNS----X-NPP-2
    VsQW----X-APP-- VsQW----X-NPP-- VsQW----X-APP-2 VsQW----X-NPP-2
    VsTP----X-APP-- VsTP----X-NPP-- VsTP----X-APP-2 VsTP----X-NPP-2
    VsYS----X-APP-2 VsYS----X-NPP-2 VpMP----R-AAI-1 VpMP----R-NAI-1
    VpMP----R-AAI-3 VpMP----R-NAI-3 VpNS----R-AAI-3 VpNS----R-NAI-3
    VpQW----R-AAI-3 VpQW----R-NAI-3 VpTP----R-AAI-3 VpTP----R-NAI-3
    VpFS----R-AAIs6 VpFS----R-NAIs6 VpNS----R-AAIs6 VpNS----R-NAIs6
    VpYS----R-AAIs6 VpYS----R-NAIs6 VpYS----R-AAP-- VpYS----R-NAP--
    VqYS----R-AAP-2 VqYS----R-NAP-2 VqQW----R-AAP-2 VqQW----R-NAP-2
    VqNS----R-AAP-2 VqNS----R-NAP-2 VqMP----R-AAP-2 VqMP----R-NAP-2
    VqTP----R-AAP-2 VqTP----R-NAP-2 VpYS----R-AAPs- VpYS----R-NAPs-
    VpFS----R-AAPs- VpFS----R-NAPs- VpNS----R-AAPs- VpNS----R-NAPs-
    VpYS----R-AAB-- VpYS----R-NAB-- VpQW----R-AAB-- VpQW----R-NAB--
    VpNS----R-AAB-- VpNS----R-NAB-- VpMP----R-AAB-- VpMP----R-NAB--
    VpTP----R-AAB-- VpTP----R-NAB-- VqYS----R-AAB-2 VqYS----R-NAB-2
    VqQW----R-AAB-2 VqQW----R-NAB-2 VqNS----R-AAB-2 VqNS----R-NAB-2
    VqMP----R-AAB-2 VqMP----R-NAB-2 VqTP----R-AAB-2 VqTP----R-NAB-2
    VpYS----R-AABs- VpYS----R-NABs- VpFS----R-AABs- VpFS----R-NABs-
    VpNS----R-AABs- VpNS----R-NABs- VsYS----X-APB-- VsYS----X-NPB--
    VsQW----X-APB-- VsQW----X-NPB-- VsNS----X-APB-- VsNS----X-NPB--
    VsMP----X-APB-- VsMP----X-NPB-- VsTP----X-APB-- VsTP----X-NPB--
    VsFS4---X-APB-- VsFS4---X-NPB-- VsFS----H-APBs- VsFS----H-NPBs-
    VsNS----H-APBs- VsNS----H-NPBs- VqYS----R-AAI-2 VqYS----R-NAI-2
    VqQW----R-AAI-2 VqQW----R-NAI-2 VqNS----R-AAI-2 VqNS----R-NAI-2
    VqMP----R-AAI-2 VqMP----R-NAI-2 VqTP----R-AAI-2 VqTP----R-NAI-2
    VpYS----R-AAB-1 VpYS----R-NAB-1 VpQW----R-AAB-1 VpQW----R-NAB-1
    VpNS----R-AAB-1 VpNS----R-NAB-1 VpMP----R-AAB-1 VpMP----R-NAB-1
    VpTP----R-AAB-1 VpTP----R-NAB-1 VqYS----R-AAB-3 VqYS----R-NAB-3
    VqQW----R-AAB-3 VqQW----R-NAB-3 VqNS----R-AAB-3 VqNS----R-NAB-3
    VqMP----R-AAB-3 VqMP----R-NAB-3 VqTP----R-AAB-3 VqTP----R-NAB-3
    VpYS----R-AAB-6 VpYS----R-NAB-6 VpYS----R-AABs1 VpYS----R-NABs1
    VpFS----R-AABs1 VpFS----R-NABs1 VpNS----R-AABs1 VpNS----R-NABs1
    VqYS----R-AAI-3 VqYS----R-NAI-3 VqQW----R-AAI-3 VqQW----R-NAI-3
    VqNS----R-AAI-3 VqNS----R-NAI-3 VqMP----R-AAI-3 VqMP----R-NAI-3
    VqTP----R-AAI-3 VqTP----R-NAI-3 VpYS----R-AAIs1 VpYS----R-NAIs1
    VpFS----R-AAIs1 VpFS----R-NAIs1 VpNS----R-AAIs1 VpNS----R-NAIs1
    VpYS----R-AA--- VpYS----R-NA--- VpQW----R-AA--- VpQW----R-NA---
    VpNS----R-AA--- VpNS----R-NA--- VpMP----R-AA--- VpMP----R-NA---
    VpTP----R-AA--- VpTP----R-NA--- VqYS----R-AA--2 VqYS----R-NA--2
    VqQW----R-AA--2 VqQW----R-NA--2 VqNS----R-AA--2 VqNS----R-NA--2
    VqMP----R-AA--2 VqMP----R-NA--2 VqTP----R-AA--2 VqTP----R-NA--2
    VpYS----R-AA-s- VpYS----R-NA-s- VpFS----R-AA-s- VpFS----R-NA-s-
    VpNS----R-AA-s- VpNS----R-NA-s- VpYS----R-AA--6 VpYS----R-NA--6
    VsYS----X-AP--- VsYS----X-NP--- VsQW----X-AP--- VsQW----X-NP---
    VsMP----X-AP--- VsMP----X-NP--- VsTP----X-AP--- VsTP----X-NP---
    VsFS4---X-AP--- VsFS4---X-NP--- VsFS----H-AP-s- VsFS----H-NP-s-
    VsNS----H-AP-s- VsNS----H-NP-s- AAFD7----1A---1 AAFD7----1N---1
    AANS3----1A---1 AANS3----1N---1 AAMS3----1A---1 AAMS3----1N---1
    AAIS3----1A---1 AAIS3----1N---1 AANP7----1A---1 AANP7----1N---1
    AAMP7----1A---1 AAMP7----1N---1 AAIP7----1A---1 AAIP7----1N---1
    AAFP7----1A---1 AAFP7----1N---1 AANS7----1A---7 AANS7----1N---7
    AANP3----1A---7 AANP3----1N---7 AAMS7----1A---7 AAMS7----1N---7
    AAMP3----1A---7 AAMP3----1N---7 AAIS7----1A---7 AAIS7----1N---7
    AAIP3----1A---7 AAIP3----1N---7 AAFP3----1A---7 AAFP3----1N---7
    AANP6----1A---1 AANP6----1N---1 AANP2----1A---1 AANP2----1N---1
    AAMP6----1A---1 AAMP6----1N---1 AAMP2----1A---1 AAMP2----1N---1
    AAIP6----1A---1 AAIP6----1N---1 AAIP2----1A---1 AAIP2----1N---1
    AAFP6----1A---1 AAFP6----1N---1 AAFP2----1A---1 AAFP2----1N---1
    AANS2----1A---1 AANS2----1N---1 AAMS4----1A---1 AAMS4----1N---1
    AAMS2----1A---1 AAMS2----1N---1 AAIS2----1A---1 AAIS2----1N---1
    AANS7----1A---1 AANS7----1N---1 AANS6----1A---1 AANS6----1N---1
    AANP3----1A---1 AANP3----1N---1 AAMS7----1A---1 AAMS7----1N---1
    AAMS6----1A---1 AAMS6----1N---1 AAMP3----1A---1 AAMP3----1N---1
    AAIS7----1A---1 AAIS7----1N---1 AAIS6----1A---1 AAIS6----1N---1
    AAIP3----1A---1 AAIP3----1N---1 AAFP3----1A---1 AAFP3----1N---1
    AANS5----1A---1 AANS5----1N---1 AANS4----1A---1 AANS4----1N---1
    AANS1----1A---1 AANS1----1N---1 AANP5----1A---1 AANP5----1N---1
    AANP4----1A---1 AANP4----1N---1 AANP1----1A---1 AANP1----1N---1
    AAMS5----1A---1 AAMS5----1N---1 AAMS1----1A---1 AAMS1----1N---1
    AAMP5----1A---1 AAMP5----1N---1 AAMP4----1A---1 AAMP4----1N---1
    AAMP1----1A---1 AAMP1----1N---1 AAIP5----1A---1 AAIP5----1N---1
    AAIP4----1A---1 AAIP4----1N---1 AAIP1----1A---1 AAIP1----1N---1
    AAFS7----1A---1 AAFS7----1N---1 AAFS6----1A---1 AAFS6----1N---1
    AAFS5----1A---1 AAFS5----1N---1 AAFS4----1A---1 AAFS4----1N---1
    AAFS3----1A---1 AAFS3----1N---1 AAFS2----1A---1 AAFS2----1N---1
    AAFS1----1A---1 AAFS1----1N---1 AAFP5----1A---1 AAFP5----1N---1
    AAFP4----1A---1 AAFP4----1N---1 AAFP1----1A---1 AAFP1----1N---1
    AANS3----1A---3 AANS3----1N---3 AANS3----2A---3 AANS3----2N---3
    AANS3----3A---3 AANS3----3N---3 AAMS3----1A---3 AAMS3----1N---3
    AAMS3----2A---3 AAMS3----2N---3 AAMS3----3A---3 AAMS3----3N---3
    AAIS3----1A---3 AAIS3----1N---3 AAIS3----2A---3 AAIS3----2N---3
    AAIS3----3A---3 AAIS3----3N---3 AANP6----1A---3 AANP6----1N---3
    AANP6----2A---3 AANP6----2N---3 AANP6----3A---3 AANP6----3N---3
    AANP2----1A---3 AANP2----1N---3 AANP2----2A---3 AANP2----2N---3
    AANP2----3A---3 AANP2----3N---3 AAMP6----1A---3 AAMP6----1N---3
    AAMP6----2A---3 AAMP6----2N---3 AAMP6----3A---3 AAMP6----3N---3
    AAMP2----1A---3 AAMP2----1N---3 AAMP2----2A---3 AAMP2----2N---3
    AAMP2----3A---3 AAMP2----3N---3 AAIP6----1A---3 AAIP6----1N---3
    AAIP6----2A---3 AAIP6----2N---3 AAIP6----3A---3 AAIP6----3N---3
    AAIP2----1A---3 AAIP2----1N---3 AAIP2----2A---3 AAIP2----2N---3
    AAIP2----3A---3 AAIP2----3N---3 AAFP6----1A---3 AAFP6----1N---3
    AAFP6----2A---3 AAFP6----2N---3 AAFP6----3A---3 AAFP6----3N---3
    AAFP2----1A---3 AAFP2----1N---3 AAFP2----2A---3 AAFP2----2N---3
    AAFP2----3A---3 AAFP2----3N---3 AANP7----1A---3 AANP7----1N---3
    AANP7----2A---3 AANP7----2N---3 AANP7----3A---3 AANP7----3N---3
    AAMP7----1A---3 AAMP7----1N---3 AAMP7----2A---3 AAMP7----2N---3
    AAMP7----3A---3 AAMP7----3N---3 AAIP7----1A---3 AAIP7----1N---3
    AAIP7----2A---3 AAIP7----2N---3 AAIP7----3A---3 AAIP7----3N---3
    AAFP7----1A---3 AAFP7----1N---3 AAFP7----2A---3 AAFP7----2N---3
    AAFP7----3A---3 AAFP7----3N---3 AANS5----1A---3 AANS5----1N---3
    AANS5----2A---3 AANS5----2N---3 AANS5----3A---3 AANS5----3N---3
    AANS4----1A---3 AANS4----1N---3 AANS4----2A---3 AANS4----2N---3
    AANS4----3A---3 AANS4----3N---3 AANS1----1A---3 AANS1----1N---3
    AANS1----2A---3 AANS1----2N---3 AANS1----3A---3 AANS1----3N---3
    AANP5----1A---3 AANP5----1N---3 AANP5----2A---3 AANP5----2N---3
    AANP5----3A---3 AANP5----3N---3 AANP4----1A---3 AANP4----1N---3
    AANP4----2A---3 AANP4----2N---3 AANP4----3A---3 AANP4----3N---3
    AANP1----1A---3 AANP1----1N---3 AANP1----2A---3 AANP1----2N---3
    AANP1----3A---3 AANP1----3N---3 AAMS5----1A---3 AAMS5----1N---3
    AAMS5----2A---3 AAMS5----2N---3 AAMS5----3A---3 AAMS5----3N---3
    AAMS1----1A---3 AAMS1----1N---3 AAMS1----2A---3 AAMS1----2N---3
    AAMS1----3A---3 AAMS1----3N---3 AAMP5----1A---3 AAMP5----1N---3
    AAMP5----2A---3 AAMP5----2N---3 AAMP5----3A---3 AAMP5----3N---3
    AAMP4----1A---3 AAMP4----1N---3 AAMP4----2A---3 AAMP4----2N---3
    AAMP4----3A---3 AAMP4----3N---3 AAMP1----1A---3 AAMP1----1N---3
    AAMP1----2A---3 AAMP1----2N---3 AAMP1----3A---3 AAMP1----3N---3
    AAIS5----1A---3 AAIS5----1N---3 AAIS5----2A---3 AAIS5----2N---3
    AAIS5----3A---3 AAIS5----3N---3 AAIS4----1A---3 AAIS4----1N---3
    AAIS4----2A---3 AAIS4----2N---3 AAIS4----3A---3 AAIS4----3N---3
    AAIS1----1A---3 AAIS1----1N---3 AAIS1----2A---3 AAIS1----2N---3
    AAIS1----3A---3 AAIS1----3N---3 AAIP5----1A---3 AAIP5----1N---3
    AAIP5----2A---3 AAIP5----2N---3 AAIP5----3A---3 AAIP5----3N---3
    AAIP4----1A---3 AAIP4----1N---3 AAIP4----2A---3 AAIP4----2N---3
    AAIP4----3A---3 AAIP4----3N---3 AAIP1----1A---3 AAIP1----1N---3
    AAIP1----2A---3 AAIP1----2N---3 AAIP1----3A---3 AAIP1----3N---3
    AAFS7----1A---3 AAFS7----1N---3 AAFS7----2A---3 AAFS7----2N---3
    AAFS7----3A---3 AAFS7----3N---3 AAFS6----1A---3 AAFS6----1N---3
    AAFS6----2A---3 AAFS6----2N---3 AAFS6----3A---3 AAFS6----3N---3
    AAFS5----1A---3 AAFS5----1N---3 AAFS5----2A---3 AAFS5----2N---3
    AAFS5----3A---3 AAFS5----3N---3 AAFS4----1A---3 AAFS4----1N---3
    AAFS4----2A---3 AAFS4----2N---3 AAFS4----3A---3 AAFS4----3N---3
    AAFS3----1A---3 AAFS3----1N---3 AAFS3----2A---3 AAFS3----2N---3
    AAFS3----3A---3 AAFS3----3N---3 AAFS2----1A---3 AAFS2----1N---3
    AAFS2----2A---3 AAFS2----2N---3 AAFS2----3A---3 AAFS2----3N---3
    AAFS1----1A---3 AAFS1----1N---3 AAFS1----2A---3 AAFS1----2N---3
    AAFS1----3A---3 AAFS1----3N---3 AAFP5----1A---3 AAFP5----1N---3
    AAFP5----2A---3 AAFP5----2N---3 AAFP5----3A---3 AAFP5----3N---3
    AAFP4----1A---3 AAFP4----1N---3 AAFP4----2A---3 AAFP4----2N---3
    AAFP4----3A---3 AAFP4----3N---3 AAFP1----1A---3 AAFP1----1N---3
    AAFP1----2A---3 AAFP1----2N---3 AAFP1----3A---3 AAFP1----3N---3
    AANP7----1A---5 AANP7----1N---5 AANP7----2A---5 AANP7----2N---5
    AANP7----3A---5 AANP7----3N---5 AAMP7----1A---5 AAMP7----1N---5
    AAMP7----2A---5 AAMP7----2N---5 AAMP7----3A---5 AAMP7----3N---5
    AAIP7----1A---5 AAIP7----1N---5 AAIP7----2A---5 AAIP7----2N---5
    AAIP7----3A---5 AAIP7----3N---5 AAFP7----1A---5 AAFP7----1N---5
    AAFP7----2A---5 AAFP7----2N---5 AAFP7----3A---5 AAFP7----3N---5
    AAFD7----1A---3 AAFD7----1N---3 AAFD7----2A---3 AAFD7----2N---3
    AAFD7----3A---3 AAFD7----3N---3 AANS2----1A---3 AANS2----1N---3
    AANS2----2A---3 AANS2----2N---3 AANS2----3A---3 AANS2----3N---3
    AAMS4----1A---3 AAMS4----1N---3 AAMS4----2A---3 AAMS4----2N---3
    AAMS4----3A---3 AAMS4----3N---3 AAMS2----1A---3 AAMS2----1N---3
    AAMS2----2A---3 AAMS2----2N---3 AAMS2----3A---3 AAMS2----3N---3
    AAIS2----1A---3 AAIS2----1N---3 AAIS2----2A---3 AAIS2----2N---3
    AAIS2----3A---3 AAIS2----3N---3 AANS7----1A---5 AANS7----1N---5
    AANS7----2A---5 AANS7----2N---5 AANS7----3A---5 AANS7----3N---5
    AANS6----1A---5 AANS6----1N---5 AANS6----2A---5 AANS6----2N---5
    AANS6----3A---5 AANS6----3N---5 AANP3----1A---5 AANP3----1N---5
    AANP3----2A---5 AANP3----2N---5 AANP3----3A---5 AANP3----3N---5
    AAMS7----1A---5 AAMS7----1N---5 AAMS7----2A---5 AAMS7----2N---5
    AAMS7----3A---5 AAMS7----3N---5 AAMS6----1A---5 AAMS6----1N---5
    AAMS6----2A---5 AAMS6----2N---5 AAMS6----3A---5 AAMS6----3N---5
    AAMP3----1A---5 AAMP3----1N---5 AAMP3----2A---5 AAMP3----2N---5
    AAMP3----3A---5 AAMP3----3N---5 AAIS7----1A---5 AAIS7----1N---5
    AAIS7----2A---5 AAIS7----2N---5 AAIS7----3A---5 AAIS7----3N---5
    AAIS6----1A---5 AAIS6----1N---5 AAIS6----2A---5 AAIS6----2N---5
    AAIS6----3A---5 AAIS6----3N---5 AAIP3----1A---5 AAIP3----1N---5
    AAIP3----2A---5 AAIP3----2N---5 AAIP3----3A---5 AAIP3----3N---5
    AAFP3----1A---5 AAFP3----1N---5 AAFP3----2A---5 AAFP3----2N---5
    AAFP3----3A---5 AAFP3----3N---5 AANS7----1A---3 AANS7----1N---3
    AANS7----2A---3 AANS7----2N---3 AANS7----3A---3 AANS7----3N---3
    AANS6----1A---3 AANS6----1N---3 AANS6----2A---3 AANS6----2N---3
    AANS6----3A---3 AANS6----3N---3 AANP3----1A---3 AANP3----1N---3
    AANP3----2A---3 AANP3----2N---3 AANP3----3A---3 AANP3----3N---3
    AAMS7----1A---3 AAMS7----1N---3 AAMS7----2A---3 AAMS7----2N---3
    AAMS7----3A---3 AAMS7----3N---3 AAMS6----1A---3 AAMS6----1N---3
    AAMS6----2A---3 AAMS6----2N---3 AAMS6----3A---3 AAMS6----3N---3
    AAMP3----1A---3 AAMP3----1N---3 AAMP3----2A---3 AAMP3----2N---3
    AAMP3----3A---3 AAMP3----3N---3 AAIS7----1A---3 AAIS7----1N---3
    AAIS7----2A---3 AAIS7----2N---3 AAIS7----3A---3 AAIS7----3N---3
    AAIS6----1A---3 AAIS6----1N---3 AAIS6----2A---3 AAIS6----2N---3
    AAIS6----3A---3 AAIS6----3N---3 AAIP3----1A---3 AAIP3----1N---3
    AAIP3----2A---3 AAIP3----2N---3 AAIP3----3A---3 AAIP3----3N---3
    AAFP3----1A---3 AAFP3----1N---3 AAFP3----2A---3 AAFP3----2N---3
    AAFP3----3A---3 AAFP3----3N---3 VB-P---1P-NAI-7 Vt-P---1P-AAI-4
    Vt-P---1P-NAI-4 Vt-P---2P-AAI-3 Vt-P---2P-NAI-3 Vt-S---2P-AAI-3
    Vt-S---2P-NAI-3 Vt-S---3P-AAI-3 Vt-S---3P-NAI-3 Vt-P---1P-AAP-4
    Vt-P---1P-NAP-4 Vt-P---2P-AAP-3 Vt-P---2P-NAP-3 Vt-P---3P-AAP-4
    Vt-P---3P-NAP-4 Vt-S---1P-AAP-4 Vt-S---1P-NAP-4 Vt-S---2P-AAP-3
    Vt-S---2P-NAP-3 Vt-S---3P-AAP-3 Vt-S---3P-NAP-3 Vt-P---3P-AAI-4
    Vt-P---3P-NAI-4 Vt-S---1P-AAI-4 Vt-S---1P-NAI-4 VB-P---1P-AAP-9
    VB-P---1P-NAP-9 VB-P---2P-AAP-9 VB-P---2P-NAP-9 VB-P---3P-AAP-9
    VB-P---3P-NAP-9 VB-S---1P-AAP-9 VB-S---1P-NAP-9 VB-S---2P-AAP-9
    VB-S---2P-NAP-9 VB-S---3P-AAP-9 VB-S---3P-NAP-9 VB-P---1P-AAP-8
    VB-P---1P-NAP-8 VB-P---2P-AAP-5 VB-P---2P-NAP-5 VB-P---2P-AAP-7
    VB-P---2P-NAP-7 VB-P---3P-AAP-5 VB-P---3P-NAP-5 VB-S---1P-AAP-7
    VB-S---1P-NAP-7 VB-S---1P-AAP-5 VB-S---1P-NAP-5 VB-S---2P-AAP-7
    VB-S---2P-NAP-7 VB-S---2P-AAP-5 VB-S---2P-NAP-5 VB-S---3P-AAP-7
    VB-S---3P-NAP-7 VB-S---3P-AAP-5 VB-S---3P-NAP-5 Vt-P---1P-AAP-5
    Vt-P---1P-NAP-5 Vt-P---1P-AAP-6 Vt-P---1P-NAP-6 Vt-P---1P-AAP-7
    Vt-P---1P-NAP-7 Vt-P---1P-AAP-8 Vt-P---1P-NAP-8 Vt-P---2P-AAP-5
    Vt-P---2P-NAP-5 Vt-P---2P-AAP-6 Vt-P---2P-NAP-6 Vt-P---3P-AAP-5
    Vt-P---3P-NAP-5 Vt-P---3P-AAP-6 Vt-P---3P-NAP-6 Vt-S---1P-AAP-5
    Vt-S---1P-NAP-5 Vt-S---1P-AAP-6 Vt-S---1P-NAP-6 Vt-S---2P-AAP-5
    Vt-S---2P-NAP-5 Vt-S---2P-AAP-6 Vt-S---2P-NAP-6 Vt-S---3P-AAP-5
    Vt-S---3P-NAP-5 Vt-S---3P-AAP-6 Vt-S---3P-NAP-6 PQ--4--------z-
    PQ--4--------n- PQ--4--------o- PQ--4--------v- PQ--4--------Z-
    PQ--4--------N- PQ--4--------O- PQ--4--------V- PQ--2--------s-
    PQ--3--------s- PQ--4--------s- PQ--6--------s- PQ--7--------s-
    P4YS1---------2 P4IS4---------2 P4MP1---------2 P4FS4---------2
    P4FS7---------2 P4NP1---------2 P4NP4---------2 P4FS1---------2
    P4ZS2---------2 P4MS4---------2 P4ZS3---------2 P4ZS6---------2
    P4YP4---------2 P4IP1---------2 P4FP1---------2 P4FP4---------2
    P4NS1---------2 P4NS4---------2 P4FS2---------2 P4FS3---------2
    P4FS6---------2 P4XP2---------2 P4XP6---------2 P4FD7---------2
    P4XP7---------2 P4XP3---------2 P4ZS7---------2 P4NP4---------7
    PKM-1--------s- PKM-3--------s- PKM-6--------s- PKM-7--------s-
    PSZS2-S1------7 PSMS4-S1------7 PSZS7-S1------7 PSXP3-S1------7
    PZFP1---------7 PZFP4---------7 PZFP5---------7 PZFS2---------7
    PZIP1---------7 PZIP5---------7 PZNS1---------7 PZNS4---------7
    PZNS5---------7 PZFS3---------7 PZFS6---------7 PZYP4---------7
    PDFS4---------4 PDMP4---------4 PDFP1---------4 PDIP1---------4
    PDFP4---------4 PDIP4---------4 PDNS1---------4 PDNS4---------4
    PDNS4--------s- PDNS1--------s- PP-S1--2P-AA-s- Db-----------s-
    PLMP1---------1 PLMP5---------1 PLMP1---------4 PLMP5---------4
    PLMP1---------5 PLMP5---------5 PLMP1---------8 PLMP5---------8
    PLXP3---------7 PLXP7---------7 PLZS3---------5 PLZS6---------3
    PLXP3---------3
)};
my $NO_ANALYSIS = qr/^X@-+[-01]$/;
my %VALID_POSITION;
for my $tag (keys %VALID_TAGS) {
    undef $VALID_POSITION{$_}{ substr $tag, $_, 1 } for 0 .. TAG_LENGTH - 1;
}
undef $VALID_POSITION{0}{S};
undef @{ $VALID_POSITION{13} }{qw{ D P }};
undef @{ $VALID_POSITION{14} }{qw{ a b }};

my %DICT;

my $PDT_STYLESHEET = 'PML_M_36';
my $PDTSC_STYLESHEET = 'PML_M_36_SC';

sub detect {
    PML::SchemaDescription() =~ /PDT 3.6 morphological/
        && 'mdata' eq PML::SchemaName()
    ? 1 : 0
}


sub switch_context_hook {
    my @nodes = $root->descendants;

    # PDT has "orig" (original manual annotation), PDTSC doesn't.
    my $is_pdt = grep $_->get_attribute('src') eq 'orig',
                 map AltV($_->attr('tag')),
                 @nodes;
    SetCurrentStylesheet($is_pdt ? $PDT_STYLESHEET : $PDTSC_STYLESHEET);
    TrEd::MinorModes::enable_minor_mode($grp, 'Show_Neighboring_Sentences');
    Redraw() if GUI();
}


#bind AddComment to ! menu Add Comment
sub AddComment {
    ChangingFile(0);
    my $text = QueryString('Comment text', 'Text:');
    return unless defined $text;
    my %comment = (type => 'Other',
                   text => $text);
    AddToList($this, 'comment', \%comment);
    ChangingFile(1);
}


#bind EditComment to ? menu Edit Comment
sub EditComment {
    ChangingFile(0);
    my @comments = grep 'New Form' ne $_->{type},
                   ListV($this->attr('comment'));
    my $remove = TredMacro::ListQuery('Remove comments',
                                      'multiple',
                                      [ map $_->{text}, @comments ],
                                      [],
                                      { label => 'Select comments to remove' });
    return unless $remove;

    my %r; undef @r{@$remove};
    my @keep = grep ! exists $r{$_}, 0 .. $#comments;
    $this->{comment} = List(@comments[@keep],
                            grep $_->{type} eq 'New Form',
                            ListV($this->attr('comment')));
    ChangingFile(1);
}


#bind EditMorphology to m menu Edit Morphology
sub EditMorphology {
    ChangingFile(0);
    return if $root == $this;

    my ($selected) = @_;
    ref [] eq ref $selected or $selected = select_morph($this);
    return unless $selected;

    return
        if (single_or_no_tag() ? $this->attr('tag')
                               : $this->attr('tag')->[ $selected->[0] ]
        )->value =~ $NO_ANALYSIS;

    ChangingFile(1);
    if (single_or_no_tag()) {
        $this->attr('tag')->{selected} = 1;

    } else {
        delete $_->{selected} for @{ $this->attr('tag') };
        $this->attr('tag')->[ $selected->[0] ]{selected} = 1;
    }
}


sub bind_button {
    my ($button, $key, $dialog) = @_;
    $dialog->bind(all => $key, sub {
        $dialog->{SubWidget}{"B_$button"}->invoke
    });
}


sub bind_dialog {
    my ($dialog) = @_;
    $dialog->bind(all => '<Tab>', sub { shift->focusNext });
    $dialog->bind(all => '<Shift-Tab>', sub { shift->focusPrev });
    bind_button(Cancel => '<Escape>', $dialog);
}


sub load_dictionary {
    my ($file) = @_;
    open my $IN, '<:encoding(UTF-8)', $file or die $!;
    while (<$IN>) {
        chomp;
        my ($form, $lemma, $tag) = split /\t/;
        undef $DICT{$form}{$lemma}{$tag};
    }
}


sub load_dictionaries {
    my ($volume, $directories, $filename)
        = 'File::Spec'->splitpath(FileName());
    my $up = 'File::Spec'->updir;
    my $path;
    my $tries = 0;
    do {
        ++$tries;
        $directories = 'File::Spec'->catfile($directories, $up);
        $path = 'File::Spec'->catpath($volume, $directories, 'all');
    } until -d $path || $tries > 1000;
    if ($tries > 1000) {
        warn "Directories not found.\n";
        return
    }

    opendir my $dir, $path or die $!;
    while (my $file = readdir $dir) {
        next if $file !~ /^dict-updates-[[:upper:]]{2}\.txt$/;
        load_dictionary('File::Spec'->catfile($path, $file));
    }
}


sub update_dictionary {
    my ($form, $lemma, $tag) = @_;
    my ($volume, $directories, $filename)
        = 'File::Spec'->splitpath(FileName());
    my @dirs = 'File::Spec'->splitdir($directories);
    my ($alldir, $user);
    $user = pop @dirs until ! @dirs
        || $user =~ /^[[:upper:]]{2}$/
            && -d ($alldir = 'File::Spec'->catpath(
                $volume, 'File::Spec'->catdir(@dirs, 'all')
            ));
    unless ($user =~ /^[[:upper:]]{2}$/ && -d $alldir) {
        warn "Username not identified.\n";
        return
    }

    open my $OUT, '>>:encoding(UTF-8)', 'File::Spec'->catfile(
        $alldir,
        "dict-updates-$user.txt"
    ) or die $!;
    print {$OUT} join("\t", $form, $lemma, $tag), "\n";
    close $OUT or die $!;
    undef $DICT{$form}{$lemma}{$tag};
 }


sub select_morph {
    my ($node) = @_;
    load_dictionaries() unless keys %DICT;
    my $alt_form = (grep 'New Form' eq $_->{type}, ListV($node->attr('comment'))
                   )[-1];
    $alt_form &&= $alt_form->{text};
    my $old_form = $node->attr('form');
    my $form = TredMacro::QueryString('Form:', 'Form:', $alt_form // $old_form);
    return unless defined $form;

    if ($form ne $old_form) {
        return if grep 'New Form' eq $_->{type} && $_->{text} eq $form,
                       ListV($this->attr('comment'));
        AddToList($node, 'comment',
                  { type => 'New Form', text => $form });
        $node->{tag} = Alt(map { delete $_->{selected}; $_ }
                                 AltV($node->attr('tag')));
        ChangingFile(1);
        return
    }

    my $db = ToplevelFrame()->DialogBox(
        -title => 'Select lemma and tag',
        -buttons => ['OK', 'Edit', 'New', 'Cancel'],
    );
    bind_dialog($db);
    bind_button(New  => '<Control-n>', $db);
    bind_button(Edit => '<Control-e>', $db);

    my @alt = AltV($node->attr('tag'));
    my @list = map tag2selection(), @alt;

    if (exists $DICT{$form}) {
        for my $add_lemma (keys %{ $DICT{$form} }) {
            for my $add_tag (keys %{ $DICT{$form}{$add_lemma} }) {
                push @list, "$add_lemma  $add_tag"
                    unless grep $_ eq "$add_lemma  $add_tag", @list;
            }
        }
    }

    my $lb = $db->add(ScrlListbox =>
        -font => $font,
        -selectmode => 'browse',
        -width => -1,
        -height => (@list > 20 ? 20 : scalar @list),
        -scrollbars => 'oe',
        -listvariable => \ my $selected,
    )->pack(-fill => 'y');
    $lb->insert('end', @list);
    $lb->focus;
    $lb->activate(0);
    for my $i (0 .. $#alt) {
        if ($alt[$i]->value =~ $NO_ANALYSIS) {
            $lb->itemconfigure($i, -foreground => 'gray');
        } elsif ($alt[$i]->get_attribute('recommended')) {
            $lb->itemconfigure($i, -foreground => 'green');
        } elsif ('orig' eq $alt[$i]->get_attribute('src')) {
            $lb->itemconfigure($i, -foreground => 'red');
        }
        if ($alt[$i]->get_attribute('selected')) {
            $lb->activate($i);
            $lb->itemconfigure($i, -background => 'yellow');
        }
    }
    for my $i ($#alt + 1 .. $#list) {
        $lb->itemconfigure($i, -foreground => 'magenta');
    }
    $lb->see('active');

    my $answer = $db->Show;

    if ('Cancel' ne $answer) {
        $node->{comment} = List(grep 'New Form' ne $_->{type},
                                ListV($node->attr('comment')));
    }

    if ('OK' eq $answer && defined $lb->curselection) {
        if ($lb->curselection->[0] > $#alt) {
            my ($lemma, $tag) = split ' ', $list[ $lb->curselection->[0] ];
            return add_new_analysis($node, $tag, $lemma, $#alt + 1, $form)
        }
        return $lb->curselection
    }

    if ($answer =~ /^(?: Edit | New )$/x) {
        my ($lemma_to_edit, $tag_to_edit);
        if ('Edit' eq $answer and my $selected = $lb->curselection) {
            ($lemma_to_edit, $tag_to_edit) = split ' ', $list[ $selected->[0] ];
        }
        my ($result, $lemma, $tag)
            = new_lemma_tag($form, $lemma_to_edit, $tag_to_edit);
        if ('OK' eq $result || SAVE_ANYWAY eq $result) {
            return add_new_analysis($node, $tag, $lemma, $#alt + 1, $form)
        }
    }

    return
}


sub add_new_analysis {
    my ($node, $tag, $lemma, $position, $form) = @_;
    update_dictionary($form, $lemma, $tag)
        unless exists $DICT{$form}
            && exists $DICT{$form}{$lemma}
            && exists $DICT{$form}{$lemma}{$tag};
    AddToAlt($node, 'tag', 'Treex::PML::Factory'->createContainer(
        $tag, { lemma => $lemma, src => 'manual' }, 1));
    return [ $position ]
}


sub tag2selection { $_->get_attribute('lemma') . "  " . $_->value }


sub new_lemma_tag {
    my ($form, $lemma, $tag) = @_;
    $lemma //= $form;
    $tag //= '-' x 15;
    my $dialog = ToplevelFrame()->DialogBox(
        -title => 'New lemma and tag',
        -buttons => [ 'OK', 'Cancel' ],
    );
    bind_dialog($dialog);
    $dialog->add(Label => -text => "New lemma and tag for $form")->pack;

    my $lf = $dialog->Frame->pack;
    $lf->Label(-text => 'Lemma')->pack(-side => 'left');
    my $le = $lf->Entry(-textvariable => \$lemma)
        ->pack(-side => 'right');
    $le->focus;
    $dialog->bind('<Alt-l>' => sub { $le->focus });
    $le->bind('<Alt-c>' => sub { $le->insert(insert => '^') });
    $le->bind('<Alt-u>' => sub { $le->insert(insert => '_') });
    ignore_spaces($le);

    my $tf = $dialog->Frame->pack;
    $tf->Label(-text => 'Tag')->pack(-side => 'left');
    my $te = $tf->Entry(-textvariable => \$tag)
        ->pack(-side => 'right');
    $dialog->bind('<Alt-t>' => sub { $te->focus });
    ignore_spaces($te);

    my $hf = $dialog->Frame;
    $hf->Label(-text => 'Alt+c ... ^ (Caret)')->pack;
    $hf->Label(-text => 'Alt+u ... _ (Underline)')->pack;
    $le->bind('<FocusOut>'  => sub { $hf->packForget });
    $le->bind('<FocusIn>' => sub { $hf->pack });

    my $ok_button = $dialog->{SubWidget}{'B_OK'};
    my $orig = $ok_button->cget('-command');
    $ok_button->configure(-command => sub {
        if (exists $VALID_TAGS{$tag} && $tag !~ $NO_ANALYSIS) {
            $orig->[0]->();
        } else {
            my $buttons = [ 'OK' ];
            push @$buttons, SAVE_ANYWAY if $tag !~ $NO_ANALYSIS
                                        && valid_positional_tag($tag);
            my $dialog2 = $dialog->Dialog(-title  => 'Invalid tag',
                                         -text   => "Invalid tag $tag",
                                         -font   => $font,
                                         -bitmap => 'error',
                                         -buttons => $buttons,
                                        );
            my $anyway = $dialog2->Show;
            $orig->[0]->() if SAVE_ANYWAY eq $anyway
                           && 'Yes' eq $dialog->Dialog(
                               -title   => 'Use unknown tag',
                               -text    => 'Are you sure?',
                               -font    => $font,
                               -bitmap  => 'question',
                               -buttons => [qw[ Yes No ]],
                           )->Show;
        }
    });

    return $dialog->Show, $lemma, $tag
}


sub valid_positional_tag {
    my ($tag) = @_;
    return if TAG_LENGTH != length $tag;
    for my $position (0 .. TAG_LENGTH - 1) {
        return 0 unless exists $VALID_POSITION{$position}{
            substr $tag, $position, 1 };
    }
    return 1
}


sub ignore_spaces {
    my ($entry) = @_;
    $entry->bind('<space>' => sub {
        $entry->delete('insert - 1 char')
    });
}


sub search_forward {
    my ($condition) = @_;
    do {
        $this = $this->following;
        unless ($this) {
            TredMacro::NextTree() or return check_last();

            $this = $root;
            redo unless $this->following;
        }
    } until ! single_or_no_tag() && $condition->();
}


sub not_selected { ! grep $_->{selected}, AltV($this->attr('tag')) }


sub no_new_form { ! grep 'New Form' eq $_->{type}, ListV($this->{comment}) }

#bind NextUnknown to space menu Find Next Unknown
sub NextUnknown {
    ChangingFile(0);
    search_forward(sub { not_selected() && no_new_form() });
    Redraw();
    EditMorphology() unless $this == $root;
}


#bind NextAmbiguous to plus menu Find Next Ambiguous
#bind NextAmbiguous to KP_Add
sub NextAmbiguous {
    ChangingFile(0);
    search_forward(sub { 1 });
    Redraw();
    EditMorphology() if $this != $root && not_selected() && no_new_form();

}


sub check_last {
    TredMacro::GotoTree(1);
    my $done = 1;
    { do {
        undef $done if $this->attr('tag')
                    && ! grep $_->get_attribute('selected'),
                         AltV($this->attr('tag'));
        $this = $this->following;
        unless ($this) {
            TredMacro::NextTree() or last;

            $this = $root;
        }
    } while $this; }
    $grp->toplevel->Dialog(-title   => 'End of file',
                           -text    => 'End of file reached. There are '
                                       . ($done ? 'no ' : q())
                                       . 'unfinished nodes.',
                           -font    => $font,
                           -bitmap  => $done ? 'info' : 'warning',
                           -buttons => [ 'OK' ]
                          )->Show;
}


sub search_backward {
    my ($condition) = @_;
    do {
        $this = $this->previous if $this->previous;
        if ($this == $root) {
            TredMacro::PrevTree() or return;

            $this = $this->following while $this->following;
        }
    } until ! single_or_no_tag() && $condition->();
}


#bind PrevUnknown to Shift+space menu Find Previous Unknown
sub PrevUnknown {
    ChangingFile(0);
    search_backward(sub { not_selected() && no_new_form() });
    Redraw();
    EditMorphology() unless $this == $root;
}


#bind PreviousAmbiguous to minus menu Find Previous Ambiguous
#bind PreviousAmbiguous to KP_Subtract
sub PreviousAmbiguous {
    ChangingFile(0);
    search_backward(sub { 1 });
    Redraw();
    EditMorphology() if $this != $root && not_selected() && no_new_form();
}


sub single_or_no_tag {
    1 >= @{ [ AltV($this->attr('tag')) ] };
}


#bind DeleteM to Delete menu Delete Analysis
sub DeleteM {
    ChangingFile(0);
    if (grep 'New Form' eq $_->{type}, ListV($this->attr('comment'))) {
        ChangingFile(1);
        $this->{comment} = List(grep 'New Form' ne $_->{type},
                                ListV($this->attr('comment')));
        (AltV($this->attr('tag')))[0]->set_attribute(selected => 1)
            if single_or_no_tag();
    }

    if (grep 'manual' eq $_->{src}, AltV($this->attr('tag'))) {
        ChangingFile(1);
        $this->{tag} = Alt(grep 'manual' ne $_->{src},
                           AltV($this->attr('tag')));
        $this->{tag} = (AltV($this->attr('tag')))[0]
            if 1 == AltV($this->attr('tag'));
    }

    return unless grep $_->{selected}, AltV($this->attr('tag'));

    # Don't remove "selected" for unambiguous nodes.
    return if single_or_no_tag();

    for my $tag (AltV($this->attr('tag'))) {
        next unless $tag->{selected};
        delete $tag->{selected};
        ChangingFile(1);
    }
}


sub assign_lemma_tag {
    my ($lemma, $tag) = @_;
    my @tags  = AltV($this->attr('tag'));
    my $idx = first { $tags[$_]{lemma} eq $lemma
                   && $tags[$_]{'#content'} eq $tag
              } 0 .. $#tags;
    unless (defined $idx) {
        $idx = @tags;
        ChangingFile(1);
        AddToAlt($this, 'tag', 'Treex::PML::Factory'->createContainer($tag,
                     { lemma => $lemma, src => 'manual' }, 1));
    }
    EditMorphology([$idx]);
}



#bind AnnotateForeignWord to f menu Annotate as Foreign Word
sub AnnotateForeignWord {
    ChangingFile(0);
    return if $this == $root;

    my $form  = $this->attr('form');
    my $lemma = "$form-77";
    my $tag   = 'F%-------------';
    assign_lemma_tag($lemma, $tag);
}


#bind AnnotateAbbreviation to a menu Annotate as Abbreviation
sub AnnotateAbbreviation {
    ChangingFile(0);
    return if $this == $root;

    my $form  = $this->attr('form');
    my $lemma = "$form-88_:B";
    my $tag   = 'NNXXX-----A----';
    assign_lemma_tag($lemma, $tag);
}


#include <contrib/support/unbind_edit.inc>

sub allow_switch_context_hook { return 'stop' unless detect() }


sub enable_edit_node_hook { 'stop' }


sub enable_attr_hook { 'stop' }

1;

=back

=cut

