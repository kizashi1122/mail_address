# MailAddress [![Build Status](https://travis-ci.org/kizashi1122/mail_address.svg)](https://travis-ci.org/kizashi1122/mail_address) [![Coverage Status](https://coveralls.io/repos/kizashi1122/mail_address/badge.png)](https://coveralls.io/r/kizashi1122/mail_address)

MailAddress is a simple email address parser.
This library is implemented based on Perl Module Mail::Address.

[mail](https://github.com/mikel/mail) is a great gem library. But some email addresses (mostly are violated RFC) are unparsable with mail gem which is strictly RFC compliant. In perl, [Mail::Address](http://search.cpan.org/~markov/MailTools-2.14/lib/Mail/Address.pod) is a very common library to parse email address. Mail::Address conviniently can parse even RFC-violated email addresses such as:

```rb
# mail gem cannot parse the following addresses
Ello [Do Not Reply] <do-not-reply@ello.co> # [, ] are not permitted according to RFC5322
大阪 太郎<osaka@example.com> # no whitespace just before <
```

So I straightforwardly converted Perl module Mail::Address to Ruby gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_address'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mail_address

## Usage

It's almost the same as Mail::Address(Perl).

```rb
require 'mail_address'

addrs = MailAddress.parse(line)

addrs.each do |addr|
  p addr.format
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mail_address/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
