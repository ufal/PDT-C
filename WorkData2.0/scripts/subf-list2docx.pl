#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use open ':encoding(UTF-8)', ':std';

use Excel::Writer::XLSX;

{   package My::Excel;
    use Moo;
    no warnings 'experimental';

    has name      => (is => 'ro', required => 1);
    has workbook  => (is => 'lazy',
                      handles => [qw[ close add_worksheet add_format ]]);
    has worksheet => (is => 'lazy',
                      handles => [qw[ write write_rich_string write_col
                                      set_column freeze_panes
                                      data_validation ]]);

    has [qw[ tag red blue bold beige_bg small justify unlocked ]]
        => (is => 'lazy');

    sub formated($self, $part) {
        return $part unless 0 == index $part, '<<';
        my ($tag, $word) = $part =~ /^<<([^:]+):(.+)>>$/;
        $tag =~ s/%.*//;
        return $self->tag->{$tag}, $word
    }

    my @FUNCTORS = qw( ACMP MANN MEANS COND AIM REG TWHEN TSIN CPR EXT
                       MOD CIRC OTHER );
    my @SUBFUNCTORS = qw( community association included excluded
                          attribute of-event of-agent of-result idiom
                          condition side-effect concomitant tool
                          transport mediator because progressively
                          proportionally intent regard simultaneously
                          validity compared adequately large certainty
                          probability other );
    sub BUILD($self, $args) {
        $self->write(0, 0, ['Position', 'Sentence',
                                'Functor', 'Subfunctor', "",
                                'Functor2', 'Subfunctor2', "", 'Comment'],
                         $self->bold);
        $self->write(0, $_, "", $self->beige_bg) for 4, 7;

        my @widths = (22, 42, 8, 14, 1, 8, 14, 1, 30);
        for my $i (0 .. $#widths) {
            $self->set_column($i, $i, $widths[$i]);
        }
        $self->freeze_panes(1, 0);

        $self->write_col(0, 52, \@SUBFUNCTORS);
        $self->set_column(52, 52, undef, undef, 1);

        $self->data_validation(1, $_, 50, $_, {validate => 'list',
                                               source   => \@FUNCTORS})
            for 2, 5;
        $self->data_validation(1, $_, 50, $_, {validate => 'list',
                                               source   => '=$BA$1:$BA$28'})
            for 3, 6;
    }

    sub _build_workbook($self) {
        'Excel::Writer::XLSX'->new($self->name)
    }

    sub _build_worksheet($self) {
        my $ws = $self->add_worksheet('Subf');
        $ws->protect;
        return $ws
    }

    sub _build_tag($self) {
        {prep => $self->red,
         verb => $self->blue,
         f    => $self->red}
    }

    sub _build_red($self) {
        my $red = $self->add_format;
        $red->set_color('red');
        $red->set_bold;
        return $red
    }

    sub _build_blue($self) {
        my $blue = $self->add_format;
        $blue->set_color('blue');
        return $blue
    }

    sub _build_bold($self) {
        my $bold = $self->add_format;
        $bold->set_bold;
        return $bold
    }

    sub _build_beige_bg($self) {
        my $beige = $self->add_format;
        $beige->set_bg_color('#FBE5D6');
        return $beige
    }

    sub _build_small($self) {
        my $small = $self->add_format;
        $small->set_size(8);
        return $small
    }

    sub _build_justify($self) {
        my $justify = $self->add_format;
        $justify->set_align('vjustify');
        $justify->set_size(12);
        return $justify
    }

    sub _build_unlocked($self) {
        my $unlocked = $self->add_format;
        $unlocked->set_locked(0);
        return $unlocked
    }
}

sub report($freq) {
    say join ' ',
        map "$_ $freq->{$_}",
        sort { $freq->{$b} <=> $freq->{$a} }
        keys %$freq;
}

my $file_tally = 1;
my $e;

my $row = 1;
my %freq;
my %seen;
my %total;

while (my $line = <>) {
    my $r = int rand 8;
    next if $line =~ /%ACMP:/ && 0 != $r;

    my $clean = $line =~ s/<<[^>]+:|\t.*//gr;
    next if $seen{$clean}++;

    $e = 'My::Excel'->new(name => "subf-s-$file_tally.xlsx")
        unless $e;

    my ($functor) = $line =~ /<<f%([^:]+):/;
    ++$freq{$functor};

    chomp $line;
    my ($sentence, $pos) = split /\t/, $line;
    substr $pos, 0, 1 + rindex($pos, '/'), "";

    my @parts = map $e->formated($_), split /(<<.*?>>)/, $sentence;

    $e->write($row, 0, $pos, $e->small);
    $e->write_rich_string($row, 1, @parts, $e->justify);
    $e->write($row, $_, " ", $e->beige_bg) for 4, 7;
    $e->write($row, $_, "", $e->unlocked) for 2, 3, 5, 6, 8;
    # $e->write($row, 9, $functor);
    if ($row++ == 50) {
        $e->close;
        undef $e;
        $row = 1;
        $total{$_} += $freq{$_} for keys %freq;
        report(\%freq);
        %freq = ();
        %seen = ();
        last if ++$file_tally > 10;
    }
}
print "Total: ";
report(\%total);
