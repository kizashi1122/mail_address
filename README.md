# MailAddress [![Test](https://github.com/kizashi1122/mail_address/actions/workflows/test.yml/badge.svg)](https://github.com/kizashi1122/mail_address/actions/workflows/test.yml) [![Coverage Status](https://coveralls.io/repos/github/kizashi1122/mail_address/badge.svg?branch=master)](https://coveralls.io/github/kizashi1122/mail_address?branch=master)

MailAddress is a Ruby port of Perl's [Mail::Address](http://search.cpan.org/~markov/MailTools-2.14/lib/Mail/Address.pod), a widely used email address parser. While the [mail](https://github.com/mikel/mail) gem is excellent, it cannot parse certain email addresses. Mail::Address can conveniently parse even non-RFC-compliant email addresses such as:

```rb
# mail gem cannot parse the following addresses
Ello [Do Not Reply] <do-not-reply@ello.co> # [, ] are not permitted according to RFC5322
大阪 太郎<osaka@example.com> # no whitespace just before `<`
```
However, Mail::Address (Perl) has some limitations that MailAddress addresses:

- Fails to parse correctly when the name part has no closing parenthesis.
- Over-modifies the name part.

Many people copy and paste email addresses from Excel or other spreadsheets, where addresses are separated by whitespace (tab or space). To handle this, MailAddress also includes a parser ported from the [Google Closure Library](https://github.com/google/closure-library/blob/master/closure/goog/format/emailaddress.js).

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

The API is almost the same as Mail::Address (Perl).
Note that the `comment` property was removed from the address class in v1.0.0, since most users are unlikely to need it.

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

`address.name` and `address.phrase` are almost the same.
`address.phrase` keeps outermost double quotes or parentheses.

If you only need a single address, you can use `parse_first`.

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

1. Fork it ( https://github.com/kizashi1122/mail_address/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
