# MailAddress [![Build Status](https://travis-ci.org/kizashi1122/mail_address.svg)](https://travis-ci.org/kizashi1122/mail_address) [![Coverage Status](https://coveralls.io/repos/kizashi1122/mail_address/badge.png)](https://coveralls.io/r/kizashi1122/mail_address)

MailAddress is a simple email address parser.
This library is implemented based on Perl Module Mail::Address and added some improvements.

[mail](https://github.com/mikel/mail) is a great gem library. But some email addresses (mostly are violated RFC) are unparsable with mail gem which is strictly RFC compliant. In perl, [Mail::Address](http://search.cpan.org/~markov/MailTools-2.14/lib/Mail/Address.pod) is a very common library to parse email address. Mail::Address conviniently can parse even RFC-violated email addresses such as:

```rb
# mail gem cannot parse the following addresses
Ello [Do Not Reply] <do-not-reply@ello.co> # [, ] are not permitted according to RFC5322
大阪 太郎<osaka@example.com> # no whitespace just before <
```

So I straightforwardly converted Perl module Mail::Address to Ruby gem. Then I reviced it because original Mail::Address also has some bad points. For example:

- if no ending parenthesis in name part, cannot parse correctly.
- Modifications of name part are too much.


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
But in this module, removed `comment` property from address class in version v1.0.0. Most people don't reallize comment I think.

```rb
require 'mail_address'

line = "John 'M' Doe <john@example.com> (this is a comment), 大阪 太郎 <osaka@example.jp>"
addrs = MailAddress.parse(line)

p addrs[0].format     # "\"John 'M' Doe (this is a comment)\" <john@example.com>"
p addrs[0].address    # "john@example.com"
p addrs[0].name       # "John 'M' Doe (this is a comment)"
p addrs[0].phrase     # "John 'M' Doe (this is a comment)"
p addrs[0].host       # "example.com"
p addrs[0].user       # "john"

p addrs[1].format     # "\"大阪 太郎\" <osaka@example.jp>"
p addrs[1].address    # "osaka@example.jp"
p addrs[1].name       # "大阪 太郎"
p addrs[1].phrase     # "大阪 太郎"
p addrs[1].host       # "example.jp"
p addrs[1].user       # "osaka"
```
`address.name` and `address.phrase` are almost same. 
`address.phrase` keeps outermost double quotes or parentheses.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mail_address/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
