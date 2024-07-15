#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

my %sign = (black   => '=',
            magenta => '&gt;',
            blue    => '&lt;',
            green   => '+',
            red     => '-');
my %order;

sub output(@buffer) {
    my $plain_lemma = $buffer[0][0];
    $plain_lemma =~ s/-.*//;
    my $order = $order{$plain_lemma};
    @buffer = sort {
        (($order->{"@$a[0 .. 3]"}[0] // 'Inf')
          <=>
         ($order->{"@$b[0 .. 3]"}[0] // 'Inf'))
    } @buffer;
    say "<p>";
    for my $line (@buffer) {
        my $count = $order->{"@$line[0 .. 3]"}[1] // 0;
        my $color = qw( black magenta blue )[$count <=> $line->[4]];
        $color = 'green' if 0 == $count;
        print qq(<font color="$color">$sign{$color});
        say join ' ', @$line[0 .. 3], $count, $line->[4];
        print '</font>';
        say '<br>';
        delete $order->{"@$line[0 .. 3]"};
    }
    for my $line (sort { $order->{$a}[0] <=> $order->{$b}[0] } keys %$order) {
        say qq(<font color="red">$sign{red});
        say "$line $order->{$line}[1] 0";
        say '</font><br>';
    }
}

die "Usage: $0 old new\n" if @ARGV != 2 || grep ! -f $_, @ARGV;
my ($old, $new) = @ARGV;

{   open my $in, '<', $old or die $!;
    my $i = 1;
    while (<$in>) {
        chomp;
        $i = 1, next unless $_;

        my ($lemma, $tag, $afun, $functor, $count) = split;
        my $plain_lemma = $lemma =~ s/-.*//r;
        die $count if $count == 0;

        $order{$plain_lemma}{"$lemma $tag $afun $functor"} = [$i++, $count];
    }
}
{   open my $in, '<', $new or die $!;
    my @buffer;
    while (<$in>) {
        chomp;
        if (! length && @buffer) {
            output(@buffer);
            @buffer = ();
        } elsif ($_) {
            push @buffer, [split ' '];
        }
    }
    output(@buffer) if @buffer;
}
