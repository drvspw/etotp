## etotp
`etotp` is a library to generate time based one time passwords ([TOTP](http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm)) based on [RFC 6238](https://tools.ietf.org/html/rfc6238).

## Requirements
This library requires atleast OTP 23.

## Usage
```erlang
{deps, [
	{etotp, "<latest release>"}
	]}.
```

If not using `hex.pm`
Add `etotp` as a dependency in `rebar.config`
```erlang
{etotp, {git, "https://github.com/drvspw/etotp.git", {tag, "<latest release>"}}}
```
