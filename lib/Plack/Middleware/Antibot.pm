package Plack::Middleware::Antibot;

use strict;
use warnings;

use parent 'Plack::Middleware';

our $VERSION = "0.01";

use List::Util qw(sum reduce);
use Plack::Util::Accessor qw(filters fall_through max_score);

sub prepare_app {
    my $self = shift;

    $self->{max_score} ||= 0.8;

    my $filters_names = $self->filters;

    my @filters;
    foreach my $filter (@$filters_names) {
        my @args;
        if (ref $filter eq 'ARRAY') {
            my $ref = $filter;
            $filter = shift @$ref;
            @args   = @$ref;
        }

        my $filter_class = __PACKAGE__ . '::' . $filter;
        my $filter_module = join('/', split(/::/, $filter_class)) . '.pm';

        eval { require $filter_module } or die $@;

        push @filters, $filter_class->new(@args);
    }

    $self->filters(\@filters);

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my @scores;
    my $current_score = 0;
    foreach my $filter (@{$self->filters}) {
        my $res = $filter->execute($env);
        return $res if $res && ref $res eq 'ARRAY';

        my $name = (split /::/, ref $filter)[-1];
        my $key = 'antibot.' . lc($name) . '.detected';

        if ($env->{$key}) {
            push @scores, $filter->score;

            if (@scores > 1) {
                my $p = sum @scores;
                my $q = reduce { $a * $b } @scores;

                $current_score = $p - $q;
            }
            else {
                $current_score = $filter->score;
            }
        }

        last if $current_score >= $self->max_score;
    }

    $env->{'antibot.score'} = $current_score;

    if ($current_score >= $self->max_score) {
        if ($self->fall_through) {
            $env->{'antibot.detected'} = 1;
        }
        else {
            return [400, [], ['Bad request']];
        }
    }

    return $self->app->($env);
}

1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::Antibot - Prevent bots from submitting forms

=head1 SYNOPSIS

    use Plack::Builder;

    my $app = { ... };

    builder {
        enable 'Antibot', filters => [qw/FakeField TooFast/];
        $app;
    };

=head1 DESCRIPTION

Plack::Middleware::Antibot is a L<Plack> middleware that prevents bots from
submitting forms. Every filter implements its own checks, so see their
documentation.

=head2 C<$env>

Some filters set additional C<$env> keys all prefixed with C<antibot.>. For
example C<TextCaptcha> filter sets C<antibot.text_captcha> to be shown to the
user.

=head2 Options

=head3 B<filters>

    enable 'Antibot', filters => ['FakeField'];

To specify filter arguments instead of a filter name pass an array references:

    enable 'Antibot', filters => [['FakeField', field_name => 'my_fake_field']];

=head3 B<fall_through>

    enable 'Antibot', filters => ['FakeField'], fall_through => 1;

Sometimes it is needed to process detected bot yourself. This way in case of
detection C<$env>'s key C<antibot.detected> will be set to appropriate filter.

=head2 Available filters

=over

=item L<Plack::Middleware::Antibot::FakeField> (requires L<Plack::Session>)

Check if an invisible or hidden field is submitted.

=item L<Plack::Middleware::Antibot::Static> (requires L<Plack::Session>)

Check if a static file was fetched before form submission.

=item L<Plack::Middleware::Antibot::TextCaptcha> (requires L<Plack::Session>)

Check if correct random text captcha is submitted.

=item L<Plack::Middleware::Antibot::TooFast>

Check if form is submitted too fast.

=item L<Plack::Middleware::Antibot::TooSlow>

Check if form is submitted too slow.

=back

=head1 LICENSE

Copyright (C) vti.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

vti E<lt>viacheslav.t@gmail.comE<gt>

=cut

