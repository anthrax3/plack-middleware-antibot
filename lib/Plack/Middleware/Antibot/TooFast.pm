package Plack::Middleware::Antibot::TooFast;

use strict;
use warnings;

use parent 'Plack::Middleware::Antibot::FilterBase';

use Plack::Session;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{session_name} = $params{session_name} || 'antibot_toofast';
    $self->{timeout}      = $params{timeout}      || 1;
    $self->{score}        = $params{score}        || 0.9;

    return $self;
}

sub execute {
    my $self = shift;
    my ($env) = @_;

    if ($env->{REQUEST_METHOD} eq 'GET') {
        my $session = Plack::Session->new($env);

        $session->set($self->{session_name}, time);
    }
    elsif ($env->{REQUEST_METHOD} eq 'POST') {
        my $session = Plack::Session->new($env);

        my $too_fast = $session->get($self->{session_name});
        unless ($too_fast && time - $too_fast > $self->{timeout}) {
            $env->{'antibot.toofast.detected'}++;
        }
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Antibot::TooFast - Check if form was submitted too fast

=head1 SYNOPSIS

    enable 'Antibot', filters => ['TooFast'];

=head1 DESCRIPTION

Plack::Middleware::Antibot::TooFast checks if form was submitted too fast.

=head2 Options

=head3 B<session_name>

Session name. C<antibot_toofast> by default.

=head3 B<timeout>

Timeout in seconds. C<1> by default.

=cut
