# NAME

Plack::Middleware::Antibot - Prevent bots from submitting forms

# SYNOPSIS

    use Plack::Builder;

    my $app = { ... };

    builder {
        enable 'Antibot', filters => [qw/FakeField TooFast/];
        $app;
    };

# DESCRIPTION

Plack::Middleware::Antibot is a [Plack](https://metacpan.org/pod/Plack) middleware that prevents bots from
submitting forms. Every filter implements its own checks, so see their
documentation.

## `$env`

Some filters set additional `$env` keys all prefixed with `antibot.`. For
example `TextCaptcha` filter sets `antibot.text_captcha` to be shown to the
user.

## Options

### **filters**

    enable 'Antibot', filters => ['FakeField'];

To specify filter arguments instead of a filter name pass an array references:

    enable 'Antibot', filters => [['FakeField', field_name => 'my_fake_field']];

### **fall\_through**

    enable 'Antibot', filters => ['FakeField'], fall_through => 1;

Sometimes it is needed to process detected bot yourself. This way in case of
detection `$env`'s key `antibot.detected` will be set to appropriate filter.

## Available filters

- [Plack::Middleware::Antibot::FakeField](https://metacpan.org/pod/Plack::Middleware::Antibot::FakeField) (requires [Plack::Session](https://metacpan.org/pod/Plack::Session))

    Check if an invisible or hidden field is submitted.

- [Plack::Middleware::Antibot::TextCaptcha](https://metacpan.org/pod/Plack::Middleware::Antibot::TextCaptcha) (requires [Plack::Session](https://metacpan.org/pod/Plack::Session))

    Check if correct random text captcha is submitted.

- [Plack::Middleware::Antibot::TooFast](https://metacpan.org/pod/Plack::Middleware::Antibot::TooFast)

    Check if form is submitted too fast.

- [Plack::Middleware::Antibot::TooSlow](https://metacpan.org/pod/Plack::Middleware::Antibot::TooSlow)

    Check if form is submitted too slow.

# LICENSE

Copyright (C) vti.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

vti <viacheslav.t@gmail.com>
