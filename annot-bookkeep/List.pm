use warnings;
use strict;

my @FILE_ATTRS = qw( name sentences forms annotator sent done comment );

{   package List::File;
    use Moo;

    has [@FILE_ATTRS] => (is => 'rw');

    sub serialise {
        my ($self) = @_;
        return join "\t",
               map $self->$_ // "",
               @FILE_ATTRS
    }
}

{   package List::Builder::Config;
    use Moo;
    use Path::Tiny qw{ path };
    use namespace::clean;

    has config => (is      => 'ro',
                   default => path(__FILE__)->parent . "/list.cfg");

    sub build {
        my ($self) = @_;
        open my $in, '<', $self->config
            or die "Can't open " . $self->config . ": $!";
        my %cfg;
        while (<$in>) {
            chomp;
            my ($key, $value) = split / = /, $_, 2;
            die "Duplicate $key in ", $self->config
                if exists $cfg{$key};
            $cfg{$key} = $value;
        }
        return 'List'->new(map +($_ => $cfg{$_}), qw( svn inactive ));
    }
}

package List;
use Moo;
use List::Util ();
use FindBin ();

has svn      => (is => 'ro', required => 1);
has inactive => (is => 'ro');
has list     => (is => 'lazy');
has bindir   => (is => 'ro', default => $FindBin::Bin);
has file     => (is => 'rwp');

sub workdir {
    my ($self, $annotator) = @_;
    my $dir = $self->svn . "/annotators/$annotator";
    die "$dir not found" unless -d $dir;
    return $dir
}

sub shuffle {
    my ($self) = @_;
    @{ $self->list } = List::Util::shuffle(@{ $self->list });
}

sub for_each {
    my ($self, $code) = @_;
    for (@{ $self->list }) {
        my %args;
        @args{@FILE_ATTRS} = split /\t/;
        my $file = 'List::File'->new(%args);
        $code->($self, $file);
    }
}

sub header {
    return '# ' . join "\t", @FILE_ATTRS
}

sub _build_list {
    my ($self) = @_;
    $self->_set_file($self->bindir . '/list.txt');
    open my $in, '<', $self->file
        or die 'list.txt not found in ' . $self->bindir;

    chomp( my @lines = grep ! /^#/, <$in> );
    return \@lines
}

__PACKAGE__
