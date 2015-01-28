package Plack::Middleware::Antibot::FakeField;

use strict;
use warnings;

use parent 'Plack::Middleware::Antibot::FilterBase';

use Plack::Request;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{field_name} = $params{field_name} || 'antibot_fake_field';
    $self->{score}      = $params{score}      || 0.8;

    return $self;
}

sub execute {
    my $self = shift;
    my ($env) = @_;

    if ($env->{REQUEST_METHOD} eq 'POST') {
        if (defined Plack::Request->new($env)->param($self->{field_name})) {
            $env->{'antibot.fakefield.detected'}++;
        }
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Antibot::FakeField - Check if fake field was submitted

=head1 SYNOPSIS

    enable 'Antibot', filters => ['FakeField'];

=head1 DESCRIPTION

Plack::Middleware::Antibot::FakeField checks if a fake field was submitted. The
field with specified name has to be present on a form, but should be invisible
to user. This can be achieved either by CSS or by JavaScript.

    <input name="antibot_fake_field" style="display:none" />

It is better to name the field to something that makes sense but doesn't clash
with other fields.

=head2 Options

=head3 B<field_name>

Field name. C<antibot_fake_field> by default.

=cut
