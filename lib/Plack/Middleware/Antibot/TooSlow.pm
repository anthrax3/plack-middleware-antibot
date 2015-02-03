package Plack::Middleware::Antibot::TooSlow;

use strict;
use warnings;

use parent 'Plack::Middleware::Antibot::FilterBase';

use Plack::Session;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{session_name} = $params{session_name} || 'antibot_tooslow';
    $self->{timeout}      = $params{timeout}      || 60 * 60;
    $self->{score}        = $params{score}        || 0.8;

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

        my $too_slow = $session->get($self->{session_name});
        unless ($too_slow && time - $too_slow < $self->{timeout}) {
            $env->{'plack.antibot.tooslow.detected'}++;
        }
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Antibot::TooSlow - Check if form was submitted too slow

=head1 SYNOPSIS

    enable 'Antibot', filters => ['TooSlow'];

=head1 DESCRIPTION

Plack::Middleware::Antibot::TooSlow checks if form was submitted too slow.

=head2 Options

=head3 B<score>

Filter's score when bot detected. C<0.8> by default.

=head3 B<session_name>

Session name. C<antibot_tooslow> by default.

=head3 B<timeout>

Timeout in seconds. C<60 * 60> by default (1 hour).

=cut
