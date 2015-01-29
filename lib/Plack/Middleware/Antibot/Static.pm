package Plack::Middleware::Antibot::Static;

use strict;
use warnings;

use parent 'Plack::Middleware::Antibot::FilterBase';

use Plack::Session;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{path}         = $params{path}         || '/antibot.gif';
    $self->{session_name} = $params{session_name} || 'antibot_static';
    $self->{timeout}      = $params{timeout}      || 60 * 15;
    $self->{score}        = $params{score}        || 0.9;

    return $self;
}

sub execute {
    my $self = shift;
    my ($env) = @_;

    if ($env->{REQUEST_METHOD} eq 'GET') {
        my $path_info = $env->{PATH_INFO};

        if ($path_info eq $self->{path}) {
            my $session = Plack::Session->new($env);
            $session->set($self->{session_name} => time);

            return [200, [], ['']];
        }

        $env->{'antibot.static.path'} = $self->{path};
        $env->{'antibot.static.html'} = qq{<img src="$self->{path}" }
          . qq{width="1" height="1" style="display:none" />};
    }
    elsif ($env->{REQUEST_METHOD} eq 'POST') {
        my $session = Plack::Session->new($env);

        my $static_fetched = $session->get($self->{session_name});
        unless ($static_fetched && time - $static_fetched < $self->{timeout}) {
            $env->{'antibot.static.detected'}++;
        }
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Antibot::Static - Check if static file was fetched

=head1 SYNOPSIS

    enable 'Antibot', filters =>
      [['Static', path => '/antibot.css']];

=head1 DESCRIPTION

Plack::Middleware::Antibot::Static checks if a static-like file was fetched.

=head2 Options

=head3 B<score>

Filter's score when bot detected. C<0.9> by default.

=head3 B<session_name>

Session name. C<antibot_static> by default.

=head3 B<timeout>

Expiration timeout in seconds. C<15 * 60> by default (15 minutes).

=cut
