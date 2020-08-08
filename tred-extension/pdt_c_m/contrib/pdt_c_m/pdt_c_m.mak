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
    AAFD7---------- AAFD7----1A---- AAFD7----1A---1 AAFD7----1A---6
    AAFD7----1N---- AAFD7----1N---1 AAFD7----1N---6 AAFD7----2A----
    AAFD7----2A---1 AAFD7----2A---3 AAFD7----2A---6 AAFD7----2A---7
    AAFD7----2N---- AAFD7----2N---1 AAFD7----3A---- AAFD7----3A---1
    AAFD7----3A---3 AAFD7----3A---6 AAFD7----3A---7 AAFD7----3N----
    AAFD7----3N---1 AAFD7---------6 AAFP1---------- AAFP1----1A----
    AAFP1----1A---1 AAFP1----1A---6 AAFP1----1N---- AAFP1----1N---1
    AAFP1----1N---6 AAFP1----2A---- AAFP1----2A---1 AAFP1----2A---3
    AAFP1----2A---6 AAFP1----2A---7 AAFP1----2N---- AAFP1----2N---1
    AAFP1----3A---- AAFP1----3A---1 AAFP1----3A---3 AAFP1----3A---6
    AAFP1----3A---7 AAFP1----3N---- AAFP1----3N---1 AAFP1---------6
    AAFP2----1A---- AAFP2----1A---1 AAFP2----1A---6 AAFP2----1N----
    AAFP2----1N---1 AAFP2----1N---6 AAFP2----2A---- AAFP2----2A---1
    AAFP2----2A---3 AAFP2----2A---6 AAFP2----2A---7 AAFP2----2N----
    AAFP2----2N---1 AAFP2----3A---- AAFP2----3A---1 AAFP2----3A---3
    AAFP2----3A---6 AAFP2----3A---7 AAFP2----3N---- AAFP2----3N---1
    AAFP3----1A---- AAFP3----1A---1 AAFP3----1A---6 AAFP3----1A---7
    AAFP3----1N---- AAFP3----1N---1 AAFP3----1N---6 AAFP3----1N---7
    AAFP3----2A---- AAFP3----2A---1 AAFP3----2A---3 AAFP3----2A---5
    AAFP3----2A---6 AAFP3----2A---7 AAFP3----2A---8 AAFP3----2A---9
    AAFP3----2N---- AAFP3----2N---1 AAFP3----2N---6 AAFP3----2N---7
    AAFP3----3A---- AAFP3----3A---1 AAFP3----3A---3 AAFP3----3A---5
    AAFP3----3A---6 AAFP3----3A---7 AAFP3----3A---8 AAFP3----3A---9
    AAFP3----3N---- AAFP3----3N---1 AAFP3----3N---6 AAFP3----3N---7
    AAFP4---------- AAFP4----1A---- AAFP4----1A---1 AAFP4----1A---6
    AAFP4----1N---- AAFP4----1N---1 AAFP4----1N---6 AAFP4----2A----
    AAFP4----2A---1 AAFP4----2A---3 AAFP4----2A---6 AAFP4----2A---7
    AAFP4----2N---- AAFP4----2N---1 AAFP4----3A---- AAFP4----3A---1
    AAFP4----3A---3 AAFP4----3A---6 AAFP4----3A---7 AAFP4----3N----
    AAFP4----3N---1 AAFP4---------6 AAFP5----1A---- AAFP5----1A---1
    AAFP5----1A---6 AAFP5----1N---- AAFP5----1N---1 AAFP5----1N---6
    AAFP5----2A---- AAFP5----2A---1 AAFP5----2A---3 AAFP5----2A---6
    AAFP5----2A---7 AAFP5----2N---- AAFP5----2N---1 AAFP5----3A----
    AAFP5----3A---1 AAFP5----3A---3 AAFP5----3A---6 AAFP5----3A---7
    AAFP5----3N---- AAFP5----3N---1 AAFP6----1A---- AAFP6----1A---1
    AAFP6----1A---6 AAFP6----1N---- AAFP6----1N---1 AAFP6----1N---6
    AAFP6----2A---- AAFP6----2A---1 AAFP6----2A---3 AAFP6----2A---6
    AAFP6----2A---7 AAFP6----2N---- AAFP6----2N---1 AAFP6----3A----
    AAFP6----3A---1 AAFP6----3A---3 AAFP6----3A---6 AAFP6----3A---7
    AAFP6----3N---- AAFP6----3N---1 AAFP7----1A---- AAFP7----1A---1
    AAFP7----1A---6 AAFP7----1A---7 AAFP7----1N---- AAFP7----1N---1
    AAFP7----1N---6 AAFP7----1N---7 AAFP7----2A---- AAFP7----2A---1
    AAFP7----2A---3 AAFP7----2A---5 AAFP7----2A---6 AAFP7----2A---7
    AAFP7----2A---8 AAFP7----2A---9 AAFP7----2N---- AAFP7----2N---1
    AAFP7----2N---6 AAFP7----2N---7 AAFP7----3A---- AAFP7----3A---1
    AAFP7----3A---3 AAFP7----3A---5 AAFP7----3A---6 AAFP7----3A---7
    AAFP7----3A---8 AAFP7----3A---9 AAFP7----3N---- AAFP7----3N---1
    AAFP7----3N---6 AAFP7----3N---7 AAFS1---------- AAFS1----1A----
    AAFS1----1A---1 AAFS1----1N---- AAFS1----1N---1 AAFS1----2A----
    AAFS1----2A---1 AAFS1----2A---3 AAFS1----2A---6 AAFS1----2A---7
    AAFS1----2N---- AAFS1----2N---1 AAFS1----3A---- AAFS1----3A---1
    AAFS1----3A---3 AAFS1----3A---6 AAFS1----3A---7 AAFS1----3N----
    AAFS1----3N---1 AAFS2---------- AAFS2----1A---- AAFS2----1A---1
    AAFS2----1A---6 AAFS2----1N---- AAFS2----1N---1 AAFS2----1N---6
    AAFS2----2A---- AAFS2----2A---1 AAFS2----2A---3 AAFS2----2A---6
    AAFS2----2A---7 AAFS2----2N---- AAFS2----2N---1 AAFS2----3A----
    AAFS2----3A---1 AAFS2----3A---3 AAFS2----3A---6 AAFS2----3A---7
    AAFS2----3N---- AAFS2----3N---1 AAFS2---------6 AAFS3----------
    AAFS3----1A---- AAFS3----1A---1 AAFS3----1A---6 AAFS3----1N----
    AAFS3----1N---1 AAFS3----1N---6 AAFS3----2A---- AAFS3----2A---1
    AAFS3----2A---3 AAFS3----2A---6 AAFS3----2A---7 AAFS3----2N----
    AAFS3----2N---1 AAFS3----3A---- AAFS3----3A---1 AAFS3----3A---3
    AAFS3----3A---6 AAFS3----3A---7 AAFS3----3N---- AAFS3----3N---1
    AAFS3---------6 AAFS4---------- AAFS4----1A---- AAFS4----1A---1
    AAFS4----1A---6 AAFS4----1N---- AAFS4----1N---1 AAFS4----2A----
    AAFS4----2A---1 AAFS4----2A---3 AAFS4----2A---6 AAFS4----2A---7
    AAFS4----2N---- AAFS4----2N---1 AAFS4----3A---- AAFS4----3A---1
    AAFS4----3A---3 AAFS4----3A---6 AAFS4----3A---7 AAFS4----3N----
    AAFS4----3N---1 AAFS5----1A---- AAFS5----1A---1 AAFS5----1N----
    AAFS5----1N---1 AAFS5----2A---- AAFS5----2A---1 AAFS5----2A---3
    AAFS5----2A---6 AAFS5----2A---7 AAFS5----2N---- AAFS5----2N---1
    AAFS5----3A---- AAFS5----3A---1 AAFS5----3A---3 AAFS5----3A---6
    AAFS5----3A---7 AAFS5----3N---- AAFS5----3N---1 AAFS6----------
    AAFS6----1A---- AAFS6----1A---1 AAFS6----1A---6 AAFS6----1N----
    AAFS6----1N---1 AAFS6----1N---6 AAFS6----2A---- AAFS6----2A---1
    AAFS6----2A---3 AAFS6----2A---6 AAFS6----2A---7 AAFS6----2N----
    AAFS6----2N---1 AAFS6----3A---- AAFS6----3A---1 AAFS6----3A---3
    AAFS6----3A---6 AAFS6----3A---7 AAFS6----3N---- AAFS6----3N---1
    AAFS6---------6 AAFS7---------- AAFS7----1A---- AAFS7----1A---1
    AAFS7----1N---- AAFS7----1N---1 AAFS7----2A---- AAFS7----2A---1
    AAFS7----2A---3 AAFS7----2A---6 AAFS7----2A---7 AAFS7----2N----
    AAFS7----2N---1 AAFS7----3A---- AAFS7----3A---1 AAFS7----3A---3
    AAFS7----3A---6 AAFS7----3A---7 AAFS7----3N---- AAFS7----3N---1
    AAFXX----1A---a AAIP1---------- AAIP1----1A---- AAIP1----1A---1
    AAIP1----1A---6 AAIP1----1N---- AAIP1----1N---1 AAIP1----1N---6
    AAIP1----2A---- AAIP1----2A---1 AAIP1----2A---3 AAIP1----2A---6
    AAIP1----2A---7 AAIP1----2N---- AAIP1----2N---1 AAIP1----3A----
    AAIP1----3A---1 AAIP1----3A---3 AAIP1----3A---6 AAIP1----3A---7
    AAIP1----3N---- AAIP1----3N---1 AAIP1---------6 AAIP2----1A----
    AAIP2----1A---1 AAIP2----1A---6 AAIP2----1N---- AAIP2----1N---1
    AAIP2----1N---6 AAIP2----2A---- AAIP2----2A---1 AAIP2----2A---3
    AAIP2----2A---6 AAIP2----2A---7 AAIP2----2N---- AAIP2----2N---1
    AAIP2----3A---- AAIP2----3A---1 AAIP2----3A---3 AAIP2----3A---6
    AAIP2----3A---7 AAIP2----3N---- AAIP2----3N---1 AAIP3----1A----
    AAIP3----1A---1 AAIP3----1A---6 AAIP3----1A---7 AAIP3----1N----
    AAIP3----1N---1 AAIP3----1N---6 AAIP3----1N---7 AAIP3----2A----
    AAIP3----2A---1 AAIP3----2A---3 AAIP3----2A---5 AAIP3----2A---6
    AAIP3----2A---7 AAIP3----2A---8 AAIP3----2A---9 AAIP3----2N----
    AAIP3----2N---1 AAIP3----2N---6 AAIP3----2N---7 AAIP3----3A----
    AAIP3----3A---1 AAIP3----3A---3 AAIP3----3A---5 AAIP3----3A---6
    AAIP3----3A---7 AAIP3----3A---8 AAIP3----3A---9 AAIP3----3N----
    AAIP3----3N---1 AAIP3----3N---6 AAIP3----3N---7 AAIP4----1A----
    AAIP4----1A---1 AAIP4----1A---6 AAIP4----1N---- AAIP4----1N---1
    AAIP4----1N---6 AAIP4----2A---- AAIP4----2A---1 AAIP4----2A---3
    AAIP4----2A---6 AAIP4----2A---7 AAIP4----2N---- AAIP4----2N---1
    AAIP4----3A---- AAIP4----3A---1 AAIP4----3A---3 AAIP4----3A---6
    AAIP4----3A---7 AAIP4----3N---- AAIP4----3N---1 AAIP5----1A----
    AAIP5----1A---1 AAIP5----1A---6 AAIP5----1N---- AAIP5----1N---1
    AAIP5----1N---6 AAIP5----2A---- AAIP5----2A---1 AAIP5----2A---3
    AAIP5----2A---6 AAIP5----2A---7 AAIP5----2N---- AAIP5----2N---1
    AAIP5----3A---- AAIP5----3A---1 AAIP5----3A---3 AAIP5----3A---6
    AAIP5----3A---7 AAIP5----3N---- AAIP5----3N---1 AAIP6----1A----
    AAIP6----1A---1 AAIP6----1A---6 AAIP6----1N---- AAIP6----1N---1
    AAIP6----1N---6 AAIP6----2A---- AAIP6----2A---1 AAIP6----2A---3
    AAIP6----2A---6 AAIP6----2A---7 AAIP6----2N---- AAIP6----2N---1
    AAIP6----3A---- AAIP6----3A---1 AAIP6----3A---3 AAIP6----3A---6
    AAIP6----3A---7 AAIP6----3N---- AAIP6----3N---1 AAIP7----1A----
    AAIP7----1A---1 AAIP7----1A---6 AAIP7----1A---7 AAIP7----1N----
    AAIP7----1N---1 AAIP7----1N---6 AAIP7----1N---7 AAIP7----2A----
    AAIP7----2A---1 AAIP7----2A---3 AAIP7----2A---5 AAIP7----2A---6
    AAIP7----2A---7 AAIP7----2A---8 AAIP7----2A---9 AAIP7----2N----
    AAIP7----2N---1 AAIP7----2N---6 AAIP7----2N---7 AAIP7----3A----
    AAIP7----3A---1 AAIP7----3A---3 AAIP7----3A---5 AAIP7----3A---6
    AAIP7----3A---7 AAIP7----3A---8 AAIP7----3A---9 AAIP7----3N----
    AAIP7----3N---1 AAIP7----3N---6 AAIP7----3N---7 AAIS1----1A----
    AAIS1----1A---1 AAIS1----1A---6 AAIS1----1N---- AAIS1----1N---1
    AAIS1----1N---6 AAIS1----2A---- AAIS1----2A---1 AAIS1----2A---3
    AAIS1----2A---6 AAIS1----2A---7 AAIS1----2N---- AAIS1----2N---1
    AAIS1----3A---- AAIS1----3A---1 AAIS1----3A---3 AAIS1----3A---6
    AAIS1----3A---7 AAIS1----3N---- AAIS1----3N---1 AAIS2----1A----
    AAIS2----1A---1 AAIS2----1A---6 AAIS2----1N---- AAIS2----1N---1
    AAIS2----1N---6 AAIS2----2A---- AAIS2----2A---1 AAIS2----2A---3
    AAIS2----2A---6 AAIS2----2A---7 AAIS2----2N---- AAIS2----2N---1
    AAIS2----3A---- AAIS2----3A---1 AAIS2----3A---3 AAIS2----3A---6
    AAIS2----3A---7 AAIS2----3N---- AAIS2----3N---1 AAIS3----1A----
    AAIS3----1A---1 AAIS3----1A---6 AAIS3----1N---- AAIS3----1N---1
    AAIS3----1N---6 AAIS3----2A---- AAIS3----2A---1 AAIS3----2A---3
    AAIS3----2A---6 AAIS3----2A---7 AAIS3----2N---- AAIS3----2N---1
    AAIS3----3A---- AAIS3----3A---1 AAIS3----3A---3 AAIS3----3A---6
    AAIS3----3A---7 AAIS3----3N---- AAIS3----3N---1 AAIS4----------
    AAIS4----1A---- AAIS4----1A---1 AAIS4----1A---6 AAIS4----1N----
    AAIS4----1N---1 AAIS4----1N---6 AAIS4----2A---- AAIS4----2A---1
    AAIS4----2A---3 AAIS4----2A---6 AAIS4----2A---7 AAIS4----2N----
    AAIS4----2N---1 AAIS4----3A---- AAIS4----3A---1 AAIS4----3A---3
    AAIS4----3A---6 AAIS4----3A---7 AAIS4----3N---- AAIS4----3N---1
    AAIS4---------6 AAIS5----1A---- AAIS5----1A---1 AAIS5----1A---6
    AAIS5----1N---- AAIS5----1N---1 AAIS5----1N---6 AAIS5----2A----
    AAIS5----2A---1 AAIS5----2A---3 AAIS5----2A---6 AAIS5----2A---7
    AAIS5----2N---- AAIS5----2N---1 AAIS5----3A---- AAIS5----3A---1
    AAIS5----3A---3 AAIS5----3A---6 AAIS5----3A---7 AAIS5----3N----
    AAIS5----3N---1 AAIS6----1A---- AAIS6----1A---1 AAIS6----1A---6
    AAIS6----1A---7 AAIS6----1N---- AAIS6----1N---1 AAIS6----1N---6
    AAIS6----1N---7 AAIS6----2A---- AAIS6----2A---1 AAIS6----2A---3
    AAIS6----2A---5 AAIS6----2A---6 AAIS6----2A---7 AAIS6----2A---8
    AAIS6----2A---9 AAIS6----2N---- AAIS6----2N---1 AAIS6----2N---6
    AAIS6----2N---7 AAIS6----3A---- AAIS6----3A---1 AAIS6----3A---3
    AAIS6----3A---5 AAIS6----3A---6 AAIS6----3A---7 AAIS6----3A---8
    AAIS6----3A---9 AAIS6----3N---- AAIS6----3N---1 AAIS6----3N---6
    AAIS6----3N---7 AAIS7----1A---- AAIS7----1A---1 AAIS7----1A---6
    AAIS7----1A---7 AAIS7----1N---- AAIS7----1N---1 AAIS7----1N---6
    AAIS7----1N---7 AAIS7----2A---- AAIS7----2A---1 AAIS7----2A---3
    AAIS7----2A---5 AAIS7----2A---6 AAIS7----2A---7 AAIS7----2A---8
    AAIS7----2A---9 AAIS7----2N---- AAIS7----2N---1 AAIS7----2N---6
    AAIS7----2N---7 AAIS7----3A---- AAIS7----3A---1 AAIS7----3A---3
    AAIS7----3A---5 AAIS7----3A---6 AAIS7----3A---7 AAIS7----3A---8
    AAIS7----3A---9 AAIS7----3N---- AAIS7----3N---1 AAIS7----3N---6
    AAIS7----3N---7 AAMP1---------- AAMP1----1A---- AAMP1----1A---1
    AAMP1----1A---6 AAMP1----1A---7 AAMP1----1N---- AAMP1----1N---1
    AAMP1----1N---6 AAMP1----2A---- AAMP1----2A---1 AAMP1----2A---3
    AAMP1----2A---6 AAMP1----2A---7 AAMP1----2N---- AAMP1----2N---1
    AAMP1----3A---- AAMP1----3A---1 AAMP1----3A---3 AAMP1----3A---6
    AAMP1----3A---7 AAMP1----3N---- AAMP1----3N---1 AAMP1---------6
    AAMP2----1A---- AAMP2----1A---1 AAMP2----1A---6 AAMP2----1N----
    AAMP2----1N---1 AAMP2----1N---6 AAMP2----2A---- AAMP2----2A---1
    AAMP2----2A---3 AAMP2----2A---6 AAMP2----2A---7 AAMP2----2N----
    AAMP2----2N---1 AAMP2----3A---- AAMP2----3A---1 AAMP2----3A---3
    AAMP2----3A---6 AAMP2----3A---7 AAMP2----3N---- AAMP2----3N---1
    AAMP3----1A---- AAMP3----1A---1 AAMP3----1A---6 AAMP3----1A---7
    AAMP3----1N---- AAMP3----1N---1 AAMP3----1N---6 AAMP3----1N---7
    AAMP3----2A---- AAMP3----2A---1 AAMP3----2A---3 AAMP3----2A---5
    AAMP3----2A---6 AAMP3----2A---7 AAMP3----2A---8 AAMP3----2A---9
    AAMP3----2N---- AAMP3----2N---1 AAMP3----2N---6 AAMP3----2N---7
    AAMP3----3A---- AAMP3----3A---1 AAMP3----3A---3 AAMP3----3A---5
    AAMP3----3A---6 AAMP3----3A---7 AAMP3----3A---8 AAMP3----3A---9
    AAMP3----3N---- AAMP3----3N---1 AAMP3----3N---6 AAMP3----3N---7
    AAMP4----1A---- AAMP4----1A---1 AAMP4----1A---6 AAMP4----1N----
    AAMP4----1N---1 AAMP4----1N---6 AAMP4----2A---- AAMP4----2A---1
    AAMP4----2A---3 AAMP4----2A---6 AAMP4----2A---7 AAMP4----2N----
    AAMP4----2N---1 AAMP4----3A---- AAMP4----3A---1 AAMP4----3A---3
    AAMP4----3A---6 AAMP4----3A---7 AAMP4----3N---- AAMP4----3N---1
    AAMP5----1A---- AAMP5----1A---1 AAMP5----1A---6 AAMP5----1A---7
    AAMP5----1N---- AAMP5----1N---1 AAMP5----1N---6 AAMP5----2A----
    AAMP5----2A---1 AAMP5----2A---3 AAMP5----2A---6 AAMP5----2A---7
    AAMP5----2N---- AAMP5----2N---1 AAMP5----3A---- AAMP5----3A---1
    AAMP5----3A---3 AAMP5----3A---6 AAMP5----3A---7 AAMP5----3N----
    AAMP5----3N---1 AAMP6----1A---- AAMP6----1A---1 AAMP6----1A---6
    AAMP6----1N---- AAMP6----1N---1 AAMP6----1N---6 AAMP6----2A----
    AAMP6----2A---1 AAMP6----2A---3 AAMP6----2A---6 AAMP6----2A---7
    AAMP6----2N---- AAMP6----2N---1 AAMP6----3A---- AAMP6----3A---1
    AAMP6----3A---3 AAMP6----3A---6 AAMP6----3A---7 AAMP6----3N----
    AAMP6----3N---1 AAMP7----1A---- AAMP7----1A---1 AAMP7----1A---6
    AAMP7----1A---7 AAMP7----1N---- AAMP7----1N---1 AAMP7----1N---6
    AAMP7----1N---7 AAMP7----2A---- AAMP7----2A---1 AAMP7----2A---3
    AAMP7----2A---5 AAMP7----2A---6 AAMP7----2A---7 AAMP7----2A---8
    AAMP7----2A---9 AAMP7----2N---- AAMP7----2N---1 AAMP7----2N---6
    AAMP7----2N---7 AAMP7----3A---- AAMP7----3A---1 AAMP7----3A---3
    AAMP7----3A---5 AAMP7----3A---6 AAMP7----3A---7 AAMP7----3A---8
    AAMP7----3A---9 AAMP7----3N---- AAMP7----3N---1 AAMP7----3N---6
    AAMP7----3N---7 AAMS1----1A---- AAMS1----1A---1 AAMS1----1A---6
    AAMS1----1N---- AAMS1----1N---1 AAMS1----1N---6 AAMS1----2A----
    AAMS1----2A---1 AAMS1----2A---3 AAMS1----2A---6 AAMS1----2A---7
    AAMS1----2N---- AAMS1----2N---1 AAMS1----3A---- AAMS1----3A---1
    AAMS1----3A---3 AAMS1----3A---6 AAMS1----3A---7 AAMS1----3N----
    AAMS1----3N---1 AAMS2----1A---- AAMS2----1A---1 AAMS2----1A---6
    AAMS2----1N---- AAMS2----1N---1 AAMS2----1N---6 AAMS2----2A----
    AAMS2----2A---1 AAMS2----2A---3 AAMS2----2A---6 AAMS2----2A---7
    AAMS2----2N---- AAMS2----2N---1 AAMS2----3A---- AAMS2----3A---1
    AAMS2----3A---3 AAMS2----3A---6 AAMS2----3A---7 AAMS2----3N----
    AAMS2----3N---1 AAMS3----1A---- AAMS3----1A---1 AAMS3----1A---6
    AAMS3----1N---- AAMS3----1N---1 AAMS3----1N---6 AAMS3----2A----
    AAMS3----2A---1 AAMS3----2A---3 AAMS3----2A---6 AAMS3----2A---7
    AAMS3----2N---- AAMS3----2N---1 AAMS3----3A---- AAMS3----3A---1
    AAMS3----3A---3 AAMS3----3A---6 AAMS3----3A---7 AAMS3----3N----
    AAMS3----3N---1 AAMS4---------- AAMS4----1A---- AAMS4----1A---1
    AAMS4----1A---6 AAMS4----1N---- AAMS4----1N---1 AAMS4----1N---6
    AAMS4----2A---- AAMS4----2A---1 AAMS4----2A---3 AAMS4----2A---6
    AAMS4----2A---7 AAMS4----2N---- AAMS4----2N---1 AAMS4----3A----
    AAMS4----3A---1 AAMS4----3A---3 AAMS4----3A---6 AAMS4----3A---7
    AAMS4----3N---- AAMS4----3N---1 AAMS4---------6 AAMS5----1A----
    AAMS5----1A---1 AAMS5----1A---6 AAMS5----1N---- AAMS5----1N---1
    AAMS5----1N---6 AAMS5----2A---- AAMS5----2A---1 AAMS5----2A---3
    AAMS5----2A---6 AAMS5----2A---7 AAMS5----2N---- AAMS5----2N---1
    AAMS5----3A---- AAMS5----3A---1 AAMS5----3A---3 AAMS5----3A---6
    AAMS5----3A---7 AAMS5----3N---- AAMS5----3N---1 AAMS6----1A----
    AAMS6----1A---1 AAMS6----1A---6 AAMS6----1A---7 AAMS6----1N----
    AAMS6----1N---1 AAMS6----1N---6 AAMS6----1N---7 AAMS6----2A----
    AAMS6----2A---1 AAMS6----2A---3 AAMS6----2A---5 AAMS6----2A---6
    AAMS6----2A---7 AAMS6----2A---8 AAMS6----2A---9 AAMS6----2N----
    AAMS6----2N---1 AAMS6----2N---6 AAMS6----2N---7 AAMS6----3A----
    AAMS6----3A---1 AAMS6----3A---3 AAMS6----3A---5 AAMS6----3A---6
    AAMS6----3A---7 AAMS6----3A---8 AAMS6----3A---9 AAMS6----3N----
    AAMS6----3N---1 AAMS6----3N---6 AAMS6----3N---7 AAMS7----1A----
    AAMS7----1A---1 AAMS7----1A---6 AAMS7----1A---7 AAMS7----1N----
    AAMS7----1N---1 AAMS7----1N---6 AAMS7----1N---7 AAMS7----2A----
    AAMS7----2A---1 AAMS7----2A---3 AAMS7----2A---5 AAMS7----2A---6
    AAMS7----2A---7 AAMS7----2A---8 AAMS7----2A---9 AAMS7----2N----
    AAMS7----2N---1 AAMS7----2N---6 AAMS7----2N---7 AAMS7----3A----
    AAMS7----3A---1 AAMS7----3A---3 AAMS7----3A---5 AAMS7----3A---6
    AAMS7----3A---7 AAMS7----3A---8 AAMS7----3A---9 AAMS7----3N----
    AAMS7----3N---1 AAMS7----3N---6 AAMS7----3N---7 AANP1----------
    AANP1----1A---- AANP1----1A---1 AANP1----1A---6 AANP1----1A---7
    AANP1----1N---- AANP1----1N---1 AANP1----1N---6 AANP1----1N---7
    AANP1----2A---- AANP1----2A---1 AANP1----2A---3 AANP1----2A---6
    AANP1----2A---7 AANP1----2N---- AANP1----2N---1 AANP1----3A----
    AANP1----3A---1 AANP1----3A---3 AANP1----3A---6 AANP1----3A---7
    AANP1----3N---- AANP1----3N---1 AANP1---------6 AANP2----1A----
    AANP2----1A---1 AANP2----1A---6 AANP2----1N---- AANP2----1N---1
    AANP2----1N---6 AANP2----2A---- AANP2----2A---1 AANP2----2A---3
    AANP2----2A---6 AANP2----2A---7 AANP2----2N---- AANP2----2N---1
    AANP2----3A---- AANP2----3A---1 AANP2----3A---3 AANP2----3A---6
    AANP2----3A---7 AANP2----3N---- AANP2----3N---1 AANP3----1A----
    AANP3----1A---1 AANP3----1A---6 AANP3----1A---7 AANP3----1N----
    AANP3----1N---1 AANP3----1N---6 AANP3----1N---7 AANP3----2A----
    AANP3----2A---1 AANP3----2A---3 AANP3----2A---5 AANP3----2A---6
    AANP3----2A---7 AANP3----2A---8 AANP3----2A---9 AANP3----2N----
    AANP3----2N---1 AANP3----2N---6 AANP3----2N---7 AANP3----3A----
    AANP3----3A---1 AANP3----3A---3 AANP3----3A---5 AANP3----3A---6
    AANP3----3A---7 AANP3----3A---8 AANP3----3A---9 AANP3----3N----
    AANP3----3N---1 AANP3----3N---6 AANP3----3N---7 AANP4----------
    AANP4----1A---- AANP4----1A---1 AANP4----1A---6 AANP4----1A---7
    AANP4----1N---- AANP4----1N---1 AANP4----1N---6 AANP4----1N---7
    AANP4----2A---- AANP4----2A---1 AANP4----2A---3 AANP4----2A---6
    AANP4----2A---7 AANP4----2N---- AANP4----2N---1 AANP4----3A----
    AANP4----3A---1 AANP4----3A---3 AANP4----3A---6 AANP4----3A---7
    AANP4----3N---- AANP4----3N---1 AANP4---------6 AANP5----1A----
    AANP5----1A---1 AANP5----1A---6 AANP5----1A---7 AANP5----1N----
    AANP5----1N---1 AANP5----1N---6 AANP5----1N---7 AANP5----2A----
    AANP5----2A---1 AANP5----2A---3 AANP5----2A---6 AANP5----2A---7
    AANP5----2N---- AANP5----2N---1 AANP5----3A---- AANP5----3A---1
    AANP5----3A---3 AANP5----3A---6 AANP5----3A---7 AANP5----3N----
    AANP5----3N---1 AANP6----1A---- AANP6----1A---1 AANP6----1A---6
    AANP6----1N---- AANP6----1N---1 AANP6----1N---6 AANP6----2A----
    AANP6----2A---1 AANP6----2A---3 AANP6----2A---6 AANP6----2A---7
    AANP6----2N---- AANP6----2N---1 AANP6----3A---- AANP6----3A---1
    AANP6----3A---3 AANP6----3A---6 AANP6----3A---7 AANP6----3N----
    AANP6----3N---1 AANP7----1A---- AANP7----1A---1 AANP7----1A---6
    AANP7----1A---7 AANP7----1N---- AANP7----1N---1 AANP7----1N---6
    AANP7----1N---7 AANP7----2A---- AANP7----2A---1 AANP7----2A---3
    AANP7----2A---5 AANP7----2A---6 AANP7----2A---7 AANP7----2A---8
    AANP7----2A---9 AANP7----2N---- AANP7----2N---1 AANP7----2N---6
    AANP7----2N---7 AANP7----3A---- AANP7----3A---1 AANP7----3A---3
    AANP7----3A---5 AANP7----3A---6 AANP7----3A---7 AANP7----3A---8
    AANP7----3A---9 AANP7----3N---- AANP7----3N---1 AANP7----3N---6
    AANP7----3N---7 AANS1---------- AANS1----1A---- AANS1----1A---1
    AANS1----1A---6 AANS1----1N---- AANS1----1N---1 AANS1----1N---6
    AANS1----2A---- AANS1----2A---1 AANS1----2A---3 AANS1----2A---6
    AANS1----2A---7 AANS1----2N---- AANS1----2N---1 AANS1----3A----
    AANS1----3A---1 AANS1----3A---3 AANS1----3A---6 AANS1----3A---7
    AANS1----3N---- AANS1----3N---1 AANS1---------6 AANS2----1A----
    AANS2----1A---1 AANS2----1A---6 AANS2----1N---- AANS2----1N---1
    AANS2----1N---6 AANS2----2A---- AANS2----2A---1 AANS2----2A---3
    AANS2----2A---6 AANS2----2A---7 AANS2----2N---- AANS2----2N---1
    AANS2----3A---- AANS2----3A---1 AANS2----3A---3 AANS2----3A---6
    AANS2----3A---7 AANS2----3N---- AANS2----3N---1 AANS3----1A----
    AANS3----1A---1 AANS3----1A---6 AANS3----1N---- AANS3----1N---1
    AANS3----1N---6 AANS3----2A---- AANS3----2A---1 AANS3----2A---3
    AANS3----2A---6 AANS3----2A---7 AANS3----2N---- AANS3----2N---1
    AANS3----3A---- AANS3----3A---1 AANS3----3A---3 AANS3----3A---6
    AANS3----3A---7 AANS3----3N---- AANS3----3N---1 AANS4----------
    AANS4----1A---- AANS4----1A---1 AANS4----1A---6 AANS4----1A---b
    AANS4----1N---- AANS4----1N---1 AANS4----1N---6 AANS4----2A----
    AANS4----2A---1 AANS4----2A---3 AANS4----2A---6 AANS4----2A---7
    AANS4----2N---- AANS4----2N---1 AANS4----3A---- AANS4----3A---1
    AANS4----3A---3 AANS4----3A---6 AANS4----3A---7 AANS4----3N----
    AANS4----3N---1 AANS4---------6 AANS5----1A---- AANS5----1A---1
    AANS5----1A---6 AANS5----1N---- AANS5----1N---1 AANS5----1N---6
    AANS5----2A---- AANS5----2A---1 AANS5----2A---3 AANS5----2A---6
    AANS5----2A---7 AANS5----2N---- AANS5----2N---1 AANS5----3A----
    AANS5----3A---1 AANS5----3A---3 AANS5----3A---6 AANS5----3A---7
    AANS5----3N---- AANS5----3N---1 AANS6----1A---- AANS6----1A---1
    AANS6----1A---6 AANS6----1A---7 AANS6----1N---- AANS6----1N---1
    AANS6----1N---6 AANS6----1N---7 AANS6----2A---- AANS6----2A---1
    AANS6----2A---3 AANS6----2A---5 AANS6----2A---6 AANS6----2A---7
    AANS6----2A---8 AANS6----2A---9 AANS6----2N---- AANS6----2N---1
    AANS6----2N---6 AANS6----2N---7 AANS6----3A---- AANS6----3A---1
    AANS6----3A---3 AANS6----3A---5 AANS6----3A---6 AANS6----3A---7
    AANS6----3A---8 AANS6----3A---9 AANS6----3N---- AANS6----3N---1
    AANS6----3N---6 AANS6----3N---7 AANS7----1A---- AANS7----1A---1
    AANS7----1A---6 AANS7----1A---7 AANS7----1A---b AANS7----1N----
    AANS7----1N---1 AANS7----1N---6 AANS7----1N---7 AANS7----2A----
    AANS7----2A---1 AANS7----2A---3 AANS7----2A---5 AANS7----2A---6
    AANS7----2A---7 AANS7----2A---8 AANS7----2A---9 AANS7----2N----
    AANS7----2N---1 AANS7----2N---6 AANS7----2N---7 AANS7----3A----
    AANS7----3A---1 AANS7----3A---3 AANS7----3A---5 AANS7----3A---6
    AANS7----3A---7 AANS7----3A---8 AANS7----3A---9 AANS7----3N----
    AANS7----3N---1 AANS7----3N---6 AANS7----3N---7 AAXP2----------
    AAXP2---------6 AAXP3---------- AAXP3---------6 AAXP6----------
    AAXP6---------6 AAXP7---------- AAXP7---------6 AAXP7---------7
    AAXXX----1A---- AAXXX----1A---1 AAXXX----1A---a AAXXX----1A---b
    AAXXX----1N---- AAXXX----1N---a AAXXX----1N---b AAXXX----2A---b
    AAXXX----3A---b AAXXX-----A---b AAYP4---------- AAYP4---------6
    AAYS1---------- AAYS1---------6 AAZS2---------- AAZS2---------6
    AAZS3---------- AAZS3---------6 AAZS6---------- AAZS6---------7
    AAZS7---------- ACFS4-----A---- ACFS4-----N---- ACMP------A----
    ACMP------N---- ACNS------A---- ACNS------N---- ACQW------A----
    ACQW------N---- ACTP------A---- ACTP------N---- ACYS------A----
    ACYS------N---- AGFD7-----A---- AGFD7-----N---- AGFP1-----A----
    AGFP1-----N---- AGFP2-----A---- AGFP2-----N---- AGFP3-----A----
    AGFP3-----A---6 AGFP3-----N---- AGFP3-----N---6 AGFP4-----A----
    AGFP4-----N---- AGFP5-----A---- AGFP5-----N---- AGFP6-----A----
    AGFP6-----N---- AGFP7-----A---- AGFP7-----A---6 AGFP7-----N----
    AGFP7-----N---6 AGFS1-----A---- AGFS1-----N---- AGFS2-----A----
    AGFS2-----N---- AGFS3-----A---- AGFS3-----N---- AGFS4-----A----
    AGFS4-----N---- AGFS5-----A---- AGFS5-----N---- AGFS6-----A----
    AGFS6-----N---- AGFS7-----A---- AGFS7-----N---- AGIP1-----A----
    AGIP1-----N---- AGIP2-----A---- AGIP2-----N---- AGIP3-----A----
    AGIP3-----A---6 AGIP3-----N---- AGIP3-----N---6 AGIP4-----A----
    AGIP4-----N---- AGIP5-----A---- AGIP5-----N---- AGIP6-----A----
    AGIP6-----N---- AGIP7-----A---- AGIP7-----A---6 AGIP7-----N----
    AGIP7-----N---6 AGIS1-----A---- AGIS1-----N---- AGIS2-----A----
    AGIS2-----N---- AGIS3-----A---- AGIS3-----N---- AGIS4-----A----
    AGIS4-----N---- AGIS5-----A---- AGIS5-----N---- AGIS6-----A----
    AGIS6-----A---6 AGIS6-----N---- AGIS6-----N---6 AGIS7-----A----
    AGIS7-----A---6 AGIS7-----N---- AGIS7-----N---6 AGMP1-----A----
    AGMP1-----N---- AGMP2-----A---- AGMP2-----N---- AGMP3-----A----
    AGMP3-----A---6 AGMP3-----N---- AGMP3-----N---6 AGMP4-----A----
    AGMP4-----N---- AGMP5-----A---- AGMP5-----N---- AGMP6-----A----
    AGMP6-----N---- AGMP7-----A---- AGMP7-----A---6 AGMP7-----N----
    AGMP7-----N---6 AGMS1-----A---- AGMS1-----N---- AGMS2-----A----
    AGMS2-----N---- AGMS3-----A---- AGMS3-----N---- AGMS4-----A----
    AGMS4-----N---- AGMS5-----A---- AGMS5-----N---- AGMS6-----A----
    AGMS6-----A---6 AGMS6-----N---- AGMS6-----N---6 AGMS7-----A----
    AGMS7-----A---6 AGMS7-----N---- AGMS7-----N---6 AGNP1-----A----
    AGNP1-----N---- AGNP2-----A---- AGNP2-----N---- AGNP3-----A----
    AGNP3-----A---6 AGNP3-----N---- AGNP3-----N---6 AGNP4-----A----
    AGNP4-----N---- AGNP5-----A---- AGNP5-----N---- AGNP6-----A----
    AGNP6-----N---- AGNP7-----A---- AGNP7-----A---6 AGNP7-----N----
    AGNP7-----N---6 AGNS1-----A---- AGNS1-----N---- AGNS2-----A----
    AGNS2-----N---- AGNS3-----A---- AGNS3-----N---- AGNS4-----A----
    AGNS4-----N---- AGNS5-----A---- AGNS5-----N---- AGNS6-----A----
    AGNS6-----A---6 AGNS6-----N---- AGNS6-----N---6 AGNS7-----A----
    AGNS7-----A---6 AGNS7-----N---- AGNS7-----N---6 AMFD7-----A----
    AMFD7-----A---1 AMFD7-----N---- AMFD7-----N---1 AMFP1-----A----
    AMFP1-----A---1 AMFP1-----N---- AMFP1-----N---1 AMFP2-----A----
    AMFP2-----A---1 AMFP2-----N---- AMFP2-----N---1 AMFP3-----A----
    AMFP3-----A---1 AMFP3-----A---6 AMFP3-----A---7 AMFP3-----N----
    AMFP3-----N---1 AMFP3-----N---6 AMFP3-----N---7 AMFP4-----A----
    AMFP4-----A---1 AMFP4-----N---- AMFP4-----N---1 AMFP5-----A----
    AMFP5-----A---1 AMFP5-----N---- AMFP5-----N---1 AMFP6-----A----
    AMFP6-----A---1 AMFP6-----N---- AMFP6-----N---1 AMFP7-----A----
    AMFP7-----A---1 AMFP7-----A---6 AMFP7-----A---7 AMFP7-----N----
    AMFP7-----N---1 AMFP7-----N---6 AMFP7-----N---7 AMFS1-----A----
    AMFS1-----A---1 AMFS1-----N---- AMFS1-----N---1 AMFS2-----A----
    AMFS2-----A---1 AMFS2-----N---- AMFS2-----N---1 AMFS3-----A----
    AMFS3-----A---1 AMFS3-----N---- AMFS3-----N---1 AMFS4-----A----
    AMFS4-----A---1 AMFS4-----N---- AMFS4-----N---1 AMFS5-----A----
    AMFS5-----A---1 AMFS5-----N---- AMFS5-----N---1 AMFS6-----A----
    AMFS6-----A---1 AMFS6-----N---- AMFS6-----N---1 AMFS7-----A----
    AMFS7-----A---1 AMFS7-----N---- AMFS7-----N---1 AMIP1-----A----
    AMIP1-----A---1 AMIP1-----N---- AMIP1-----N---1 AMIP2-----A----
    AMIP2-----A---1 AMIP2-----N---- AMIP2-----N---1 AMIP3-----A----
    AMIP3-----A---1 AMIP3-----A---6 AMIP3-----A---7 AMIP3-----N----
    AMIP3-----N---1 AMIP3-----N---6 AMIP3-----N---7 AMIP4-----A----
    AMIP4-----A---1 AMIP4-----N---- AMIP4-----N---1 AMIP5-----A----
    AMIP5-----A---1 AMIP5-----N---- AMIP5-----N---1 AMIP6-----A----
    AMIP6-----A---1 AMIP6-----N---- AMIP6-----N---1 AMIP7-----A----
    AMIP7-----A---1 AMIP7-----A---6 AMIP7-----A---7 AMIP7-----N----
    AMIP7-----N---1 AMIP7-----N---6 AMIP7-----N---7 AMIS1-----A----
    AMIS1-----A---1 AMIS1-----N---- AMIS1-----N---1 AMIS2-----A----
    AMIS2-----A---1 AMIS2-----N---- AMIS2-----N---1 AMIS3-----A----
    AMIS3-----A---1 AMIS3-----N---- AMIS3-----N---1 AMIS4-----A----
    AMIS4-----A---1 AMIS4-----N---- AMIS4-----N---1 AMIS5-----A----
    AMIS5-----A---1 AMIS5-----N---- AMIS5-----N---1 AMIS6-----A----
    AMIS6-----A---1 AMIS6-----A---6 AMIS6-----A---7 AMIS6-----N----
    AMIS6-----N---1 AMIS6-----N---6 AMIS6-----N---7 AMIS7-----A----
    AMIS7-----A---1 AMIS7-----A---6 AMIS7-----A---7 AMIS7-----N----
    AMIS7-----N---1 AMIS7-----N---6 AMIS7-----N---7 AMMP1-----A----
    AMMP1-----A---1 AMMP1-----N---- AMMP1-----N---1 AMMP2-----A----
    AMMP2-----A---1 AMMP2-----N---- AMMP2-----N---1 AMMP3-----A----
    AMMP3-----A---1 AMMP3-----A---6 AMMP3-----A---7 AMMP3-----N----
    AMMP3-----N---1 AMMP3-----N---6 AMMP3-----N---7 AMMP4-----A----
    AMMP4-----A---1 AMMP4-----N---- AMMP4-----N---1 AMMP5-----A----
    AMMP5-----A---1 AMMP5-----N---- AMMP5-----N---1 AMMP6-----A----
    AMMP6-----A---1 AMMP6-----N---- AMMP6-----N---1 AMMP7-----A----
    AMMP7-----A---1 AMMP7-----A---6 AMMP7-----A---7 AMMP7-----N----
    AMMP7-----N---1 AMMP7-----N---6 AMMP7-----N---7 AMMS1-----A----
    AMMS1-----A---1 AMMS1-----N---- AMMS1-----N---1 AMMS2-----A----
    AMMS2-----A---1 AMMS2-----N---- AMMS2-----N---1 AMMS3-----A----
    AMMS3-----A---1 AMMS3-----N---- AMMS3-----N---1 AMMS4-----A----
    AMMS4-----A---1 AMMS4-----N---- AMMS4-----N---1 AMMS5-----A----
    AMMS5-----A---1 AMMS5-----N---- AMMS5-----N---1 AMMS6-----A----
    AMMS6-----A---1 AMMS6-----A---6 AMMS6-----A---7 AMMS6-----N----
    AMMS6-----N---1 AMMS6-----N---6 AMMS6-----N---7 AMMS7-----A----
    AMMS7-----A---1 AMMS7-----A---6 AMMS7-----A---7 AMMS7-----N----
    AMMS7-----N---1 AMMS7-----N---6 AMMS7-----N---7 AMNP1-----A----
    AMNP1-----A---1 AMNP1-----N---- AMNP1-----N---1 AMNP2-----A----
    AMNP2-----A---1 AMNP2-----N---- AMNP2-----N---1 AMNP3-----A----
    AMNP3-----A---1 AMNP3-----A---6 AMNP3-----A---7 AMNP3-----N----
    AMNP3-----N---1 AMNP3-----N---6 AMNP3-----N---7 AMNP4-----A----
    AMNP4-----A---1 AMNP4-----N---- AMNP4-----N---1 AMNP5-----A----
    AMNP5-----A---1 AMNP5-----N---- AMNP5-----N---1 AMNP6-----A----
    AMNP6-----A---1 AMNP6-----N---- AMNP6-----N---1 AMNP7-----A----
    AMNP7-----A---1 AMNP7-----A---6 AMNP7-----A---7 AMNP7-----N----
    AMNP7-----N---1 AMNP7-----N---6 AMNP7-----N---7 AMNS1-----A----
    AMNS1-----A---1 AMNS1-----N---- AMNS1-----N---1 AMNS2-----A----
    AMNS2-----A---1 AMNS2-----N---- AMNS2-----N---1 AMNS3-----A----
    AMNS3-----A---1 AMNS3-----N---- AMNS3-----N---1 AMNS4-----A----
    AMNS4-----A---1 AMNS4-----N---- AMNS4-----N---1 AMNS5-----A----
    AMNS5-----A---1 AMNS5-----N---- AMNS5-----N---1 AMNS6-----A----
    AMNS6-----A---1 AMNS6-----A---6 AMNS6-----A---7 AMNS6-----N----
    AMNS6-----N---1 AMNS6-----N---6 AMNS6-----N---7 AMNS7-----A----
    AMNS7-----A---1 AMNS7-----A---6 AMNS7-----A---7 AMNS7-----N----
    AMNS7-----N---1 AMNS7-----N---6 AMNS7-----N---7 AOFP-----------
    AOFP----------1 AOFP----------6 AOFS----------- AOFS----------1
    AOIP----------- AOIP----------1 AOIP----------6 AOMP-----------
    AOMP----------1 AOMP----------6 AONP----------- AONP----------1
    AONP----------6 AONS----------- AONS----------1 AONS----------6
    AOYS----------- AOYS----------6 AUFD7F--------- AUFD7F--------6
    AUFD7M--------- AUFD7M--------1 AUFD7M--------6 AUFD7M--------7
    AUFP1F--------- AUFP1M--------- AUFP1M--------1 AUFP2F---------
    AUFP2F--------6 AUFP2M--------- AUFP2M--------1 AUFP2M--------6
    AUFP2M--------7 AUFP3F--------- AUFP3F--------6 AUFP3M---------
    AUFP3M--------1 AUFP3M--------6 AUFP3M--------7 AUFP4F---------
    AUFP4M--------- AUFP4M--------1 AUFP5F--------- AUFP5M---------
    AUFP5M--------1 AUFP6F--------- AUFP6F--------6 AUFP6M---------
    AUFP6M--------1 AUFP6M--------6 AUFP6M--------7 AUFP7F---------
    AUFP7F--------6 AUFP7M--------- AUFP7M--------1 AUFP7M--------6
    AUFP7M--------7 AUFP7M--------8 AUFS1F--------- AUFS1M---------
    AUFS1M--------1 AUFS2F--------- AUFS2M--------- AUFS2M--------1
    AUFS3F--------- AUFS3M--------- AUFS3M--------1 AUFS4F---------
    AUFS4M--------- AUFS4M--------1 AUFS5F--------- AUFS5M---------
    AUFS5M--------1 AUFS6F--------- AUFS6M--------- AUFS6M--------1
    AUFS7F--------- AUFS7M--------- AUFS7M--------1 AUIP1F---------
    AUIP1M--------- AUIP1M--------1 AUIP2F--------- AUIP2F--------6
    AUIP2M--------- AUIP2M--------1 AUIP2M--------6 AUIP2M--------7
    AUIP3F--------- AUIP3F--------6 AUIP3M--------- AUIP3M--------1
    AUIP3M--------6 AUIP3M--------7 AUIP4F--------- AUIP4M---------
    AUIP4M--------1 AUIP5F--------- AUIP5M--------- AUIP5M--------1
    AUIP6F--------- AUIP6F--------6 AUIP6M--------- AUIP6M--------1
    AUIP6M--------6 AUIP6M--------7 AUIP7F--------- AUIP7F--------6
    AUIP7M--------- AUIP7M--------1 AUIP7M--------6 AUIP7M--------7
    AUIP7M--------8 AUIS1F--------- AUIS1M--------- AUIS1M--------1
    AUIS1M--------6 AUIS1M--------7 AUIS2F--------- AUIS2F--------6
    AUIS2M--------- AUIS2M--------1 AUIS3F--------- AUIS3M---------
    AUIS3M--------1 AUIS3M--------6 AUIS3M--------7 AUIS4F---------
    AUIS4M--------- AUIS4M--------1 AUIS4M--------6 AUIS4M--------7
    AUIS5F--------- AUIS5M--------- AUIS5M--------1 AUIS5M--------6
    AUIS5M--------7 AUIS6F--------- AUIS6F--------1 AUIS6F--------6
    AUIS6F--------7 AUIS6M--------- AUIS6M--------1 AUIS6M--------2
    AUIS7F--------- AUIS7F--------6 AUIS7M--------- AUIS7M--------1
    AUIS7M--------6 AUIS7M--------7 AUMP1F--------- AUMP1M---------
    AUMP1M--------1 AUMP2F--------- AUMP2F--------6 AUMP2M---------
    AUMP2M--------1 AUMP2M--------6 AUMP2M--------7 AUMP3F---------
    AUMP3F--------6 AUMP3M--------- AUMP3M--------1 AUMP3M--------6
    AUMP3M--------7 AUMP4F--------- AUMP4M--------- AUMP4M--------1
    AUMP5F--------- AUMP5M--------- AUMP5M--------1 AUMP6F---------
    AUMP6F--------6 AUMP6M--------- AUMP6M--------1 AUMP6M--------6
    AUMP6M--------7 AUMP7F--------- AUMP7F--------6 AUMP7M---------
    AUMP7M--------1 AUMP7M--------6 AUMP7M--------7 AUMP7M--------8
    AUMS1F--------- AUMS1M--------- AUMS1M--------1 AUMS1M--------6
    AUMS1M--------7 AUMS2F--------- AUMS2F--------6 AUMS2M---------
    AUMS2M--------1 AUMS3F--------- AUMS3M--------- AUMS3M--------1
    AUMS3M--------6 AUMS3M--------7 AUMS4F--------- AUMS4F--------6
    AUMS4M--------- AUMS4M--------1 AUMS5F--------- AUMS5M---------
    AUMS5M--------1 AUMS5M--------6 AUMS5M--------7 AUMS6F---------
    AUMS6F--------1 AUMS6F--------6 AUMS6F--------7 AUMS6M---------
    AUMS6M--------1 AUMS6M--------2 AUMS7F--------- AUMS7F--------6
    AUMS7M--------- AUMS7M--------1 AUMS7M--------6 AUMS7M--------7
    AUNP1F--------- AUNP1M--------- AUNP1M--------1 AUNP2F---------
    AUNP2F--------6 AUNP2M--------- AUNP2M--------1 AUNP2M--------6
    AUNP2M--------7 AUNP3F--------- AUNP3F--------6 AUNP3M---------
    AUNP3M--------1 AUNP3M--------6 AUNP3M--------7 AUNP4F---------
    AUNP4M--------- AUNP4M--------1 AUNP5F--------- AUNP5M---------
    AUNP5M--------1 AUNP6F--------- AUNP6F--------6 AUNP6M---------
    AUNP6M--------1 AUNP6M--------6 AUNP6M--------7 AUNP7F---------
    AUNP7F--------6 AUNP7M--------- AUNP7M--------1 AUNP7M--------6
    AUNP7M--------7 AUNP7M--------8 AUNS1F--------- AUNS1M---------
    AUNS1M--------1 AUNS2F--------- AUNS2F--------6 AUNS2M---------
    AUNS2M--------1 AUNS3F--------- AUNS3M--------- AUNS3M--------1
    AUNS3M--------6 AUNS3M--------7 AUNS4F--------- AUNS4M---------
    AUNS4M--------1 AUNS5F--------- AUNS5M--------- AUNS5M--------1
    AUNS6F--------- AUNS6F--------1 AUNS6F--------6 AUNS6F--------7
    AUNS6M--------- AUNS6M--------1 AUNS6M--------2 AUNS7F---------
    AUNS7F--------6 AUNS7M--------- AUNS7M--------1 AUNS7M--------6
    AUNS7M--------7 AUXXXF--------7 AUXXXM--------- AUXXXM--------5
    AUXXXM--------6 AUXXXM--------7 AUXXXM--------8 AUXXXM--------a
    AUXXXM--------b B^------------- BAXXX----1A---- Bb-------------
    BNFXX-----A---- BNIXX-----A---- BNMXX-----A---- BNNXX-----A----
    BNXXX-----A---- C}------------- C?--1---------- C}------------1
    C}------------2 C?--4---------- Ca--1---------- Ca--1--------s-
    Ca--2---------- Ca--2---------1 Ca--3---------- Ca--4----------
    Ca--4--------s- Ca--5---------- Ca--6---------- Ca--7----------
    Ca--X---------- CdFD7---------- CdFD7---------6 CdFP1----------
    CdFP1---------1 CdFP1---------6 CdFP2---------- CdFP2---------6
    CdFP3---------- CdFP3---------6 CdFP4---------- CdFP4---------1
    CdFP4---------6 CdFP5---------- CdFP5---------1 CdFP5---------6
    CdFP6---------- CdFP6---------6 CdFP7---------- CdFP7---------6
    CdFP7---------7 CdFS1---------- CdFS2---------- CdFS2---------6
    CdFS3---------- CdFS3---------6 CdFS4---------- CdFS4---------2
    CdFS5---------- CdFS6---------- CdFS6---------6 CdFS7----------
    CdIP1---------- CdIP1---------1 CdIP1---------6 CdIP2----------
    CdIP2---------6 CdIP3---------- CdIP3---------6 CdIP4----------
    CdIP4---------1 CdIP4---------6 CdIP5---------- CdIP5---------1
    CdIP5---------6 CdIP6---------- CdIP6---------6 CdIP7----------
    CdIP7---------6 CdIP7---------7 CdIS1---------- CdIS1---------6
    CdIS2---------- CdIS2---------6 CdIS3---------- CdIS3---------6
    CdIS4---------- CdIS4---------6 CdIS5---------- CdIS5---------6
    CdIS6---------- CdIS6---------6 CdIS7---------- CdIS7---------6
    CdMP1---------- CdMP1---------1 CdMP1---------6 CdMP2----------
    CdMP2---------6 CdMP3---------- CdMP3---------6 CdMP4----------
    CdMP4---------1 CdMP4---------6 CdMP5---------- CdMP5---------1
    CdMP5---------6 CdMP6---------- CdMP6---------6 CdMP7----------
    CdMP7---------6 CdMP7---------7 CdMS1---------- CdMS1---------6
    CdMS2---------- CdMS2---------6 CdMS3---------- CdMS3---------6
    CdMS4---------- CdMS4---------6 CdMS5---------- CdMS5---------6
    CdMS6---------- CdMS6---------6 CdMS7---------- CdMS7---------6
    CdNP1---------- CdNP1---------1 CdNP1---------6 CdNP2----------
    CdNP2---------6 CdNP3---------- CdNP3---------6 CdNP4----------
    CdNP4---------1 CdNP4---------6 CdNP5---------- CdNP5---------1
    CdNP5---------6 CdNP6---------- CdNP6---------6 CdNP7----------
    CdNP7---------6 CdNP7---------7 CdNS1---------- CdNS1---------1
    CdNS1---------6 CdNS2---------- CdNS2---------6 CdNS3----------
    CdNS3---------6 CdNS4---------- CdNS4---------1 CdNS4---------6
    CdNS5---------- CdNS5---------6 CdNS6---------- CdNS6---------6
    CdNS7---------- CdNS7---------6 CdXP1---------- CdXP1---------1
    CdXP2---------- CdXP3---------- CdXP4---------- CdXP4---------1
    CdXP5---------- CdXP5---------1 CdXP6---------- CdXP7----------
    CdXS1---------- CdXS5---------- CdYP4---------- CdYS2----------
    CdYS3---------- CdYS6---------- CdYS7---------- ChFD7----------
    ChFD7---------6 ChFP1---------- ChFP1---------1 ChFP1---------6
    ChFP2---------- ChFP2---------6 ChFP3---------- ChFP3---------6
    ChFP4---------- ChFP4---------1 ChFP4---------6 ChFP5----------
    ChFP5---------1 ChFP5---------6 ChFP6---------- ChFP6---------6
    ChFP7---------- ChFP7---------6 ChFP7---------7 ChFS1----------
    ChFS2---------- ChFS2---------6 ChFS3---------- ChFS3---------6
    ChFS4---------- ChFS5---------- ChFS6---------- ChFS6---------6
    ChFS7---------- ChIP1---------- ChIP1---------1 ChIP1---------6
    ChIP2---------- ChIP2---------6 ChIP3---------- ChIP3---------6
    ChIP4---------- ChIP4---------1 ChIP4---------6 ChIP5----------
    ChIP5---------1 ChIP5---------6 ChIP6---------- ChIP6---------6
    ChIP7---------- ChIP7---------6 ChIP7---------7 ChIS1----------
    ChIS1---------6 ChIS2---------- ChIS2---------6 ChIS3----------
    ChIS3---------6 ChIS4---------- ChIS4---------6 ChIS5----------
    ChIS5---------6 ChIS6---------- ChIS6---------6 ChIS7----------
    ChIS7---------6 ChMP1---------- ChMP1---------1 ChMP1---------6
    ChMP2---------- ChMP2---------6 ChMP3---------- ChMP3---------6
    ChMP4---------- ChMP4---------1 ChMP4---------6 ChMP5----------
    ChMP5---------1 ChMP5---------6 ChMP6---------- ChMP6---------6
    ChMP7---------- ChMP7---------6 ChMP7---------7 ChMS1----------
    ChMS1---------6 ChMS2---------- ChMS2---------6 ChMS3----------
    ChMS3---------6 ChMS4---------- ChMS4---------6 ChMS5----------
    ChMS5---------6 ChMS6---------- ChMS6---------6 ChMS7----------
    ChMS7---------6 ChNP1---------- ChNP1---------1 ChNP1---------6
    ChNP2---------- ChNP2---------6 ChNP3---------- ChNP3---------6
    ChNP4---------- ChNP4---------1 ChNP4---------6 ChNP5----------
    ChNP5---------1 ChNP5---------6 ChNP6---------- ChNP6---------6
    ChNP7---------- ChNP7---------6 ChNP7---------7 ChNS1----------
    ChNS1---------6 ChNS2---------- ChNS2---------6 ChNS3----------
    ChNS3---------6 ChNS4---------- ChNS4---------6 ChNS5----------
    ChNS5---------6 ChNS6---------- ChNS6---------6 ChNS7----------
    ChNS7---------6 ChXP2---------- ChXP3---------- ChXP6----------
    ChXP7---------- ChYP4---------- CjNP1---------- CjNP2----------
    CjNP3---------- CjNP4---------- CjNP5---------- CjNP6----------
    CjNP7---------- CjNS1---------- CjNS1---------1 CjNS2----------
    CjNS3---------- CjNS4---------- CjNS4---------1 CjNS5----------
    CjNS6---------- CjNS7---------- CjNXX---------- CkNP1----------
    CkNP2---------- CkNP3---------- CkNP4---------- CkNP5----------
    CkNP6---------- CkNP7---------- CkNS1---------- CkNS2----------
    CkNS3---------- CkNS4---------- CkNS5---------- CkNS6----------
    CkNS7---------- CkNXX---------- Cl-D7---------- ClFD7----------
    Cl-P1---------- Cl-P2---------- Cl-P2---------1 Cl-P2---------2
    Cl-P3---------- Cl-P3---------1 Cl-P3---------2 Cl-P4----------
    Cl-P5---------- Cl-P6---------- Cl-P6---------1 Cl-P6---------2
    Cl-P7---------- Cl-P7---------1 Cl-P7---------2 Cl-P7---------6
    Cl-S1---------- Cl-S1---------1 Cl-S1---------2 Cl-S1---------6
    Cl-S4---------- Cl-S4---------1 Cl-S4---------2 Cl-S4---------6
    Cl-S5---------- Cl-S5---------1 Cl-S5---------2 Cl-S5---------6
    ClXP6---------- Cl-XX---------- ClXXX---------- CnFD7----------
    CnFD7---------6 CnFD7---------8 CnFS1---------- CnFS2----------
    CnFS2---------6 CnFS3---------- CnFS3---------6 CnFS4----------
    CnFS4---------1 CnFS5---------- CnFS6---------- CnFS6---------6
    CnFS7---------- CnFXX---------- CnHP1---------- CnHP4----------
    CnHP5---------- CnIS4---------- CnMS4---------- CnMS4---------6
    CnNS1---------- CnNS4---------- CnNS5---------- CnNXX----------
    CnXP2---------- CnXP2---------6 CnXP3---------- CnXP3---------6
    CnXP6---------- CnXP6---------6 CnXP7---------- CnXP7---------6
    CnXP7---------8 CnXXX---------- CnYP1---------- CnYP4----------
    CnYP5---------- CnYS1---------- CnYS5---------- CnZS2----------
    CnZS2---------6 CnZS3---------- CnZS6---------- CnZS7----------
    CnZS7---------6 Co------------- Co------------1 CrFD7----------
    CrFD7---------6 CrFP1---------- CrFP1---------6 CrFP1---------7
    CrFP2---------- CrFP2---------6 CrFP3---------- CrFP3---------6
    CrFP3---------7 CrFP4---------- CrFP4---------6 CrFP4---------7
    CrFP5---------- CrFP5---------6 CrFP5---------7 CrFP6----------
    CrFP6---------6 CrFP7---------- CrFP7---------6 CrFP7---------7
    CrFS1---------- CrFS1---------7 CrFS2---------- CrFS2---------6
    CrFS2---------7 CrFS3---------- CrFS3---------6 CrFS3---------7
    CrFS4---------- CrFS4---------7 CrFS5---------- CrFS5---------7
    CrFS6---------- CrFS6---------6 CrFS6---------7 CrFS7----------
    CrFS7---------7 CrIP1---------- CrIP1---------6 CrIP1---------7
    CrIP2---------- CrIP2---------6 CrIP3---------- CrIP3---------6
    CrIP3---------7 CrIP4---------- CrIP4---------6 CrIP4---------7
    CrIP5---------- CrIP5---------6 CrIP5---------7 CrIP6----------
    CrIP6---------6 CrIP7---------- CrIP7---------6 CrIP7---------7
    CrIS1---------- CrIS1---------6 CrIS1---------7 CrIS2----------
    CrIS2---------6 CrIS3---------- CrIS3---------6 CrIS4----------
    CrIS4---------6 CrIS4---------7 CrIS5---------- CrIS5---------6
    CrIS5---------7 CrIS6---------- CrIS6---------6 CrIS6---------7
    CrIS7---------- CrIS7---------6 CrIS7---------7 CrMP1----------
    CrMP1---------6 CrMP1---------7 CrMP2---------- CrMP2---------6
    CrMP3---------- CrMP3---------6 CrMP3---------7 CrMP4----------
    CrMP4---------6 CrMP4---------7 CrMP5---------- CrMP5---------6
    CrMP5---------7 CrMP6---------- CrMP6---------6 CrMP7----------
    CrMP7---------6 CrMP7---------7 CrMS1---------- CrMS1---------6
    CrMS1---------7 CrMS2---------- CrMS2---------6 CrMS3----------
    CrMS3---------6 CrMS4---------- CrMS4---------6 CrMS5----------
    CrMS5---------6 CrMS5---------7 CrMS6---------- CrMS6---------6
    CrMS6---------7 CrMS7---------- CrMS7---------6 CrMS7---------7
    CrNP1---------- CrNP1---------6 CrNP1---------7 CrNP2----------
    CrNP2---------6 CrNP3---------- CrNP3---------6 CrNP3---------7
    CrNP4---------- CrNP4---------6 CrNP4---------7 CrNP5----------
    CrNP5---------6 CrNP5---------7 CrNP6---------- CrNP6---------6
    CrNP7---------- CrNP7---------6 CrNP7---------7 CrNS1----------
    CrNS1---------6 CrNS1---------7 CrNS2---------- CrNS2---------6
    CrNS3---------- CrNS3---------6 CrNS4---------- CrNS4---------6
    CrNS4---------7 CrNS5---------- CrNS5---------6 CrNS5---------7
    CrNS6---------- CrNS6---------6 CrNS6---------7 CrNS7----------
    CrNS7---------6 CrNS7---------7 Cu------------- Cv-------------
    Cv------------1 Cv------------7 CwFD7---------- CwFP1----------
    CwFP4---------- CwFP5---------- CwFS1---------- CwFS2----------
    CwFS3---------- CwFS4---------- CwFS5---------- CwFS6----------
    CwFS7---------- CwIP1---------- CwIP5---------- CwIS4----------
    CwMP1---------- CwMP5---------- CwMS4---------- CwMS4---------6
    CwNP1---------- CwNP1---------6 CwNP4---------- CwNP4---------6
    CwNP5---------- CwNP5---------6 CwNS1---------- CwNS4----------
    CwNS5---------- CwXP2---------- CwXP3---------- CwXP6----------
    CwXP7---------- CwYP4---------- CwYS1---------- CwYS5----------
    CwZS2---------- CwZS2---------6 CwZS3---------- CwZS6----------
    CwZS6---------7 CwZS7---------- CyFS1---------- CyFS2----------
    CyFS3---------- CyFS4---------- CyFS5---------- CyFS6----------
    CyFS7---------- CyIS4---------- CyMS4---------- CyNS1----------
    CyNS4---------- CyNS5---------- CyYS1---------- CyYS5----------
    CyZS2---------- CyZS3---------- CyZS6---------- CyZS7----------
    CzFP1---------- CzFP1---------1 CzFP2---------- CzFP3----------
    CzFP4---------- CzFP4---------1 CzFP5---------- CzFP5---------1
    CzFP6---------- CzFP7---------- CzFP7---------6 CzFP7---------6
    CzFS1---------- CzFS2---------- CzFS3---------- CzFS4----------
    CzFS5---------- CzFS6---------- CzFS7---------- CzFXX----------
    CzFXX---------b CzIP1---------- CzIP1---------1 CzIP2----------
    CzIP2---------1 CzIP3---------- CzIP3---------6 CzIP3---------1
    CzIP4---------- CzIP4---------1 CzIP5---------- CzIP5---------1
    CzIP6---------- CzIP6---------1 CzIP7---------- CzIP7---------6
    CzIP7---------1 CzIS1---------- CzIS2---------- CzIS2---------1
    CzIS3---------- CzIS3---------1 CzIS4---------- CzIS5----------
    CzIS5---------1 CzIS6---------- CzIS6---------1 CzIS7----------
    CzIS7---------1 CzIXX---------- CzIXX---------b CzNP1----------
    CzNP2---------- CzNP3---------- CzNP4---------- CzNP5----------
    CzNP6---------- CzNP7---------- CzNS1---------- CzNS2----------
    CzNS3---------- CzNS4---------- CzNS5---------- CzNS6----------
    CzNS7---------- CzNXX---------- CzNXX---------1 CzNXX---------2
    Db------------- Db------------1 Db------------2 Db------------3
    Db------------4 Db------------6 Db------------7 Db------------8
    Db------------a Db------------b Db-----------s- Dg-------1A----
    Dg-------1A---1 Dg-------1A---4 Dg-------1A---6 Dg-------1A---7
    Dg-------1A---b Dg-------1N---- Dg-------1N---1 Dg-------1N---6
    Dg-------2A---- Dg-------2A---1 Dg-------2A---2 Dg-------2A---3
    Dg-------2A---4 Dg-------2A---6 Dg-------2A---7 Dg-------2N----
    Dg-------2N---1 Dg-------2N---2 Dg-------2N---3 Dg-------2N---6
    Dg-------3A---- Dg-------3A---1 Dg-------3A---2 Dg-------3A---3
    Dg-------3A---6 Dg-------3A---7 Dg-------3N---- Dg-------3N---1
    Dg-------3N---2 Dg-------3N---3 Dg-------3N---6 F%-------------
    II------------- II------------1 II------------6 J^-------------
    J,------------- J*------------- J*------------1 J^------------2
    J,------------6 J,------------7 J,------------8 J,-----------c-
    J,-----------c6 J,-----------e- J,-----------m- J,-----------m6
    J^-----------s- J,-----------s- J,-----------s6 J,-----------s7
    NNFD7-----A---- NNFP1-----A---- NNFP1-----A---1 NNFP1-----A---2
    NNFP1-----A---3 NNFP1-----A---4 NNFP1-----A---6 NNFP1-----A---b
    NNFP1-----N---- NNFP1-----N---1 NNFP1-----N---6 NNFP2-----A----
    NNFP2-----A---1 NNFP2-----A---2 NNFP2-----A---6 NNFP2-----A---7
    NNFP2-----N---- NNFP2-----N---1 NNFP2-----N---6 NNFP3-----A----
    NNFP3-----A---1 NNFP3-----A---2 NNFP3-----A---6 NNFP3-----N----
    NNFP3-----N---1 NNFP3-----N---6 NNFP4-----A---- NNFP4-----A---1
    NNFP4-----A---2 NNFP4-----A---3 NNFP4-----A---4 NNFP4-----A---6
    NNFP4-----A---b NNFP4-----N---- NNFP4-----N---1 NNFP4-----N---6
    NNFP5-----A---- NNFP5-----A---1 NNFP5-----A---2 NNFP5-----A---3
    NNFP5-----A---4 NNFP5-----A---6 NNFP5-----A---b NNFP5-----N----
    NNFP5-----N---1 NNFP5-----N---6 NNFP6-----A---- NNFP6-----A---1
    NNFP6-----A---2 NNFP6-----A---6 NNFP6-----A---7 NNFP6-----N----
    NNFP6-----N---1 NNFP6-----N---6 NNFP7-----A---- NNFP7-----A---1
    NNFP7-----A---2 NNFP7-----A---3 NNFP7-----A---5 NNFP7-----A---6
    NNFP7-----A---7 NNFP7-----N---- NNFP7-----N---1 NNFP7-----N---6
    NNFP7-----N---7 NNFS1-----A---- NNFS1-----A---1 NNFS1-----A---2
    NNFS1-----A---5 NNFS1-----A---6 NNFS1-----A---b NNFS1-----N----
    NNFS2-----A---- NNFS2-----A---1 NNFS2-----A---2 NNFS2-----A---3
    NNFS2-----A---6 NNFS2-----A---b NNFS2-----N---- NNFS2-----N---1
    NNFS2-----N---6 NNFS3-----A---- NNFS3-----A---1 NNFS3-----A---2
    NNFS3-----A---3 NNFS3-----A---4 NNFS3-----A---6 NNFS3-----N----
    NNFS3-----N---1 NNFS3-----N---2 NNFS3-----N---6 NNFS4---------1
    NNFS4-----A---- NNFS4-----A---1 NNFS4-----A---2 NNFS4-----A---4
    NNFS4-----A---5 NNFS4-----A---6 NNFS4-----N---- NNFS4-----N---1
    NNFS5-----A---- NNFS5-----A---1 NNFS5-----A---2 NNFS5-----A---6
    NNFS5-----N---- NNFS6-----A---- NNFS6-----A---1 NNFS6-----A---2
    NNFS6-----A---6 NNFS6-----N---- NNFS6-----N---1 NNFS6-----N---6
    NNFS7-----A---- NNFS7-----A---1 NNFS7-----A---2 NNFS7-----A---3
    NNFS7-----A---6 NNFS7-----A---a NNFS7-----A---b NNFS7-----N----
    NNFS7-----N---1 NNFXX-----A---- NNFXX-----A---1 NNFXX-----A---2
    NNFXX-----A---6 NNFXX-----A---a NNFXX-----A---b NNFXX-----A---c
    NNIP1-----A---- NNIP1-----A---1 NNIP1-----A---2 NNIP1-----A---3
    NNIP1-----A---6 NNIP1-----A---7 NNIP1-----A---8 NNIP1-----A---b
    NNIP1-----N---- NNIP1-----N---1 NNIP1-----N---6 NNIP2-----A----
    NNIP2-----A---1 NNIP2-----A---2 NNIP2-----A---3 NNIP2-----A---6
    NNIP2-----A---b NNIP2-----N---- NNIP2-----N---1 NNIP2-----N---6
    NNIP3-----A---- NNIP3-----A---1 NNIP3-----A---2 NNIP3-----A---6
    NNIP3-----A---7 NNIP3-----A---8 NNIP3-----A---b NNIP3-----N----
    NNIP3-----N---1 NNIP3-----N---6 NNIP3-----N---7 NNIP3-----N---8
    NNIP4-----A---- NNIP4-----A---1 NNIP4-----A---2 NNIP4-----A---3
    NNIP4-----A---6 NNIP4-----A---8 NNIP4-----A---b NNIP4-----N----
    NNIP4-----N---1 NNIP4-----N---6 NNIP5-----A---- NNIP5-----A---1
    NNIP5-----A---2 NNIP5-----A---3 NNIP5-----A---6 NNIP5-----A---7
    NNIP5-----A---8 NNIP5-----N---- NNIP5-----N---1 NNIP5-----N---6
    NNIP6-----A---- NNIP6-----A---1 NNIP6-----A---2 NNIP6-----A---3
    NNIP6-----A---4 NNIP6-----A---6 NNIP6-----A---7 NNIP6-----A---b
    NNIP6-----N---- NNIP6-----N---1 NNIP6-----N---6 NNIP7-----A----
    NNIP7-----A---1 NNIP7-----A---2 NNIP7-----A---6 NNIP7-----A---7
    NNIP7-----A---8 NNIP7-----A---b NNIP7-----N---- NNIP7-----N---1
    NNIP7-----N---6 NNIP7-----N---7 NNIS1-----A---- NNIS1-----A---1
    NNIS1-----A---2 NNIS1-----A---6 NNIS1-----N---- NNIS1-----N---1
    NNIS1-----N---2 NNIS2-----A---- NNIS2-----A---1 NNIS2-----A---2
    NNIS2-----A---3 NNIS2-----A---4 NNIS2-----A---6 NNIS2-----A---7
    NNIS2-----A---b NNIS2-----N---- NNIS2-----N---1 NNIS2-----N---6
    NNIS3-----A---- NNIS3-----A---1 NNIS3-----A---2 NNIS3-----A---6
    NNIS3-----A---7 NNIS3-----A---b NNIS3-----N---- NNIS3-----N---1
    NNIS3-----N---6 NNIS4-----A---- NNIS4-----A---1 NNIS4-----A---2
    NNIS4-----A---4 NNIS4-----A---6 NNIS4-----A---7 NNIS4-----N----
    NNIS4-----N---1 NNIS4-----N---2 NNIS5-----A---- NNIS5-----A---1
    NNIS5-----A---2 NNIS5-----A---5 NNIS5-----A---6 NNIS5-----N----
    NNIS5-----N---1 NNIS5-----N---6 NNIS6-----A---- NNIS6-----A---1
    NNIS6-----A---2 NNIS6-----A---4 NNIS6-----A---5 NNIS6-----A---6
    NNIS6-----A---7 NNIS6-----A---9 NNIS6-----A---b NNIS6-----N----
    NNIS6-----N---1 NNIS6-----N---6 NNIS7-----A---- NNIS7-----A---1
    NNIS7-----A---2 NNIS7-----A---6 NNIS7-----A---b NNIS7-----N----
    NNIS7-----N---1 NNIS7-----N---6 NNIXX-----A---- NNIXX-----A---1
    NNIXX-----A---a NNIXX-----A---b NNIXX-----N---- NNMP1-----A----
    NNMP1-----A---1 NNMP1-----A---2 NNMP1-----A---3 NNMP1-----A---5
    NNMP1-----A---6 NNMP1-----A---7 NNMP1-----A---b NNMP1-----N----
    NNMP1-----N---1 NNMP1-----N---2 NNMP1-----N---3 NNMP1-----N---6
    NNMP2-----A---- NNMP2-----A---1 NNMP2-----A---2 NNMP2-----A---6
    NNMP2-----A---b NNMP2-----N---- NNMP2-----N---2 NNMP2-----N---6
    NNMP3-----A---- NNMP3-----A---1 NNMP3-----A---2 NNMP3-----A---3
    NNMP3-----A---6 NNMP3-----A---7 NNMP3-----A---8 NNMP3-----N----
    NNMP3-----N---2 NNMP3-----N---6 NNMP3-----N---7 NNMP4-----A----
    NNMP4-----A---1 NNMP4-----A---2 NNMP4-----A---6 NNMP4-----A---7
    NNMP4-----A---b NNMP4-----N---- NNMP4-----N---1 NNMP4-----N---2
    NNMP4-----N---6 NNMP5-----A---- NNMP5-----A---1 NNMP5-----A---2
    NNMP5-----A---3 NNMP5-----A---5 NNMP5-----A---6 NNMP5-----A---7
    NNMP5-----N---- NNMP5-----N---1 NNMP5-----N---2 NNMP5-----N---3
    NNMP5-----N---6 NNMP6-----A---- NNMP6-----A---1 NNMP6-----A---2
    NNMP6-----A---6 NNMP6-----A---7 NNMP6-----N---- NNMP6-----N---1
    NNMP6-----N---2 NNMP6-----N---6 NNMP7-----A---- NNMP7-----A---1
    NNMP7-----A---2 NNMP7-----A---5 NNMP7-----A---6 NNMP7-----A---7
    NNMP7-----A---8 NNMP7-----N---- NNMP7-----N---1 NNMP7-----N---2
    NNMP7-----N---6 NNMP7-----N---7 NNMS1-----A---- NNMS1-----A---1
    NNMS1-----A---2 NNMS1-----A---3 NNMS1-----A---4 NNMS1-----A---5
    NNMS1-----A---6 NNMS1-----A---7 NNMS1-----A---8 NNMS1-----N----
    NNMS1-----N---1 NNMS1-----N---6 NNMS2-----A---- NNMS2-----A---1
    NNMS2-----A---2 NNMS2-----A---3 NNMS2-----A---6 NNMS2-----A---7
    NNMS2-----A---b NNMS2-----N---- NNMS2-----N---1 NNMS2-----N---2
    NNMS2-----N---6 NNMS3-----A---- NNMS3-----A---1 NNMS3-----A---2
    NNMS3-----A---3 NNMS3-----A---4 NNMS3-----A---6 NNMS3-----A---7
    NNMS3-----A---8 NNMS3-----A---b NNMS3-----N---- NNMS3-----N---1
    NNMS3-----N---2 NNMS3-----N---3 NNMS3-----N---6 NNMS4-----A----
    NNMS4-----A---1 NNMS4-----A---2 NNMS4-----A---4 NNMS4-----A---6
    NNMS4-----A---7 NNMS4-----A---b NNMS4-----N---- NNMS4-----N---1
    NNMS4-----N---2 NNMS4-----N---6 NNMS5-----A---- NNMS5-----A---1
    NNMS5-----A---2 NNMS5-----A---3 NNMS5-----A---4 NNMS5-----A---5
    NNMS5-----A---6 NNMS5-----A---7 NNMS5-----N---- NNMS5-----N---1
    NNMS5-----N---6 NNMS6-----A---- NNMS6-----A---1 NNMS6-----A---2
    NNMS6-----A---3 NNMS6-----A---4 NNMS6-----A---6 NNMS6-----A---7
    NNMS6-----A---8 NNMS6-----A---b NNMS6-----N---- NNMS6-----N---1
    NNMS6-----N---2 NNMS6-----N---3 NNMS6-----N---6 NNMS6-----N---7
    NNMS7-----A---- NNMS7-----A---1 NNMS7-----A---2 NNMS7-----A---6
    NNMS7-----A---7 NNMS7-----A---b NNMS7-----N---- NNMS7-----N---1
    NNMS7-----N---2 NNMS7-----N---6 NNMXX-----A---- NNMXX-----A---1
    NNMXX-----A---a NNMXX-----A---b NNMXX-----N---- NNND7-----A----
    NNNP1-----A---- NNNP1-----A---1 NNNP1-----A---2 NNNP1-----A---3
    NNNP1-----A---6 NNNP1-----N---- NNNP1-----N---1 NNNP1-----N---6
    NNNP2-----A---- NNNP2-----A---1 NNNP2-----A---2 NNNP2-----A---3
    NNNP2-----A---6 NNNP2-----N---- NNNP2-----N---1 NNNP2-----N---6
    NNNP3-----A---- NNNP3-----A---1 NNNP3-----A---2 NNNP3-----A---3
    NNNP3-----A---6 NNNP3-----A---7 NNNP3-----N---- NNNP3-----N---1
    NNNP3-----N---6 NNNP4-----A---- NNNP4-----A---1 NNNP4-----A---2
    NNNP4-----A---3 NNNP4-----A---6 NNNP4-----N---- NNNP4-----N---1
    NNNP4-----N---6 NNNP5-----A---- NNNP5-----A---1 NNNP5-----A---2
    NNNP5-----A---3 NNNP5-----A---6 NNNP5-----N---- NNNP5-----N---1
    NNNP5-----N---6 NNNP6-----A---- NNNP6-----A---1 NNNP6-----A---2
    NNNP6-----A---3 NNNP6-----A---6 NNNP6-----N---- NNNP6-----N---1
    NNNP6-----N---6 NNNP7-----A---- NNNP7-----A---1 NNNP7-----A---2
    NNNP7-----A---3 NNNP7-----A---6 NNNP7-----A---7 NNNP7-----N----
    NNNP7-----N---1 NNNP7-----N---6 NNNP7-----N---7 NNNS1-----A----
    NNNS1-----A---1 NNNS1-----A---2 NNNS1-----A---6 NNNS1-----N----
    NNNS1-----N---1 NNNS1-----N---6 NNNS2-----A---- NNNS2-----A---1
    NNNS2-----A---2 NNNS2-----A---3 NNNS2-----A---5 NNNS2-----A---6
    NNNS2-----N---- NNNS2-----N---1 NNNS2-----N---6 NNNS3-----A----
    NNNS3-----A---1 NNNS3-----A---2 NNNS3-----A---3 NNNS3-----A---6
    NNNS3-----N---- NNNS3-----N---1 NNNS3-----N---6 NNNS4-----A----
    NNNS4-----A---1 NNNS4-----A---2 NNNS4-----A---6 NNNS4-----N----
    NNNS4-----N---1 NNNS4-----N---6 NNNS5-----A---- NNNS5-----A---1
    NNNS5-----A---2 NNNS5-----A---6 NNNS5-----N---- NNNS5-----N---1
    NNNS5-----N---6 NNNS6-----A---- NNNS6-----A---1 NNNS6-----A---2
    NNNS6-----A---3 NNNS6-----A---4 NNNS6-----A---6 NNNS6-----A---7
    NNNS6-----N---- NNNS6-----N---1 NNNS6-----N---6 NNNS6-----N---7
    NNNS7-----A---- NNNS7-----A---1 NNNS7-----A---2 NNNS7-----A---6
    NNNS7-----A---b NNNS7-----N---- NNNS7-----N---1 NNNS7-----N---6
    NNNXX-----A---- NNNXX-----A---1 NNNXX-----A---6 NNNXX-----A---a
    NNNXX-----A---b NNXS1-----A---- NNXXX-----A---- NNXXX-----A---1
    NNXXX-----A---6 NNXXX-----A---b P1FD7FS3------- P1FSXFS3-------
    P1IS4FS3------- P1MS4FS3------- P1NS4FS3------- P1XP1FS3-------
    P1XP2FS3------- P1XP3FS3------- P1XP4FS3------- P1XP6FS3-------
    P1XP7FS3------- P1XXXXP3------- P1XXXZS3------- P1ZS1FS3-------
    P1ZS2FS3------- P1ZS2FS3------2 P1ZS3FS3------- P1ZS6FS3-------
    P1ZS7FS3------- P4FD7---------- P4FD7---------2 P4FD7---------6
    P4FP1---------- P4FP1---------2 P4FP1---------6 P4FP1--------s-
    P4FP1--------s6 P4FP4---------- P4FP4---------2 P4FP4---------6
    P4FP4--------s- P4FP4--------s6 P4FS1---------- P4FS1---------2
    P4FS1--------s- P4FS2---------- P4FS2---------2 P4FS2---------6
    P4FS3---------- P4FS3---------2 P4FS3---------6 P4FS3--------s-
    P4FS4---------- P4FS4---------2 P4FS6---------- P4FS6---------2
    P4FS6---------6 P4FS7---------- P4FS7---------2 P4IP1----------
    P4IP1---------2 P4IP1---------6 P4IP1--------s- P4IS4----------
    P4IS4---------2 P4IS4---------6 P4IS4---------7 P4IS4---------8
    P4MP1---------- P4MP1---------2 P4MP1---------6 P4MS1--------s-
    P4MS4---------- P4MS4---------2 P4MS4---------6 P4MS4---------7
    P4MS4--------s- P4NP1---------- P4NP1---------2 P4NP1---------6
    P4NP1---------7 P4NP4---------- P4NP4---------2 P4NP4---------6
    P4NP4---------7 P4NS1---------- P4NS1---------2 P4NS1---------6
    P4NS1---------8 P4NS4---------- P4NS4---------2 P4NS4---------6
    P4NS4---------8 P4XD7---------- P4XP1---------6 P4XP2----------
    P4XP2---------2 P4XP2---------6 P4XP2--------s- P4XP3----------
    P4XP3---------2 P4XP3---------6 P4XP3---------7 P4XP3---------8
    P4XP3---------9 P4XP3--------s- P4XP4---------6 P4XP6----------
    P4XP6---------2 P4XP6---------6 P4XP6--------s- P4XP7----------
    P4XP7---------2 P4XP7---------6 P4XP7---------7 P4XP7--------s-
    P4XXX---------- P4YP4---------- P4YP4---------2 P4YP4---------6
    P4YP4--------s- P4YP4--------s6 P4YS1---------- P4YS1---------2
    P4YS1---------6 P4YS1---------7 P4YS1---------8 P4YS2----------
    P4YS3---------- P4YS5---------- P4ZS2---------- P4ZS2---------2
    P4ZS2---------6 P4ZS2---------7 P4ZS3---------- P4ZS3---------2
    P4ZS3---------6 P4ZS3---------7 P4ZS3--------s- P4ZS6----------
    P4ZS6---------2 P4ZS6---------6 P4ZS6---------7 P4ZS6---------8
    P4ZS6--------s- P4ZS7---------- P4ZS7---------2 P4ZS7---------6
    P4ZS7---------7 P4ZS7---------8 P4ZS7---------9 P4ZS7--------s-
    P5ZS2--3------- P5ZS3--3------- P5ZS4--3------- P6--2----------
    P6--3---------- P6--4---------- P6--6---------- P6--7----------
    P7--3---------- P7--3--------s- P7--4---------- P7--4--------s-
    P8FD7---------- P8FD7---------6 P8FP1---------1 P8FP4---------1
    P8FS1---------1 P8FS2---------- P8FS2---------1 P8FS2---------6
    P8FS3---------- P8FS3---------1 P8FS3---------6 P8FS4----------
    P8FS4---------1 P8FS4---------6 P8FS5---------1 P8FS6----------
    P8FS6---------1 P8FS6---------6 P8FS7---------- P8FS7---------1
    P8HP1---------- P8HP5---------- P8HP5---------7 P8HS1----------
    P8HS5---------- P8IP1---------- P8IP1---------1 P8IP1---------7
    P8IP5---------- P8IP5---------1 P8IP5---------7 P8IS4----------
    P8IS4---------6 P8MP1---------- P8MP1---------1 P8MP5----------
    P8MP5---------1 P8MS4---------- P8MS4---------6 P8NP1---------1
    P8NP4---------1 P8NP5---------1 P8NS1---------1 P8NS4----------
    P8NS4---------1 P8NS4---------6 P8NS5---------1 P8XP2----------
    P8XP2---------6 P8XP3---------- P8XP3---------6 P8XP4----------
    P8XP4---------7 P8XP6---------- P8XP6---------6 P8XP7----------
    P8YP4---------1 P8YS1---------- P8YS1---------6 P8YS5----------
    P8YS5---------6 P8ZS2---------- P8ZS2---------6 P8ZS3----------
    P8ZS3---------6 P8ZS6---------- P8ZS6---------6 P8ZS6---------7
    P8ZS7---------- P8ZS7---------6 P9FD7FS3------- P9FSXFS3-------
    P9IS4FS3------- P9MS4FS3------- P9NS4FS3------- P9XP1FS3-------
    P9XP2FS3------- P9XP3FS3------- P9XP3FS3------6 P9XP4FS3-------
    P9XP5FS3------- P9XP6FS3------- P9XP7FS3------- P9XP7FS3------6
    P9XXXXP3------- P9XXXZS3------- P9ZS1FS3------- P9ZS2FS3-------
    P9ZS3FS3------- P9ZS5FS3------- P9ZS6FS3------- P9ZS6FS3------6
    P9ZS7FS3------- P9ZS7FS3------6 PDFD7---------- PDFD7---------2
    PDFD7---------6 PDFD7---------7 PDFP1---------- PDFP1---------4
    PDFP1---------5 PDFP1---------7 PDFP4---------- PDFP4---------4
    PDFP4---------5 PDFP4---------7 PDFS1---------- PDFS2----------
    PDFS2---------6 PDFS3---------- PDFS3---------6 PDFS4----------
    PDFS4---------1 PDFS4---------4 PDFS4---------5 PDFS4---------6
    PDFS6---------- PDFS6---------6 PDFS7---------- PDFS7---------1
    PDIP1---------- PDIP1---------4 PDIP1---------5 PDIP1---------7
    PDIP4---------- PDIP4---------4 PDIP4---------5 PDIP4---------7
    PDIS1---------- PDIS4---------- PDIS4---------6 PDIS4---------7
    PDMP1---------- PDMP1---------1 PDMP1---------6 PDMP4----------
    PDMP4---------4 PDMP4---------5 PDMP4---------7 PDMP7---------6
    PDMS1---------- PDMS4---------- PDMS4---------1 PDMS4---------6
    PDMS4---------7 PDMS7---------6 PDNP1---------- PDNP1---------6
    PDNP4---------- PDNP4---------6 PDNS1---------- PDNS1---------2
    PDNS1---------4 PDNS1---------5 PDNS1---------6 PDNS1---------7
    PDNS1--------s- PDNS4---------- PDNS4---------2 PDNS4---------4
    PDNS4---------5 PDNS4---------6 PDNS4---------7 PDNS4--------s-
    PDXP1---------6 PDXP2---------- PDXP2---------1 PDXP2---------2
    PDXP2---------6 PDXP2---------7 PDXP3---------- PDXP3---------1
    PDXP3---------2 PDXP3---------6 PDXP3---------7 PDXP4---------6
    PDXP6---------- PDXP6---------1 PDXP6---------2 PDXP6---------6
    PDXP6---------7 PDXP7---------- PDXP7---------2 PDXP7---------6
    PDXXX---------- PDYS1---------- PDYS1---------6 PDYS1---------7
    PDZS2---------- PDZS2---------1 PDZS2---------6 PDZS2---------7
    PDZS3---------- PDZS3---------6 PDZS6---------- PDZS6---------1
    PDZS6---------2 PDZS6---------6 PDZS6---------7 PDZS7----------
    PDZS7---------6 PDZS7---------7 PEFP1--3------- PEFP1--3------6
    PEFS1--3------- PEFS1--3------6 PEFS2--3------- PEFS3--3-------
    PEFS4--3------- PEFS4--3------1 PEFS4--3------6 PEFS4--3------7
    PEFS6--3------- PEFS7--3------- PEIP1--3------- PEIP1--3------6
    PEMP1--3------- PEMP1--3------6 PENP1--3------- PENS1--3-------
    PENS1--3------6 PENS4--3------- PENS4--3------1 PEXP2--3-------
    PEXP3--3------- PEXP3--3------1 PEXP4--3------- PEXP4--3------1
    PEXP6--3------- PEXP7--3------- PEXP7--3------1 PEXP7--3------6
    PEXP7--3------7 PEYS1--3------- PEYS1--3------6 PEYS2--3-------
    PEYS4--3------- PEZS2--3------- PEZS2--3------1 PEZS2--3-----d-
    PEZS3--3------- PEZS3--3------1 PEZS4--3------- PEZS4--3------1
    PEZS4--3------2 PEZS4--3-----n- PEZS4--3-----o- PEZS4--3-----p-
    PEZS4--3-----z- PEZS6--3------- PEZS6--3------6 PEZS7--3-------
    PEZS7--3------1 PH-S2--1------- PH-S2--2------- PH-S3--1-------
    PH-S3--2------- PH-S4--1------- PH-S4--1------5 PH-S4--1------6
    PH-S4--2------- PJFP1---------- PJFS1---------- PJFS1---------2
    PJFS1---------6 PJFS2---------- PJFS2---------2 PJFS3----------
    PJFS3---------2 PJFS4---------- PJFS6---------- PJFS6---------2
    PJFS7---------- PJFS7---------2 PJIP1---------- PJIS4---------2
    PJMP1---------- PJMS4---------- PJMS4---------2 PJNP1----------
    PJNP1---------6 PJNS1---------- PJNS1---------2 PJNS4----------
    PJNS4---------2 PJXP1---------2 PJXP2---------- PJXP2---------2
    PJXP3---------- PJXP3---------1 PJXP4---------- PJXP4---------2
    PJXP6---------- PJXP6---------2 PJXP7---------- PJXP7---------1
    PJYS1---------- PJYS1---------2 PJYS4---------6 PJZS2----------
    PJZS2---------1 PJZS2---------2 PJZS3---------- PJZS3---------1
    PJZS4---------- PJZS4---------1 PJZS4---------2 PJZS6----------
    PJZS6---------2 PJZS7---------- PK--1---------- PK--1---------6
    PK--2---------- PK--2--2------- PK--3---------- PK--4----------
    PK--4--2------- PK--4---------6 PK--5---------- PK--6----------
    PK--6---------6 PK--7---------- PK--7---------6 PLFD7----------
    PLFP1---------- PLFP1---------6 PLFP4---------- PLFP4---------6
    PLFP5---------- PLFS1---------- PLFS1---------4 PLFS2----------
    PLFS3---------- PLFS4---------- PLFS4---------1 PLFS4---------4
    PLFS4---------6 PLFS5---------- PLFS5---------4 PLFS6----------
    PLFS7---------- PLIP1---------- PLIP1---------6 PLIP5----------
    PLIS4---------- PLIS4---------1 PLIS4---------6 PLMP1----------
    PLMP1---------1 PLMP1---------4 PLMP1---------5 PLMP1---------6
    PLMP1---------7 PLMP1---------8 PLMP5---------- PLMP5---------1
    PLMP5---------4 PLMP5---------5 PLMP5---------6 PLMP5---------7
    PLMP5---------8 PLMS2---------- PLMS4---------- PLMS4---------6
    PLNP1---------- PLNP1---------4 PLNP1---------6 PLNP1---------7
    PLNP4---------- PLNP4---------4 PLNP4---------6 PLNP5----------
    PLNP5---------4 PLNP5---------6 PLNS1---------- PLNS1---------1
    PLNS1---------6 PLNS2---------6 PLNS4---------- PLNS4---------1
    PLNS4---------6 PLNS5---------- PLNS5---------1 PLXD7----------
    PLXD7---------4 PLXD7---------6 PLXP2---------- PLXP2---------4
    PLXP2---------6 PLXP3---------- PLXP3---------3 PLXP3---------4
    PLXP3---------7 PLXP6---------- PLXP6---------4 PLXP6---------6
    PLXP7---------- PLXP7---------4 PLXP7---------6 PLXP7---------7
    PLYP4---------- PLYS1---------- PLYS1---------1 PLYS1---------6
    PLYS4---------- PLYS5---------- PLYS5---------1 PLYS5---------6
    PLZS2---------- PLZS2---------3 PLZS2---------4 PLZS2---------6
    PLZS3---------- PLZS3---------4 PLZS3---------5 PLZS3---------6
    PLZS6---------- PLZS6---------3 PLZS6---------4 PLZS6---------6
    PLZS7---------- PLZS7---------6 PP-P1--1------- PP-P1--2-------
    PP-P2--1------- PP-P2--2------- PP-P3--1------- PP-P3--2-------
    PP-P3--2------6 PP-P4--1------- PP-P4--2------- PP-P5--1-------
    PP-P5--2------- PP-P6--1------- PP-P6--2------- PP-P7--1-------
    PP-P7--1------6 PP-P7--2------- PP-P7--2------6 PP-S1--1-------
    PP-S1--1------6 PP-S1--2------- PP-S1--2-----s- PP-S2--1-------
    PP-S2--2------- PP-S3--1------- PP-S3--2------- PP-S4--1-------
    PP-S4--2------- PP-S5--2------- PP-S6--1------- PP-S6--2-------
    PP-S7--1------- PP-S7--2------- PQ--1---------- PQ--1---------1
    PQ--1---------6 PQ--1--------s- PQ--2---------- PQ--2---------9
    PQ--2--------s- PQ--3---------- PQ--3---------9 PQ--3--------s-
    PQ--4---------- PQ--4---------6 PQ--4--------n- PQ--4--------N-
    PQ--4--------o- PQ--4--------O- PQ--4--------s- PQ--4--------v-
    PQ--4--------V- PQ--4--------z- PQ--4--------Z- PQ--6----------
    PQ--6---------6 PQ--6---------9 PQ--6--------s- PQ--7----------
    PQ--7---------6 PQ--7---------9 PQ--7--------s- PSFD7-P1-------
    PSFD7-P2------- PSFD7-S1------- PSFD7-S1------6 PSFD7-S2-------
    PSFD7-S2------6 PSFP1-S1------1 PSFP1-S2------1 PSFP4-S1------1
    PSFP4-S2------1 PSFS1-S1------1 PSFS1-S2------1 PSFS2-P1-------
    PSFS2-P2------- PSFS2-S1------- PSFS2-S1------1 PSFS2-S1------6
    PSFS2-S2------- PSFS2-S2------1 PSFS2-S2------6 PSFS3-P1-------
    PSFS3-P2------- PSFS3-S1------- PSFS3-S1------1 PSFS3-S1------6
    PSFS3-S2------- PSFS3-S2------1 PSFS3-S2------6 PSFS4-P1-------
    PSFS4-P1------6 PSFS4-P1------7 PSFS4-P2------- PSFS4-P2------6
    PSFS4-S1------- PSFS4-S1------1 PSFS4-S1------6 PSFS4-S2-------
    PSFS4-S2------1 PSFS4-S2------6 PSFS5-S1------1 PSFS5-S2------1
    PSFS6-P1------- PSFS6-P2------- PSFS6-S1------- PSFS6-S1------1
    PSFS6-S1------6 PSFS6-S2------- PSFS6-S2------1 PSFS6-S2------6
    PSFS7-P1------- PSFS7-P2------- PSFS7-S1------- PSFS7-S1------1
    PSFS7-S2------- PSFS7-S2------1 PSHP1-P1------- PSHP1-P2-------
    PSHP1-S1------- PSHP1-S2------- PSHP5-S1------- PSHP5-S1------7
    PSHP5-S2------- PSHP5-S2------7 PSHS1-P1------- PSHS1-P2-------
    PSHS1-S1------- PSHS1-S2------- PSHS5-P1------- PSHS5-P2-------
    PSHS5-S1------- PSHS5-S2------- PSIP1-P1------- PSIP1-P2-------
    PSIP1-S1------- PSIP1-S1------1 PSIP1-S1------7 PSIP1-S2-------
    PSIP1-S2------1 PSIP1-S2------7 PSIP5-S1------- PSIP5-S1------1
    PSIP5-S1------7 PSIP5-S2------- PSIP5-S2------1 PSIP5-S2------7
    PSIS4-P1------- PSIS4-P2------- PSIS4-S1------- PSIS4-S1------6
    PSIS4-S2------- PSIS4-S2------6 PSMP1-P1------- PSMP1-P2-------
    PSMP1-S1------- PSMP1-S1------1 PSMP1-S1------7 PSMP1-S2-------
    PSMP1-S2------1 PSMP5-P1------- PSMP5-P2------- PSMP5-S1-------
    PSMP5-S1------1 PSMP5-S1------7 PSMP5-S2------- PSMP5-S2------1
    PSMS4-P1------- PSMS4-P2------- PSMS4-S1------- PSMS4-S1------6
    PSMS4-S1------7 PSMS4-S2------- PSMS4-S2------6 PSNP1-S1------1
    PSNP1-S1------6 PSNP1-S2------1 PSNP4-S1------1 PSNP4-S2------1
    PSNP5-S1------1 PSNP5-S2------1 PSNS1-S1------1 PSNS1-S1------6
    PSNS1-S2------1 PSNS4-P1------- PSNS4-P2------- PSNS4-S1-------
    PSNS4-S1------1 PSNS4-S1------6 PSNS4-S2------- PSNS4-S2------1
    PSNS5-S1------1 PSNS5-S1------6 PSNS5-S2------1 PSXP2-P1-------
    PSXP2-P1------6 PSXP2-P2------- PSXP2-P2------6 PSXP2-S1-------
    PSXP2-S1------6 PSXP2-S2------- PSXP2-S2------6 PSXP3-P1-------
    PSXP3-P2------- PSXP3-S1------- PSXP3-S1------6 PSXP3-S1------7
    PSXP3-S2------- PSXP3-S2------6 PSXP4-P1------- PSXP4-P2-------
    PSXP4-S1------- PSXP4-S1------7 PSXP4-S2------- PSXP4-S2------7
    PSXP6-P1------- PSXP6-P1------6 PSXP6-P2------- PSXP6-P2------6
    PSXP6-S1------- PSXP6-S1------6 PSXP6-S2------- PSXP6-S2------6
    PSXP7-P1------- PSXP7-P1------6 PSXP7-P1------7 PSXP7-P2-------
    PSXP7-P2------6 PSXP7-P2------7 PSXP7-S1------- PSXP7-S2-------
    PSYP4-S1------1 PSYP4-S1------7 PSYP4-S2------1 PSYS1-P1-------
    PSYS1-P2------- PSYS1-S1------- PSYS1-S1------6 PSYS1-S2-------
    PSYS1-S2------6 PSYS5-P1------- PSYS5-P2------- PSYS5-S1-------
    PSYS5-S1------6 PSYS5-S2------- PSYS5-S2------6 PSZS2-P1-------
    PSZS2-P1------b PSZS2-P2------- PSZS2-S1------- PSZS2-S1------6
    PSZS2-S1------7 PSZS2-S2------- PSZS2-S2------6 PSZS3-P1-------
    PSZS3-P2------- PSZS3-S1------- PSZS3-S1------6 PSZS3-S2-------
    PSZS3-S2------6 PSZS6-P1------- PSZS6-P1------6 PSZS6-P2-------
    PSZS6-P2------6 PSZS6-S1------- PSZS6-S1------6 PSZS6-S1------7
    PSZS6-S2------- PSZS6-S2------6 PSZS6-S2------7 PSZS7-P1-------
    PSZS7-P1------6 PSZS7-P1------b PSZS7-P2------- PSZS7-P2------6
    PSZS7-S1------- PSZS7-S1------6 PSZS7-S1------7 PSZS7-S2-------
    PSZS7-S2------6 PWFD7---------- PWFD7---------6 PWFP1----------
    PWFP1---------6 PWFP4---------- PWFP4---------6 PWFP5----------
    PWFP5---------6 PWFS1---------- PWFS2---------- PWFS2---------6
    PWFS3---------- PWFS3---------6 PWFS4---------- PWFS5----------
    PWFS6---------- PWFS6---------6 PWFS7---------- PWIP1----------
    PWIP1---------6 PWIP5---------- PWIP5---------6 PWIS4----------
    PWIS4---------6 PWMP1---------- PWMP1---------6 PWMP5----------
    PWMP5---------6 PWMS4---------- PWMS4---------6 PWNP1----------
    PWNP1---------6 PWNP1---------7 PWNP4---------- PWNP4---------6
    PWNP4---------7 PWNP5---------- PWNP5---------6 PWNP5---------7
    PWNS1---------- PWNS1---------6 PWNS4---------- PWNS4---------6
    PWNS5---------- PWNS5---------6 PWXP2---------- PWXP2---------6
    PWXP3---------- PWXP3---------6 PWXP6---------- PWXP6---------6
    PWXP7---------- PWXP7---------6 PWXP7---------7 PWYP4----------
    PWYP4---------6 PWYS1---------- PWYS1---------6 PWYS5----------
    PWYS5---------6 PWZS2---------- PWZS2---------6 PWZS3----------
    PWZS3---------6 PWZS6---------- PWZS6---------6 PWZS6---------7
    PWZS7---------- PWZS7---------6 PY--1---------- PY--2----------
    PY--2---------2 PY--3---------- PY--3---------2 PY--4----------
    PY--6---------- PY--6---------2 PY--6---------6 PY--7----------
    PY--7---------2 PY--7---------6 PZFD7---------- PZFD7---------6
    PZFP1---------- PZFP1---------6 PZFP1---------7 PZFP4----------
    PZFP4---------6 PZFP4---------7 PZFP5---------- PZFP5---------6
    PZFP5---------7 PZFS1---------- PZFS2---------- PZFS2---------6
    PZFS2---------7 PZFS3---------- PZFS3---------6 PZFS3---------7
    PZFS4---------- PZFS4---------1 PZFS5---------- PZFS6----------
    PZFS6---------6 PZFS6---------7 PZFS7---------- PZFS7---------1
    PZIP1---------- PZIP1---------1 PZIP1---------6 PZIP1---------7
    PZIP5---------- PZIP5---------6 PZIP5---------7 PZIS4----------
    PZIS4---------6 PZMP1---------- PZMP1---------6 PZMP5----------
    PZMP5---------6 PZMS4---------- PZMS4---------6 PZNP1----------
    PZNP1---------1 PZNP1---------6 PZNP4---------- PZNP4---------1
    PZNP4---------6 PZNP5---------- PZNP5---------6 PZNS1----------
    PZNS1---------1 PZNS1---------6 PZNS1---------7 PZNS4----------
    PZNS4---------1 PZNS4---------6 PZNS4---------7 PZNS5----------
    PZNS5---------6 PZNS5---------7 PZXP1---------6 PZXP2----------
    PZXP2---------6 PZXP3---------- PZXP3---------6 PZXP4---------6
    PZXP6---------- PZXP6---------6 PZXP7---------- PZXP7---------6
    PZXP7---------7 PZYP4---------- PZYP4---------1 PZYP4---------6
    PZYP4---------7 PZYS1---------- PZYS1---------1 PZYS1---------6
    PZYS5---------- PZYS5---------6 PZZS2---------- PZZS2---------1
    PZZS2---------6 PZZS3---------- PZZS3---------6 PZZS6----------
    PZZS6---------6 PZZS6---------7 PZZS7---------- PZZS7---------6
    Q3------------- RF------------- RR--1---------- RR--1---------a
    RR--1---------b RR--1---------c RR--2---------- RR--2---------6
    RR--2---------b RR--3---------- RR--3---------6 RR--3---------7
    RR--4---------- RR--4---------b RR--6---------- RR--7----------
    RR--7---------b RR--X---------- RV--2---------- RV--2---------1
    RV--3---------- RV--3---------1 RV--4---------- RV--4---------1
    RV--6---------- RV--7---------- S2--------A---- S2--------N----
    SAFD7----1A---- SAFD7----1A---6 SAFD7----2A---- SAFP1----1A----
    SAFP1----1A---6 SAFP1----2A---- SAFP2----1A---- SAFP2----1A---6
    SAFP2----2A---- SAFP3----1A---- SAFP3----1A---6 SAFP3----2A----
    SAFP3----2A---6 SAFP4----1A---- SAFP4----1A---6 SAFP4----2A----
    SAFP5----1A---- SAFP5----1A---6 SAFP5----2A---- SAFP6----1A----
    SAFP6----1A---6 SAFP6----2A---- SAFP7----1A---- SAFP7----1A---6
    SAFP7----1A---7 SAFP7----2A---- SAFP7----2A---6 SAFS1----1A----
    SAFS1----2A---- SAFS2----1A---- SAFS2----1A---6 SAFS2----2A----
    SAFS3----1A---- SAFS3----1A---6 SAFS3----2A---- SAFS4----1A----
    SAFS4----2A---- SAFS5----1A---- SAFS5----2A---- SAFS6----1A----
    SAFS6----1A---6 SAFS6----2A---- SAFS7----1A---- SAFS7----2A----
    SAIP1----1A---- SAIP1----1A---6 SAIP1----2A---- SAIP2----1A----
    SAIP2----1A---6 SAIP2----2A---- SAIP3----1A---- SAIP3----1A---6
    SAIP3----2A---- SAIP3----2A---6 SAIP4----1A---- SAIP4----1A---6
    SAIP4----2A---- SAIP5----1A---- SAIP5----1A---6 SAIP5----2A----
    SAIP6----1A---- SAIP6----1A---6 SAIP6----2A---- SAIP7----1A----
    SAIP7----1A---6 SAIP7----1A---7 SAIP7----2A---- SAIP7----2A---6
    SAIS1----1A---- SAIS1----1A---6 SAIS1----2A---- SAIS2----1A----
    SAIS2----1A---6 SAIS2----2A---- SAIS3----1A---- SAIS3----1A---6
    SAIS3----2A---- SAIS4----1A---- SAIS4----1A---6 SAIS4----2A----
    SAIS5----1A---- SAIS5----1A---6 SAIS5----2A---- SAIS6----1A----
    SAIS6----1A---6 SAIS6----1A---7 SAIS6----2A---- SAIS6----2A---6
    SAIS7----1A---- SAIS7----1A---6 SAIS7----2A---- SAIS7----2A---6
    SAMP1----1A---- SAMP1----1A---6 SAMP1----2A---- SAMP2----1A----
    SAMP2----1A---6 SAMP2----2A---- SAMP3----1A---- SAMP3----1A---6
    SAMP3----2A---- SAMP3----2A---6 SAMP4----1A---- SAMP4----1A---6
    SAMP4----2A---- SAMP5----1A---- SAMP5----1A---6 SAMP5----2A----
    SAMP6----1A---- SAMP6----1A---6 SAMP6----2A---- SAMP7----1A----
    SAMP7----1A---6 SAMP7----1A---7 SAMP7----2A---- SAMP7----2A---6
    SAMS1----1A---- SAMS1----1A---6 SAMS1----2A---- SAMS2----1A----
    SAMS2----1A---6 SAMS2----2A---- SAMS3----1A---- SAMS3----1A---6
    SAMS3----2A---- SAMS4----1A---- SAMS4----1A---6 SAMS4----2A----
    SAMS5----1A---- SAMS5----1A---6 SAMS5----2A---- SAMS6----1A----
    SAMS6----1A---6 SAMS6----1A---7 SAMS6----2A---- SAMS6----2A---6
    SAMS7----1A---- SAMS7----1A---6 SAMS7----2A---- SAMS7----2A---6
    SANP1----1A---- SANP1----1A---6 SANP1----1A---7 SANP1----2A----
    SANP2----1A---- SANP2----1A---6 SANP2----2A---- SANP3----1A----
    SANP3----1A---6 SANP3----2A---- SANP3----2A---6 SANP4----1A----
    SANP4----1A---6 SANP4----1A---7 SANP4----2A---- SANP5----1A----
    SANP5----1A---6 SANP5----1A---7 SANP5----2A---- SANP6----1A----
    SANP6----1A---6 SANP6----2A---- SANP7----1A---- SANP7----1A---6
    SANP7----1A---7 SANP7----2A---- SANP7----2A---6 SANS1----1A----
    SANS1----1A---6 SANS1----2A---- SANS2----1A---- SANS2----1A---6
    SANS2----2A---- SANS3----1A---- SANS3----1A---6 SANS3----2A----
    SANS4----1A---- SANS4----1A---6 SANS4----2A---- SANS5----1A----
    SANS5----1A---6 SANS5----2A---- SANS6----1A---- SANS6----1A---6
    SANS6----1A---7 SANS6----2A---- SANS6----2A---6 SANS7----1A----
    SANS7----1A---6 SANS7----2A---- SANS7----2A---6 SAXXX----1A----
    Sb------------- SNFP1-----A---- SNFP2-----A---- SNFP3-----A----
    SNFP4-----A---- SNFP5-----A---- SNFP6-----A---- SNFP7-----A----
    SNFP7-----A---6 SNFS1-----A---- SNFS2-----A---- SNFS3-----A----
    SNFS4-----A---- SNFS5-----A---- SNFS6-----A---- SNFS7-----A----
    SNIP1-----A---- SNIP2-----A---- SNIP3-----A---- SNIP3-----A---6
    SNIP4-----A---- SNIP5-----A---- SNIP6-----A---- SNIP6-----A---1
    SNIP7-----A---- SNIP7-----A---6 SNIS1-----A---- SNIS2-----A----
    SNIS3-----A---- SNIS4-----A---- SNIS5-----A---- SNIS6-----A----
    SNIS7-----A---- SNIXX-----A---- SNMP1-----A---- SNMP1-----A---1
    SNMP2-----A---- SNMP3-----A---- SNMP3-----A---6 SNMP4-----A----
    SNMP5-----A---- SNMP5-----A---1 SNMP6-----A---- SNMP6-----A---6
    SNMP7-----A---- SNMP7-----A---6 SNMS1-----A---- SNMS2-----A----
    SNMS3-----A---- SNMS3-----A---1 SNMS4-----A---- SNMS5-----A----
    SNMS6-----A---- SNMS6-----A---1 SNMS7-----A---- SNMXX-----A----
    SNNS1-----A---- SNNS2-----A---- SNNS3-----A---- SNNS4-----A----
    SNNS5-----A---- SNNS6-----A---- SNNS7-----A---- SNNXX-----A----
    Sn-XX---------- SNXXX-----A---- TT------------- TT------------1
    TT------------2 TT------------3 TT------------6 TT------------7
    TT------------a TT------------b TT-----------s- VB-P---1F-AAB--
    VB-P---1F-AAB-6 VB-P---1F-AAI-- VB-P---1F-AAI-3 VB-P---1F-AAI-5
    VB-P---1F-AAI-6 VB-P---1F-AAI-7 VB-P---1F-AAP-- VB-P---1F-AAP-6
    VB-P---1F-NAB-- VB-P---1F-NAB-6 VB-P---1F-NAI-- VB-P---1F-NAI-5
    VB-P---1F-NAI-6 VB-P---1F-NAI-7 VB-P---1F-NAP-- VB-P---1F-NAP-6
    VB-P---1P-AAB-- VB-P---1P-AAB-6 VB-P---1P-AAI-- VB-P---1P-AAI-1
    VB-P---1P-AAI-2 VB-P---1P-AAI-5 VB-P---1P-AAI-6 VB-P---1P-AAI-7
    VB-P---1P-AAI-8 VB-P---1P-AAP-- VB-P---1P-AAP-1 VB-P---1P-AAP-2
    VB-P---1P-AAP-5 VB-P---1P-AAP-6 VB-P---1P-AAP-7 VB-P---1P-AAP-8
    VB-P---1P-AAP-9 VB-P---1P-NAB-- VB-P---1P-NAB-6 VB-P---1P-NAI--
    VB-P---1P-NAI-1 VB-P---1P-NAI-2 VB-P---1P-NAI-6 VB-P---1P-NAI-7
    VB-P---1P-NAI-8 VB-P---1P-NAP-- VB-P---1P-NAP-1 VB-P---1P-NAP-2
    VB-P---1P-NAP-5 VB-P---1P-NAP-6 VB-P---1P-NAP-7 VB-P---1P-NAP-8
    VB-P---1P-NAP-9 VB-P---2F-AAB-- VB-P---2F-AAI-- VB-P---2F-AAI-3
    VB-P---2F-AAI-6 VB-P---2F-AAI-7 VB-P---2F-AAP-- VB-P---2F-NAB--
    VB-P---2F-NAI-- VB-P---2F-NAI-6 VB-P---2F-NAI-7 VB-P---2F-NAP--
    VB-P---2P-AAB-- VB-P---2P-AAI-- VB-P---2P-AAI-1 VB-P---2P-AAI-2
    VB-P---2P-AAI-6 VB-P---2P-AAP-- VB-P---2P-AAP-1 VB-P---2P-AAP-2
    VB-P---2P-AAP-5 VB-P---2P-AAP-6 VB-P---2P-AAP-7 VB-P---2P-AAP-9
    VB-P---2P-NAB-- VB-P---2P-NAI-- VB-P---2P-NAI-1 VB-P---2P-NAI-2
    VB-P---2P-NAI-6 VB-P---2P-NAP-- VB-P---2P-NAP-1 VB-P---2P-NAP-2
    VB-P---2P-NAP-5 VB-P---2P-NAP-6 VB-P---2P-NAP-7 VB-P---2P-NAP-9
    VB-P---3F-AAB-- VB-P---3F-AAB-1 VB-P---3F-AAI-- VB-P---3F-AAI-1
    VB-P---3F-AAI-2 VB-P---3F-AAI-6 VB-P---3F-AAI-7 VB-P---3F-AAP--
    VB-P---3F-AAP-1 VB-P---3F-NAB-- VB-P---3F-NAB-1 VB-P---3F-NAI--
    VB-P---3F-NAI-1 VB-P---3F-NAI-2 VB-P---3F-NAI-6 VB-P---3F-NAI-7
    VB-P---3F-NAP-- VB-P---3F-NAP-1 VB-P---3P-AAB-- VB-P---3P-AAB-1
    VB-P---3P-AAB-6 VB-P---3P-AAB-7 VB-P---3P-AAI-- VB-P---3P-AAI-1
    VB-P---3P-AAI-2 VB-P---3P-AAI-3 VB-P---3P-AAI-4 VB-P---3P-AAI-6
    VB-P---3P-AAI-7 VB-P---3P-AAI-8 VB-P---3P-AAP-- VB-P---3P-AAP-1
    VB-P---3P-AAP-2 VB-P---3P-AAP-3 VB-P---3P-AAP-4 VB-P---3P-AAP-5
    VB-P---3P-AAP-6 VB-P---3P-AAP-7 VB-P---3P-AAP-9 VB-P---3P-NAB--
    VB-P---3P-NAB-1 VB-P---3P-NAB-6 VB-P---3P-NAB-7 VB-P---3P-NAI--
    VB-P---3P-NAI-1 VB-P---3P-NAI-2 VB-P---3P-NAI-3 VB-P---3P-NAI-4
    VB-P---3P-NAI-6 VB-P---3P-NAI-7 VB-P---3P-NAI-8 VB-P---3P-NAP--
    VB-P---3P-NAP-1 VB-P---3P-NAP-2 VB-P---3P-NAP-3 VB-P---3P-NAP-4
    VB-P---3P-NAP-5 VB-P---3P-NAP-6 VB-P---3P-NAP-7 VB-P---3P-NAP-9
    VB-S---1F-AAB-- VB-S---1F-AAB-1 VB-S---1F-AAI-- VB-S---1F-AAI-1
    VB-S---1F-AAI-3 VB-S---1F-AAI-4 VB-S---1F-AAI-6 VB-S---1F-AAI-7
    VB-S---1F-AAP-- VB-S---1F-AAP-1 VB-S---1F-NAB-- VB-S---1F-NAB-1
    VB-S---1F-NAI-- VB-S---1F-NAI-1 VB-S---1F-NAI-4 VB-S---1F-NAI-6
    VB-S---1F-NAI-7 VB-S---1F-NAP-- VB-S---1F-NAP-1 VB-S---1P-AAB--
    VB-S---1P-AAB-1 VB-S---1P-AAB-6 VB-S---1P-AAI-- VB-S---1P-AAI-1
    VB-S---1P-AAI-2 VB-S---1P-AAI-3 VB-S---1P-AAI-4 VB-S---1P-AAI-6
    VB-S---1P-AAI-7 VB-S---1P-AAP-- VB-S---1P-AAP-1 VB-S---1P-AAP-2
    VB-S---1P-AAP-3 VB-S---1P-AAP-4 VB-S---1P-AAP-5 VB-S---1P-AAP-6
    VB-S---1P-AAP-7 VB-S---1P-AAP-9 VB-S---1P-NAB-- VB-S---1P-NAB-1
    VB-S---1P-NAB-6 VB-S---1P-NAI-- VB-S---1P-NAI-1 VB-S---1P-NAI-2
    VB-S---1P-NAI-3 VB-S---1P-NAI-4 VB-S---1P-NAI-6 VB-S---1P-NAI-7
    VB-S---1P-NAP-- VB-S---1P-NAP-1 VB-S---1P-NAP-2 VB-S---1P-NAP-3
    VB-S---1P-NAP-4 VB-S---1P-NAP-5 VB-S---1P-NAP-6 VB-S---1P-NAP-7
    VB-S---1P-NAP-9 VB-S---2F-AAB-- VB-S---2F-AAI-- VB-S---2F-AAI-3
    VB-S---2F-AAI-6 VB-S---2F-AAI-7 VB-S---2F-AAP-- VB-S---2F-NAB--
    VB-S---2F-NAI-- VB-S---2F-NAI-6 VB-S---2F-NAI-7 VB-S---2F-NAP--
    VB-S---2P-AAB-- VB-S---2P-AAI-- VB-S---2P-AAI-1 VB-S---2P-AAI-2
    VB-S---2P-AAI-6 VB-S---2P-AAI-7 VB-S---2P-AAI-8 VB-S---2P-AAP--
    VB-S---2P-AAP-1 VB-S---2P-AAP-2 VB-S---2P-AAP-5 VB-S---2P-AAP-6
    VB-S---2P-AAP-7 VB-S---2P-AAP-9 VB-S---2P-NAB-- VB-S---2P-NAI--
    VB-S---2P-NAI-1 VB-S---2P-NAI-2 VB-S---2P-NAI-6 VB-S---2P-NAP--
    VB-S---2P-NAP-1 VB-S---2P-NAP-2 VB-S---2P-NAP-5 VB-S---2P-NAP-6
    VB-S---2P-NAP-7 VB-S---2P-NAP-9 VB-S---3F-AAB-- VB-S---3F-AAI--
    VB-S---3F-AAI-3 VB-S---3F-AAI-6 VB-S---3F-AAI-7 VB-S---3F-AAP--
    VB-S---3F-NAB-- VB-S---3F-NAI-- VB-S---3F-NAI-6 VB-S---3F-NAI-7
    VB-S---3F-NAP-- VB-S---3P-AAB-- VB-S---3P-AAI-- VB-S---3P-AAI-1
    VB-S---3P-AAI-2 VB-S---3P-AAI-4 VB-S---3P-AAI-5 VB-S---3P-AAI-6
    VB-S---3P-AAI-7 VB-S---3P-AAI-9 VB-S---3P-AAP-- VB-S---3P-AAP-1
    VB-S---3P-AAP-2 VB-S---3P-AAP-5 VB-S---3P-AAP-6 VB-S---3P-AAP-7
    VB-S---3P-AAP-9 VB-S---3P-NAB-- VB-S---3P-NAI-- VB-S---3P-NAI-1
    VB-S---3P-NAI-2 VB-S---3P-NAI-4 VB-S---3P-NAI-5 VB-S---3P-NAI-6
    VB-S---3P-NAI-7 VB-S---3P-NAI-8 VB-S---3P-NAI-9 VB-S---3P-NAP--
    VB-S---3P-NAP-1 VB-S---3P-NAP-2 VB-S---3P-NAP-5 VB-S---3P-NAP-6
    VB-S---3P-NAP-7 VB-S---3P-NAP-9 Vc----------I-- Vc----------Ic-
    Vc----------Ic6 Vc----------Ie- Vc----------Im- Vc----------Im6
    Vc----------Is- VeHS------A-B-- VeHS------A-I-- VeHS------A-I-1
    VeHS------A-P-- VeHS------A-P-2 VeHS------A-P-4 VeHS------A-P-6
    VeHS------N-B-- VeHS------N-I-- VeHS------N-I-1 VeHS------N-P--
    VeHS------N-P-2 VeHS------N-P-4 VeHS------N-P-6 VeXP------A-B--
    VeXP------A-I-- VeXP------A-I-1 VeXP------A-P-2 VeXP------A-P-4
    VeXP------A-P-6 VeXP------N-B-- VeXP------N-I-- VeXP------N-I-1
    VeXP------N-P-2 VeXP------N-P-4 VeXP------N-P-6 VeYS------A-B--
    VeYS------A-I-- VeYS------A-I-1 VeYS------A-P-- VeYS------A-P-4
    VeYS------A-P-6 VeYS------N-B-- VeYS------N-I-- VeYS------N-I-1
    VeYS------N-P-- VeYS------N-P-4 VeYS------N-P-6 Vf--------A-B--
    Vf--------A-B-2 Vf--------A-B-b Vf--------A-I-- Vf--------A-I-1
    Vf--------A-I-2 Vf--------A-I-3 Vf--------A-I-6 Vf--------A-P--
    Vf--------A-P-1 Vf--------A-P-2 Vf--------A-P-3 Vf--------A-P-4
    Vf--------A-P-6 Vf--------A-P-7 Vf--------A-P-b Vf--------N-B--
    Vf--------N-B-2 Vf--------N-I-- Vf--------N-I-1 Vf--------N-I-2
    Vf--------N-I-3 Vf--------N-I-6 Vf--------N-I-7 Vf--------N-P--
    Vf--------N-P-1 Vf--------N-P-2 Vf--------N-P-3 Vf--------N-P-4
    Vf--------N-P-6 Vf--------N-P-7 Vi-P---1--A-B-- Vi-P---1--A-B-2
    Vi-P---1--A-I-- Vi-P---1--A-I-1 Vi-P---1--A-I-2 Vi-P---1--A-I-3
    Vi-P---1--A-I-4 Vi-P---1--A-I-5 Vi-P---1--A-I-6 Vi-P---1--A-I-7
    Vi-P---1--A-I-8 Vi-P---1--A-P-- Vi-P---1--A-P-1 Vi-P---1--A-P-2
    Vi-P---1--A-P-3 Vi-P---1--A-P-6 Vi-P---1--A-P-7 Vi-P---1--A-P-8
    Vi-P---1--N-B-- Vi-P---1--N-B-2 Vi-P---1--N-I-- Vi-P---1--N-I-1
    Vi-P---1--N-I-2 Vi-P---1--N-I-3 Vi-P---1--N-I-4 Vi-P---1--N-I-5
    Vi-P---1--N-I-6 Vi-P---1--N-I-7 Vi-P---1--N-I-8 Vi-P---1--N-P--
    Vi-P---1--N-P-1 Vi-P---1--N-P-2 Vi-P---1--N-P-3 Vi-P---1--N-P-6
    Vi-P---1--N-P-7 Vi-P---1--N-P-8 Vi-P---2--A-B-- Vi-P---2--A-B-2
    Vi-P---2--A-I-- Vi-P---2--A-I-1 Vi-P---2--A-I-2 Vi-P---2--A-I-3
    Vi-P---2--A-I-4 Vi-P---2--A-I-5 Vi-P---2--A-I-6 Vi-P---2--A-I-7
    Vi-P---2--A-I-8 Vi-P---2--A-P-- Vi-P---2--A-P-1 Vi-P---2--A-P-2
    Vi-P---2--A-P-3 Vi-P---2--A-P-6 Vi-P---2--A-P-7 Vi-P---2--A-P-8
    Vi-P---2--N-B-- Vi-P---2--N-B-2 Vi-P---2--N-I-- Vi-P---2--N-I-1
    Vi-P---2--N-I-2 Vi-P---2--N-I-3 Vi-P---2--N-I-4 Vi-P---2--N-I-5
    Vi-P---2--N-I-6 Vi-P---2--N-I-7 Vi-P---2--N-I-8 Vi-P---2--N-P--
    Vi-P---2--N-P-1 Vi-P---2--N-P-2 Vi-P---2--N-P-3 Vi-P---2--N-P-6
    Vi-P---2--N-P-7 Vi-P---2--N-P-8 Vi-P---3--A-B-2 Vi-P---3--A-B-4
    Vi-P---3--A-I-2 Vi-P---3--A-I-3 Vi-P---3--A-I-4 Vi-P---3--A-I-5
    Vi-P---3--A-I-6 Vi-P---3--A-I-7 Vi-P---3--A-I-8 Vi-P---3--A-I-9
    Vi-P---3--A-P-1 Vi-P---3--A-P-2 Vi-P---3--A-P-3 Vi-P---3--A-P-4
    Vi-P---3--A-P-5 Vi-P---3--A-P-6 Vi-P---3--A-P-7 Vi-P---3--A-P-8
    Vi-P---3--N-B-2 Vi-P---3--N-B-4 Vi-P---3--N-I-2 Vi-P---3--N-I-3
    Vi-P---3--N-I-4 Vi-P---3--N-I-5 Vi-P---3--N-I-6 Vi-P---3--N-I-7
    Vi-P---3--N-I-8 Vi-P---3--N-I-9 Vi-P---3--N-P-1 Vi-P---3--N-P-2
    Vi-P---3--N-P-3 Vi-P---3--N-P-4 Vi-P---3--N-P-5 Vi-P---3--N-P-6
    Vi-P---3--N-P-7 Vi-P---3--N-P-8 Vi-S---2--A-B-- Vi-S---2--A-B-2
    Vi-S---2--A-I-- Vi-S---2--A-I-1 Vi-S---2--A-I-2 Vi-S---2--A-I-3
    Vi-S---2--A-I-4 Vi-S---2--A-I-5 Vi-S---2--A-I-6 Vi-S---2--A-I-7
    Vi-S---2--A-P-- Vi-S---2--A-P-1 Vi-S---2--A-P-2 Vi-S---2--A-P-3
    Vi-S---2--A-P-6 Vi-S---2--A-P-7 Vi-S---2--A-P-9 Vi-S---2--A-P-b
    Vi-S---2--N-B-- Vi-S---2--N-B-2 Vi-S---2--N-I-- Vi-S---2--N-I-1
    Vi-S---2--N-I-2 Vi-S---2--N-I-3 Vi-S---2--N-I-4 Vi-S---2--N-I-5
    Vi-S---2--N-I-6 Vi-S---2--N-P-- Vi-S---2--N-P-1 Vi-S---2--N-P-2
    Vi-S---2--N-P-3 Vi-S---2--N-P-6 Vi-S---2--N-P-7 Vi-S---3--A-B-2
    Vi-S---3--A-B-4 Vi-S---3--A-I-2 Vi-S---3--A-I-3 Vi-S---3--A-I-4
    Vi-S---3--A-I-5 Vi-S---3--A-I-6 Vi-S---3--A-I-7 Vi-S---3--A-I-9
    Vi-S---3--A-P-1 Vi-S---3--A-P-2 Vi-S---3--A-P-3 Vi-S---3--A-P-4
    Vi-S---3--A-P-5 Vi-S---3--A-P-6 Vi-S---3--A-P-7 Vi-S---3--N-B-2
    Vi-S---3--N-B-4 Vi-S---3--N-I-2 Vi-S---3--N-I-3 Vi-S---3--N-I-4
    Vi-S---3--N-I-5 Vi-S---3--N-I-6 Vi-S---3--N-I-9 Vi-S---3--N-P-1
    Vi-S---3--N-P-2 Vi-S---3--N-P-3 Vi-S---3--N-P-4 Vi-S---3--N-P-5
    Vi-S---3--N-P-6 Vi-S---3--N-P-7 VmHS------A-B-- VmHS------A-I--
    VmHS------A-I-6 VmHS------A-P-- VmHS------A-P-1 VmHS------A-P-2
    VmHS------N-B-- VmHS------N-I-- VmHS------N-I-6 VmHS------N-P--
    VmHS------N-P-1 VmHS------N-P-2 VmXP------A-B-- VmXP------A-I--
    VmXP------A-I-2 VmXP------A-I-6 VmXP------A-P-- VmXP------A-P-1
    VmXP------A-P-2 VmXP------N-B-- VmXP------N-I-- VmXP------N-I-2
    VmXP------N-I-6 VmXP------N-P-- VmXP------N-P-1 VmXP------N-P-2
    VmYS------A-B-- VmYS------A-I-- VmYS------A-I-6 VmYS------A-P--
    VmYS------A-P-1 VmYS------A-P-2 VmYS------N-B-- VmYS------N-I--
    VmYS------N-I-6 VmYS------N-P-- VmYS------N-P-1 VmYS------N-P-2
    VpFS----R-AABs- VpFS----R-AABs1 VpFS----R-AAIs- VpFS----R-AAIs1
    VpFS----R-AAIs6 VpFS----R-AAPs- VpFS----R-AAPs1 VpFS----R-AAPs2
    VpFS----R-AAPs3 VpFS----R-AAPs6 VpFS----R-NABs- VpFS----R-NABs1
    VpFS----R-NAIs- VpFS----R-NAIs1 VpFS----R-NAIs6 VpFS----R-NAPs-
    VpFS----R-NAPs1 VpFS----R-NAPs2 VpFS----R-NAPs3 VpFS----R-NAPs6
    VpMP----R-AAB-- VpMP----R-AAB-1 VpMP----R-AAI-- VpMP----R-AAI-1
    VpMP----R-AAI-3 VpMP----R-AAI-6 VpMP----R-AAP-- VpMP----R-AAP-1
    VpMP----R-AAP-2 VpMP----R-AAP-3 VpMP----R-AAP-6 VpMP----R-AAP-7
    VpMP----R-NAB-- VpMP----R-NAB-1 VpMP----R-NAI-- VpMP----R-NAI-1
    VpMP----R-NAI-3 VpMP----R-NAI-6 VpMP----R-NAP-- VpMP----R-NAP-1
    VpMP----R-NAP-2 VpMP----R-NAP-3 VpMP----R-NAP-6 VpMP----R-NAP-7
    VpNS----R-AAB-- VpNS----R-AAB-1 VpNS----R-AABs- VpNS----R-AABs1
    VpNS----R-AAI-- VpNS----R-AAI-1 VpNS----R-AAI-3 VpNS----R-AAI-6
    VpNS----R-AAIs- VpNS----R-AAIs1 VpNS----R-AAIs6 VpNS----R-AAP--
    VpNS----R-AAP-1 VpNS----R-AAP-2 VpNS----R-AAP-3 VpNS----R-AAP-6
    VpNS----R-AAP-7 VpNS----R-AAPs- VpNS----R-AAPs1 VpNS----R-AAPs2
    VpNS----R-AAPs3 VpNS----R-AAPs6 VpNS----R-NAB-- VpNS----R-NAB-1
    VpNS----R-NABs- VpNS----R-NABs1 VpNS----R-NAI-- VpNS----R-NAI-1
    VpNS----R-NAI-3 VpNS----R-NAI-6 VpNS----R-NAIs- VpNS----R-NAIs1
    VpNS----R-NAIs6 VpNS----R-NAP-- VpNS----R-NAP-1 VpNS----R-NAP-2
    VpNS----R-NAP-3 VpNS----R-NAP-6 VpNS----R-NAP-7 VpNS----R-NAPs-
    VpNS----R-NAPs1 VpNS----R-NAPs2 VpNS----R-NAPs3 VpNS----R-NAPs6
    VpQW----R-AAB-- VpQW----R-AAB-1 VpQW----R-AAI-- VpQW----R-AAI-1
    VpQW----R-AAI-3 VpQW----R-AAI-6 VpQW----R-AAP-- VpQW----R-AAP-1
    VpQW----R-AAP-2 VpQW----R-AAP-3 VpQW----R-AAP-6 VpQW----R-AAP-7
    VpQW----R-NAB-- VpQW----R-NAB-1 VpQW----R-NAI-- VpQW----R-NAI-1
    VpQW----R-NAI-3 VpQW----R-NAI-6 VpQW----R-NAP-- VpQW----R-NAP-1
    VpQW----R-NAP-2 VpQW----R-NAP-3 VpQW----R-NAP-6 VpQW----R-NAP-7
    VpTP----R-AAB-- VpTP----R-AAB-1 VpTP----R-AAI-- VpTP----R-AAI-1
    VpTP----R-AAI-3 VpTP----R-AAI-6 VpTP----R-AAP-- VpTP----R-AAP-1
    VpTP----R-AAP-2 VpTP----R-AAP-3 VpTP----R-AAP-6 VpTP----R-AAP-7
    VpTP----R-NAB-- VpTP----R-NAB-1 VpTP----R-NAI-- VpTP----R-NAI-1
    VpTP----R-NAI-3 VpTP----R-NAI-6 VpTP----R-NAP-- VpTP----R-NAP-1
    VpTP----R-NAP-2 VpTP----R-NAP-3 VpTP----R-NAP-6 VpTP----R-NAP-7
    VpYS----R-AAB-- VpYS----R-AAB-1 VpYS----R-AAB-6 VpYS----R-AABs-
    VpYS----R-AABs1 VpYS----R-AAI-- VpYS----R-AAI-1 VpYS----R-AAI-6
    VpYS----R-AAI-7 VpYS----R-AAIs- VpYS----R-AAIs1 VpYS----R-AAIs6
    VpYS----R-AAP-- VpYS----R-AAP-1 VpYS----R-AAP-2 VpYS----R-AAP-3
    VpYS----R-AAP-6 VpYS----R-AAP-7 VpYS----R-AAPs- VpYS----R-AAPs1
    VpYS----R-AAPs2 VpYS----R-AAPs3 VpYS----R-NAB-- VpYS----R-NAB-1
    VpYS----R-NAB-6 VpYS----R-NABs- VpYS----R-NABs1 VpYS----R-NAI--
    VpYS----R-NAI-1 VpYS----R-NAI-6 VpYS----R-NAI-7 VpYS----R-NAIs-
    VpYS----R-NAIs1 VpYS----R-NAIs6 VpYS----R-NAP-- VpYS----R-NAP-1
    VpYS----R-NAP-2 VpYS----R-NAP-3 VpYS----R-NAP-6 VpYS----R-NAP-7
    VpYS----R-NAPs- VpYS----R-NAPs1 VpYS----R-NAPs2 VpYS----R-NAPs3
    VqMP----R-AAB-2 VqMP----R-AAB-3 VqMP----R-AAI-2 VqMP----R-AAI-3
    VqMP----R-AAI-6 VqMP----R-AAP-2 VqMP----R-AAP-3 VqMP----R-AAP-4
    VqMP----R-AAP-5 VqMP----R-NAB-2 VqMP----R-NAB-3 VqMP----R-NAI-2
    VqMP----R-NAI-3 VqMP----R-NAI-6 VqMP----R-NAP-2 VqMP----R-NAP-3
    VqMP----R-NAP-4 VqMP----R-NAP-5 VqNS----R-AAB-2 VqNS----R-AAB-3
    VqNS----R-AAI-2 VqNS----R-AAI-3 VqNS----R-AAI-6 VqNS----R-AAP-2
    VqNS----R-AAP-3 VqNS----R-AAP-4 VqNS----R-AAP-5 VqNS----R-NAB-2
    VqNS----R-NAB-3 VqNS----R-NAI-2 VqNS----R-NAI-3 VqNS----R-NAI-6
    VqNS----R-NAP-2 VqNS----R-NAP-3 VqNS----R-NAP-4 VqNS----R-NAP-5
    VqQW----R-AAB-2 VqQW----R-AAB-3 VqQW----R-AAI-2 VqQW----R-AAI-3
    VqQW----R-AAI-6 VqQW----R-AAP-2 VqQW----R-AAP-3 VqQW----R-AAP-4
    VqQW----R-AAP-5 VqQW----R-NAB-2 VqQW----R-NAB-3 VqQW----R-NAI-2
    VqQW----R-NAI-3 VqQW----R-NAI-6 VqQW----R-NAP-2 VqQW----R-NAP-3
    VqQW----R-NAP-4 VqQW----R-NAP-5 VqTP----R-AAB-2 VqTP----R-AAB-3
    VqTP----R-AAI-2 VqTP----R-AAI-3 VqTP----R-AAI-6 VqTP----R-AAP-2
    VqTP----R-AAP-3 VqTP----R-AAP-4 VqTP----R-AAP-5 VqTP----R-NAB-2
    VqTP----R-NAB-3 VqTP----R-NAI-2 VqTP----R-NAI-3 VqTP----R-NAI-6
    VqTP----R-NAP-2 VqTP----R-NAP-3 VqTP----R-NAP-4 VqTP----R-NAP-5
    VqYS----R-AAB-2 VqYS----R-AAB-3 VqYS----R-AAI-2 VqYS----R-AAI-3
    VqYS----R-AAI-6 VqYS----R-AAP-2 VqYS----R-AAP-3 VqYS----R-AAP-4
    VqYS----R-AAP-5 VqYS----R-NAB-2 VqYS----R-NAB-3 VqYS----R-NAI-2
    VqYS----R-NAI-3 VqYS----R-NAI-6 VqYS----R-NAP-2 VqYS----R-NAP-3
    VqYS----R-NAP-4 VqYS----R-NAP-5 VsFS4---X-APB-- VsFS4---X-API--
    VsFS4---X-API-1 VsFS4---X-API-2 VsFS4---X-APP-- VsFS4---X-APP-1
    VsFS4---X-APP-2 VsFS4---X-NPB-- VsFS4---X-NPI-- VsFS4---X-NPI-1
    VsFS4---X-NPI-2 VsFS4---X-NPP-- VsFS4---X-NPP-1 VsFS4---X-NPP-2
    VsFS----H-APBs- VsFS----H-APIs- VsFS----H-APIs1 VsFS----H-APPs-
    VsFS----H-APPs1 VsFS----H-APPs2 VsFS----H-NPBs- VsFS----H-NPIs-
    VsFS----H-NPIs1 VsFS----H-NPPs- VsFS----H-NPPs1 VsFS----H-NPPs2
    VsMP----X-APB-- VsMP----X-API-- VsMP----X-API-1 VsMP----X-API-2
    VsMP----X-APP-- VsMP----X-APP-1 VsMP----X-APP-2 VsMP----X-NPB--
    VsMP----X-NPI-- VsMP----X-NPI-1 VsMP----X-NPI-2 VsMP----X-NPP--
    VsMP----X-NPP-1 VsMP----X-NPP-2 VsNS----H-APBs- VsNS----H-APIs-
    VsNS----H-APIs1 VsNS----H-APPs- VsNS----H-APPs1 VsNS----H-APPs2
    VsNS----H-NPBs- VsNS----H-NPIs- VsNS----H-NPIs1 VsNS----H-NPPs-
    VsNS----H-NPPs1 VsNS----H-NPPs2 VsNS----X-APB-- VsNS----X-API--
    VsNS----X-API-1 VsNS----X-API-2 VsNS----X-API-6 VsNS----X-APP--
    VsNS----X-APP-1 VsNS----X-APP-2 VsNS----X-APP-5 VsNS----X-APP-6
    VsNS----X-APP-7 VsNS----X-NPB-- VsNS----X-NPI-- VsNS----X-NPI-1
    VsNS----X-NPI-2 VsNS----X-NPI-6 VsNS----X-NPP-- VsNS----X-NPP-1
    VsNS----X-NPP-2 VsNS----X-NPP-6 VsNS----X-NPP-7 VsQW----X-APB--
    VsQW----X-API-- VsQW----X-API-1 VsQW----X-API-2 VsQW----X-APP--
    VsQW----X-APP-1 VsQW----X-APP-2 VsQW----X-APP-6 VsQW----X-NPB--
    VsQW----X-NPI-- VsQW----X-NPI-1 VsQW----X-NPI-2 VsQW----X-NPP--
    VsQW----X-NPP-1 VsQW----X-NPP-2 VsQW----X-NPP-6 VsTP----X-APB--
    VsTP----X-API-- VsTP----X-API-1 VsTP----X-API-2 VsTP----X-APP--
    VsTP----X-APP-1 VsTP----X-APP-2 VsTP----X-APP-6 VsTP----X-NPB--
    VsTP----X-NPI-- VsTP----X-NPI-1 VsTP----X-NPI-2 VsTP----X-NPP--
    VsTP----X-NPP-1 VsTP----X-NPP-2 VsTP----X-NPP-6 VsYS----H-APIs-
    VsYS----X-APB-- VsYS----X-API-- VsYS----X-API-1 VsYS----X-API-2
    VsYS----X-APP-- VsYS----X-APP-1 VsYS----X-APP-2 VsYS----X-NPB--
    VsYS----X-NPI-- VsYS----X-NPI-1 VsYS----X-NPI-2 VsYS----X-NPP--
    VsYS----X-NPP-1 VsYS----X-NPP-2 Vt-P---1F-AAB-2 Vt-P---1F-AAB-3
    Vt-P---1F-AAI-2 Vt-P---1F-AAI-3 Vt-P---1F-AAP-2 Vt-P---1F-AAP-3
    Vt-P---1F-NAB-2 Vt-P---1F-NAB-3 Vt-P---1F-NAI-2 Vt-P---1F-NAI-3
    Vt-P---1F-NAP-2 Vt-P---1F-NAP-3 Vt-P---1P-AAB-2 Vt-P---1P-AAB-3
    Vt-P---1P-AAI-2 Vt-P---1P-AAI-3 Vt-P---1P-AAI-4 Vt-P---1P-AAI-5
    Vt-P---1P-AAI-6 Vt-P---1P-AAI-7 Vt-P---1P-AAP-1 Vt-P---1P-AAP-2
    Vt-P---1P-AAP-3 Vt-P---1P-AAP-4 Vt-P---1P-AAP-5 Vt-P---1P-AAP-6
    Vt-P---1P-AAP-7 Vt-P---1P-AAP-8 Vt-P---1P-NAB-2 Vt-P---1P-NAB-3
    Vt-P---1P-NAI-2 Vt-P---1P-NAI-3 Vt-P---1P-NAI-4 Vt-P---1P-NAI-5
    Vt-P---1P-NAI-6 Vt-P---1P-NAI-7 Vt-P---1P-NAP-1 Vt-P---1P-NAP-2
    Vt-P---1P-NAP-3 Vt-P---1P-NAP-4 Vt-P---1P-NAP-5 Vt-P---1P-NAP-6
    Vt-P---1P-NAP-7 Vt-P---1P-NAP-8 Vt-P---2F-AAB-2 Vt-P---2F-AAI-2
    Vt-P---2F-AAP-2 Vt-P---2F-NAB-2 Vt-P---2F-NAI-2 Vt-P---2F-NAP-2
    Vt-P---2P-AAB-2 Vt-P---2P-AAI-2 Vt-P---2P-AAI-3 Vt-P---2P-AAI-4
    Vt-P---2P-AAI-6 Vt-P---2P-AAI-7 Vt-P---2P-AAP-2 Vt-P---2P-AAP-3
    Vt-P---2P-AAP-5 Vt-P---2P-AAP-6 Vt-P---2P-AAP-7 Vt-P---2P-NAB-2
    Vt-P---2P-NAI-2 Vt-P---2P-NAI-3 Vt-P---2P-NAI-4 Vt-P---2P-NAI-6
    Vt-P---2P-NAI-7 Vt-P---2P-NAP-2 Vt-P---2P-NAP-3 Vt-P---2P-NAP-5
    Vt-P---2P-NAP-6 Vt-P---2P-NAP-7 Vt-P---3F-AAB-2 Vt-P---3F-AAB-3
    Vt-P---3F-AAI-2 Vt-P---3F-AAI-3 Vt-P---3F-AAP-2 Vt-P---3F-AAP-3
    Vt-P---3F-NAB-2 Vt-P---3F-NAB-3 Vt-P---3F-NAI-2 Vt-P---3F-NAI-3
    Vt-P---3F-NAP-2 Vt-P---3F-NAP-3 Vt-P---3P-AAB-2 Vt-P---3P-AAB-3
    Vt-P---3P-AAB-9 Vt-P---3P-AAI-2 Vt-P---3P-AAI-3 Vt-P---3P-AAI-4
    Vt-P---3P-AAI-5 Vt-P---3P-AAI-6 Vt-P---3P-AAI-7 Vt-P---3P-AAI-9
    Vt-P---3P-AAP-1 Vt-P---3P-AAP-2 Vt-P---3P-AAP-3 Vt-P---3P-AAP-4
    Vt-P---3P-AAP-5 Vt-P---3P-AAP-6 Vt-P---3P-AAP-7 Vt-P---3P-AAP-9
    Vt-P---3P-NAB-2 Vt-P---3P-NAB-3 Vt-P---3P-NAB-9 Vt-P---3P-NAI-2
    Vt-P---3P-NAI-3 Vt-P---3P-NAI-4 Vt-P---3P-NAI-5 Vt-P---3P-NAI-6
    Vt-P---3P-NAI-7 Vt-P---3P-NAI-9 Vt-P---3P-NAP-1 Vt-P---3P-NAP-2
    Vt-P---3P-NAP-3 Vt-P---3P-NAP-4 Vt-P---3P-NAP-5 Vt-P---3P-NAP-6
    Vt-P---3P-NAP-7 Vt-P---3P-NAP-9 Vt-S---1F-AAB-2 Vt-S---1F-AAB-3
    Vt-S---1F-AAI-2 Vt-S---1F-AAI-3 Vt-S---1F-AAP-2 Vt-S---1F-AAP-3
    Vt-S---1F-NAB-2 Vt-S---1F-NAB-3 Vt-S---1F-NAI-2 Vt-S---1F-NAI-3
    Vt-S---1F-NAP-2 Vt-S---1F-NAP-3 Vt-S---1P-AAB-2 Vt-S---1P-AAB-3
    Vt-S---1P-AAI-2 Vt-S---1P-AAI-3 Vt-S---1P-AAI-4 Vt-S---1P-AAI-5
    Vt-S---1P-AAI-6 Vt-S---1P-AAI-7 Vt-S---1P-AAP-1 Vt-S---1P-AAP-2
    Vt-S---1P-AAP-3 Vt-S---1P-AAP-4 Vt-S---1P-AAP-5 Vt-S---1P-AAP-6
    Vt-S---1P-AAP-7 Vt-S---1P-NAB-2 Vt-S---1P-NAB-3 Vt-S---1P-NAI-2
    Vt-S---1P-NAI-3 Vt-S---1P-NAI-4 Vt-S---1P-NAI-5 Vt-S---1P-NAI-6
    Vt-S---1P-NAI-7 Vt-S---1P-NAP-1 Vt-S---1P-NAP-2 Vt-S---1P-NAP-3
    Vt-S---1P-NAP-4 Vt-S---1P-NAP-5 Vt-S---1P-NAP-6 Vt-S---1P-NAP-7
    Vt-S---2F-AAB-2 Vt-S---2F-AAI-2 Vt-S---2F-AAP-2 Vt-S---2F-NAB-2
    Vt-S---2F-NAI-2 Vt-S---2F-NAP-2 Vt-S---2P-AAB-2 Vt-S---2P-AAI-2
    Vt-S---2P-AAI-3 Vt-S---2P-AAI-4 Vt-S---2P-AAI-6 Vt-S---2P-AAI-7
    Vt-S---2P-AAP-2 Vt-S---2P-AAP-3 Vt-S---2P-AAP-5 Vt-S---2P-AAP-6
    Vt-S---2P-AAP-7 Vt-S---2P-NAB-2 Vt-S---2P-NAI-2 Vt-S---2P-NAI-3
    Vt-S---2P-NAI-4 Vt-S---2P-NAI-6 Vt-S---2P-NAI-7 Vt-S---2P-NAP-2
    Vt-S---2P-NAP-3 Vt-S---2P-NAP-5 Vt-S---2P-NAP-6 Vt-S---2P-NAP-7
    Vt-S---3F-AAB-2 Vt-S---3F-AAI-2 Vt-S---3F-AAP-2 Vt-S---3F-NAB-2
    Vt-S---3F-NAI-2 Vt-S---3F-NAP-2 Vt-S---3P-AAB-2 Vt-S---3P-AAI-2
    Vt-S---3P-AAI-3 Vt-S---3P-AAI-4 Vt-S---3P-AAI-6 Vt-S---3P-AAI-7
    Vt-S---3P-AAP-2 Vt-S---3P-AAP-3 Vt-S---3P-AAP-5 Vt-S---3P-AAP-6
    Vt-S---3P-AAP-7 Vt-S---3P-NAB-2 Vt-S---3P-NAI-2 Vt-S---3P-NAI-3
    Vt-S---3P-NAI-4 Vt-S---3P-NAI-6 Vt-S---3P-NAI-7 Vt-S---3P-NAP-2
    Vt-S---3P-NAP-3 Vt-S---3P-NAP-5 Vt-S---3P-NAP-6 Vt-S---3P-NAP-7
    Xx------------- XX------------- Z:------------- NNMP2-----N---1
    NNMP3-----N---1 NNFXX-----N---- NNNXX-----N---- NNPS6-----A---6
    NNPS6-----N---6 NNNP7-----N---2 NNFS1-----N---1 NNIPX-----A----
    NNIPX-----N---- P4ZS6--------s7 P4FS3--------s6 P4FS6--------s6
    P4NS1--------s6 P4NP4--------s6 P4NS4--------s6 P4FS2--------s6
    P4NP4--------s7 P4YS1--------s6 P4IS4--------s6 P4XP2--------s6
    P4XP6--------s6 P4XP3--------s6 P4XP7--------s6 P4FD7--------s6
    P4FS4--------s- P4FS7--------s- P4ZS6--------s6 P4ZS7--------s6
    P4NP4--------s- P4NS1--------s- P4NS4--------s- P4FS2--------s-
    P4FS6--------s- P4ZS2--------s- P4YS1--------s- P4IS4--------s-
    P4ZS2--------s6 P4MS4--------s6 P4XP7--------s7 P4FD7--------s-
    P4ZS3--------s6 PJFS4---------1 PJZS7---------1 PJXP2---------1
    PJFS2---------1 PJFS3---------1 PJFS7---------1 PEFS2--3------1
    PEFS3--3------1 PEFS7--3------1 PEZS2--3------2 PEXP2--3------1
    P4XP4--------s6 P4ZS7--------s9 P4XP3--------s9 NNNP7-----A---8
    NNNP7-----N---8 CnXXX---------1 PJXP4---------1 PJNS4---------1
    P1FXXFS3------- P9FXXFS3------- PJFS6---------1 PJXP6---------1
    PJXP1---------- PJZS2---------3 PJZS4---------3 PJZS2---------4
    VpNP----R-AAP-6 VpNP----R-NAP-6 VsNP----X-APP-6 VsNP----X-NPP-6
    VpNP----R-AAB-6 VpNP----R-NAB-6 VsNP----X-APB-6 VsNP----X-NPB-6
    VpNP----R-AAI-6 VpNP----R-NAI-6 VsNP----X-API-6 VsNP----X-NPI-6
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


#bind EditAllComments to Ctrl+question menu Edit All Comments
sub EditAllComments {
    ChangingFile(0);
    my @comments = ListV($this->attr('comment'));
    my $remove = TredMacro::ListQuery('Remove comments',
                                      'multiple',
                                      [ map $_->{text}, @comments ],
                                      [],
                                      { label => 'Select comments to remove' });
    return unless $remove;

    my %r; undef @r{@$remove};
    my @keep = grep ! exists $r{$_}, 0 .. $#comments;
    $this->{comment} = List(@comments[@keep]);
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

