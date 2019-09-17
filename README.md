# MailAddress [![Build Status](https://travis-ci.org/kizashi1122/mail_address.svg)](https://travis-ci.org/kizashi1122/mail_address) [![Coverage Status](https://coveralls.io/repos/kizashi1122/mail_address/badge.png)](https://coveralls.io/r/kizashi1122/mail_address) [![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/kizashi1122/mail_address/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/kizashi1122/mail_address/?branch=master)

MailAddress is a port of Mail::Address from Perl.

[mail](https://github.com/mikel/mail) is a great gem library. But some email addresses are unparsable with it. In perl, [Mail::Address](http://search.cpan.org/~markov/MailTools-2.14/lib/Mail/Address.pod) is a very common library to parse email addresses. Mail::Address conviniently can parse even non-RFC-compliant email addresses such as:

```rb
# mail gem cannot parse the following addresses
Ello [Do Not Reply] <do-not-reply@ello.co> # [, ] are not permitted according to RFC5322
大阪 太郎<osaka@example.com> # no whitespace just before `<`
```
But Mail::Address(Perl) has some bad points (below). These are fixed in MailAddress.

- if no ending parenthesis in name part, cannot parse correctly.
- Modifications of name part are too much.

Many people copy and paste email addresses from Excel or the other spreadsheets. In this case, addresses are separated by whitespace(tab or space). To enable to parse this, also ported from a parser part of [Google Closure Library](https://github.com/google/closure-library/blob/master/closure/goog/format/emailaddress.js).

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
p addrs[0].original   # "John 'M' Doe <john@example.com> (this is a comment)"

p addrs[1].format     # "\"大阪 太郎\" <osaka@example.jp>"
p addrs[1].address    # "osaka@example.jp"
p addrs[1].name       # "大阪 太郎"
p addrs[1].phrase     # "大阪 太郎"
p addrs[1].host       # "example.jp"
p addrs[1].user       # "osaka"
p addrs[1].original   # "大阪 太郎 <osaka@example.jp>"
```

`address.name` and `address.phrase` are almost same.
`address.phrase` keeps outermost double quotes or parentheses.

if you specify single email address, you can use `parse_first`.

```rb
line = "John Doe <john@example.com>"
addr = MailAddress.parse_first(line)

p addr.address # "john@example.com"
```

### Parse addresses separated with whitespace

```rb
require 'mail_address'

line = "John Doe <john@example.com> second@example.com, third@example.com" # separated with space and comma
addrs = MailAddress.parse_simple(line)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/mail_address/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
