#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;

use open IO => ':encoding(UTF-8)', ':std';

my $orig_dir = "$FindBin::Bin/../../WorkData/PDTSC/data";

{   package Local::Original::Iterator;
    use Moo;
    has file => (is => 'ro');
    has _fh => (is => 'ro', lazy => 1, builder => '_build_fh');
    sub _build_fh {
        my ($self) = @_;
        open my $fh, '<', "$orig_dir/" . $self->file . ".mdata"
            or die $self->file, ": $!";
        return $fh
    }
    sub next_token {
        my ($self) = @_;
        my $line = "";
        $line = readline $self->_fh
            until eof $self->_fh || $line =~ m{<form>(.*)</form>};

        my $value = $1;
        return $value || ""
    }
    sub done { eof $_[0]->_fh }
}

{   package Local::New::Iterator;
    use Moo;
    has file => (is => 'ro');
    has _num => (is => 'rw', default => '00');
    has _fh => (is => 'ro', lazy => 1, builder => '_build_fh',
                clearer => '_clear_fh');
    sub _build_fh {
        my ($self) = @_;
        open my $fh, '<', "$orig_dir/" . $self->file . '.' . $self->_num . '.w'
            or return 'done';
        return $fh
    }
    sub next_token {
        my ($self) = @_;
        my ($line, $value) = ("");
        return "" if $self->done;

        until ($value = ($line =~ m{<token>(.*)</token>})[0]
               or eof $self->_fh
         ) {
            $line = readline $self->_fh;
            if (eof $self->_fh) {
                $self->_num(sprintf '%02d', 1 + $self->_num);
                $self->_clear_fh;
            }
        }
        return $value || ""
    }
    sub done { 'done' eq $_[0]->_fh }
}


while (<>) {
    my ($new, $old) = split;
    my $old_i = 'Local::Original::Iterator'->new(file => $old);
    my $new_i = 'Local::New::Iterator'->new(file => $new);

    my $same = 1;
    until ($old_i->done || $new_i->done) {
        my ($o, $n) = map $_->next_token, $old_i, $new_i;
        undef $same unless $o eq $n;
    }
    say "$new $old" unless $same;
}

# Expects output of identify_pdtsc.pl as input.
