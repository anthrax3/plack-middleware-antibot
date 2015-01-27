package Plack::Middleware::Antibot::FilterBase;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub check {
}

1;
