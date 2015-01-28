package Plack::Middleware::Antibot::FilterBase;

use strict;
use warnings;

use Carp qw(croak);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub score {
    $_[0]->{score};
}

sub execute {
}

1;
