#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use FindBin;
use Path::Tiny qw{ path };

my $target = shift;
die 'Target not specified' unless defined $target;

-d 'annotators' or die 'The directory annotators/ not found';

my %rev;
my %ignore;
open my $svn, '-|', qw{ svn log -v annotators/ } or die $!;
my $rev;
while (<$svn>) {
    $rev = $1 if /^r([0-9]+) \| /;
    if (m{^ +[AM] /(annotators/.../done/.+\.[tamw])(?:$| )}) {
        push @{ $rev{$1} }, $rev unless exists $ignore{$1};
    } elsif (m{^ +D /(annotators/.../done/.+\.[tamw])(?:$| )}) {
        undef $ignore{$1};
    }
}

my %non_existing;
@non_existing{ keys %rev } = ();
for my $file (glob 'annotators/???/done/*.[tamw]') {
    say "Missing $file" unless $rev{$file};
    delete $non_existing{$file};
}

delete @rev{ keys %non_existing };

unless (-d $target) {
    mkdir $target or die $!;
}

my $resource_dir = path(path($FindBin::Bin)->parent->parent,
                        qw( tred-extension pdtc10 resources ));

for my $file (sort keys %rev) {
    my $rev = pop @{ $rev{$file} };
    say STDERR "$file\t$rev";
    my $path = $file =~ s{/[^/]+$}{}r;
    open my $svn, '-|', qw{ svn cat -r }, $rev, $file or die $!;
    path("$target/$path")->mkdir;
    open my $out, '>', "$target/$file" or die $!;
    print {$out} $_ while <$svn>;
    close $out;
    if (0 != system '/net/work/people/stepanek/pml/bin/pml_validate',
                 -p => $resource_dir,
                 -p => '/net/work/projects/pcedt-coref/tred-extension/pcedt-coref/resources',
                 -p => '/net/work/people/stepanek/pcedt-cz/tred_extensions/wsj-anot/resources',
                 -p => '/net/work/people/stepanek/tred/TrEd/extensions/pdt20/resources',
                 "$target/$file"
    ) {
        redo if @{ $rev{$file} };
        die "No other versions of $target/$file"
    }
}



=head1 NAME

 first-commit.pl

=head1 SYNOPSIS

 first-commit.pl target-dir

=head1 DESCRIPTION

Create a copy of the annotated files (only t-layer) where the first valid
commit version is used instead of the final one.

=cut
