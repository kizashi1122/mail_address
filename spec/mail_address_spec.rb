# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pp'

describe MailAddress do

  it "normal case (commonly used)" do
    # address only
    line = 'johndoe@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # <address> only
    line = '<johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # name + <address> (single byte only)
    line = 'John Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('John Doe <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('John Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # name + <address> (multi byte)
    line = 'ジョン ドゥ <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"ジョン ドゥ" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('ジョン ドゥ')
    expect(results[0].phrase).to eq('ジョン ドゥ')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    line = 'Amazon.co.jp アソシエイト・プログラム <associates@amazon.co.jp>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"Amazon.co.jp アソシエイト・プログラム" <associates@amazon.co.jp>')
    expect(results[0].address).to eq('associates@amazon.co.jp')
    expect(results[0].name).to eq('Amazon.co.jp アソシエイト・プログラム')
    expect(results[0].phrase).to eq('Amazon.co.jp アソシエイト・プログラム')
    expect(results[0].host).to eq('amazon.co.jp')
    expect(results[0].user).to eq('associates')
    expect(results[0].original).to eq(line)

    # name (includes parens) + <address>
    line = 'Example (Twitterより) <notify@twitter.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"Example (Twitterより)" <notify@twitter.com>')
    expect(results[0].address).to eq('notify@twitter.com')
    expect(results[0].name).to eq('Example (Twitterより)')
    expect(results[0].phrase).to eq('Example (Twitterより)')
    expect(results[0].host).to eq('twitter.com')
    expect(results[0].user).to eq('notify')
    expect(results[0].original).to eq(line)

    # name + <address> (multi byte) name is quoted
    line = '"ジョン ドゥ" <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"ジョン ドゥ" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('ジョン ドゥ')
    expect(results[0].phrase).to eq('"ジョン ドゥ"')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # address + (note)
    line = 'johndoe@example.com (John Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('(John Doe)')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # address + (note) # nested paren
    line = 'johndoe@example.com (John (Mid) Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John (Mid) Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John (Mid) Doe')
    expect(results[0].phrase).to eq('(John (Mid) Doe)')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # address + (note) # note has special char
    line = 'johndoe@example.com (John@Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John@Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John@Doe')
    expect(results[0].phrase).to eq('(John@Doe)')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    line = 'johndoe@example.com (John, Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John, Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John, Doe')
    expect(results[0].phrase).to eq('(John, Doe)')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # name + <address> + (note)
    line = 'John Doe <johndoe@example.com> (Extra)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John Doe (Extra)" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John Doe (Extra)')
    expect(results[0].phrase).to eq('John Doe (Extra)')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # name + <address> (name has starting paren but doesn't have ending paren)
    line = 'John(Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John(Doe" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John(Doe')
    expect(results[0].phrase).to eq('John(Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # ditto
    line = 'John ( Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John ( Doe" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('John ( Doe')
    expect(results[0].phrase).to eq('John ( Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)

    # "address1" <address2>
    line = '"michael@example.jp" <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"michael@example.jp" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq('michael@example.jp')
    expect(results[0].phrase).to eq('"michael@example.jp"')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe')
    expect(results[0].original).to eq(line)
  end

  it "normal case (multiple address)" do
    line = "John 'M' Doe <john@example.com>, 大阪 太郎 <osaka@example.jp>, localpartonly"
    results = MailAddress.parse(line)

    expect(results[0].format).to eq("John 'M' Doe <john@example.com>")
    expect(results[0].address).to eq("john@example.com")
    expect(results[0].name).to eq("John 'M' Doe")
    expect(results[0].phrase).to eq("John 'M' Doe")
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('john')
    expect(results[0].original).to eq("John 'M' Doe <john@example.com>")

    # Perl module Mail::Address returns '大阪 太郎 <osaka@example.jp>' (no double quote)
    # because regular expression \w matches even multibyte characters.
    expect(results[1].format).to eq('"大阪 太郎" <osaka@example.jp>')
    expect(results[1].address).to eq('osaka@example.jp')
    expect(results[1].name).to eq('大阪 太郎')
    expect(results[1].phrase).to eq('大阪 太郎')
    expect(results[1].host).to eq('example.jp')
    expect(results[1].user).to eq('osaka')
    expect(results[1].original).to eq('大阪 太郎 <osaka@example.jp>')

    expect(results[2].format).to  eq('localpartonly')
    expect(results[2].address).to be_nil
    expect(results[2].name).to    eq('localpartonly')
    expect(results[2].phrase).to  eq('localpartonly')
    expect(results[2].host).to    be_nil
    expect(results[2].user).to    eq('')
    expect(results[2].original).to eq('localpartonly')
  end

  it "normal case (rfc-violated(RFC822) but commonly used in AU/DoCoMo)" do
    # dot before @
    line = 'johndoe.@example.com' # no double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('johndoe.@example.com')
    expect(results[0].address).to eq('johndoe.@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe.')
    expect(results[0].original).to eq(line)

    line = '"johndoe."@example.com' # enclosed with double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('"johndoe."@example.com')
    expect(results[0].address).to eq('"johndoe."@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('"johndoe."')
    expect(results[0].original).to eq(line)

    line = 'John Doe <johndoe.@example.com>' # no double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <johndoe.@example.com>')
    expect(results[0].address).to eq('johndoe.@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('John Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('johndoe.')
    expect(results[0].original).to eq(line)

    line = 'John Doe <"johndoe."@example.com>' # enclosed with double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <"johndoe."@example.com>')
    expect(results[0].address).to eq('"johndoe."@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('John Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('"johndoe."')
    expect(results[0].original).to eq(line)

    # contains '..'
    line = 'john..doe@example.com'  # enclosed with double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('john..doe@example.com')
    expect(results[0].address).to eq('john..doe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('john..doe')
    expect(results[0].original).to eq(line)

    line = '"john..doe"@example.com'  # enclosed with double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('"john..doe"@example.com')
    expect(results[0].address).to eq('"john..doe"@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('"john..doe"')
    expect(results[0].original).to eq(line)

    line = 'John Doe <john..doe@example.com>' # no double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <john..doe@example.com>')
    expect(results[0].address).to eq('john..doe@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('John Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('john..doe')
    expect(results[0].original).to eq(line)

    line = 'John Doe <"john..doe"@example.com>'  # enclosed with double quotes
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <"john..doe"@example.com>')
    expect(results[0].address).to eq('"john..doe"@example.com')
    expect(results[0].name).to eq('John Doe')
    expect(results[0].phrase).to eq('John Doe')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('"john..doe"')
    expect(results[0].original).to eq(line)
  end

  it "Unclosed double quotes" do
    line = '"john..doe@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"john..doe@example.com')
    expect(results[0].address).to be_nil
    expect(results[0].name).to eq('john..doe@example.com')    ## IRREGULAR PATTERN
    expect(results[0].phrase).to eq('"john..doe@example.com') ## IRREGULAR PATTERN
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq("")
    expect(results[0].original).to eq(line)

    line = 'john..doe"@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('john..doe"@example.com')
    expect(results[0].address).to be_nil
    expect(results[0].name).to eq('john..doe"@example.com')    ## IRREGULAR PATTERN
    expect(results[0].phrase).to eq('john..doe"@example.com') ## IRREGULAR PATTERN
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq("")
    expect(results[0].original).to eq(line)

    #
    # it takes about 1 minutes in v1.4.5
    #
    line = '"ooooooooooooooooo@docomo.ne.jp'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"ooooooooooooooooo@docomo.ne.jp')
    expect(results[0].address).to be_nil
    expect(results[0].name).to eq('ooooooooooooooooo@docomo.ne.jp')    ## IRREGULAR PATTERN
    expect(results[0].phrase).to eq('"ooooooooooooooooo@docomo.ne.jp') ## IRREGULAR PATTERN
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq("")
    expect(results[0].original).to eq(line)
  end

  it "unparsable with mail gem (includes non-permitted char'[')" do
    line = "Ello [Do Not Reply] <do-not-reply@ello.co>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq('"Ello [Do Not Reply]" <do-not-reply@ello.co>')
    expect(results[0].address).to eq('do-not-reply@ello.co')
    expect(results[0].name).to    eq('Ello')
    expect(results[0].phrase).to  eq('Ello [Do Not Reply]')
    expect(results[0].host).to    eq('ello.co')
    expect(results[0].user).to    eq('do-not-reply')
    expect(results[0].original).to eq(line)
  end

  it "unparsable with mail gem (no whitespace before <)" do
    line = "大阪 太郎<osaka@example.jp>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq('"大阪 太郎" <osaka@example.jp>')
    expect(results[0].address).to eq('osaka@example.jp')
    expect(results[0].name).to    eq('大阪 太郎')
    expect(results[0].phrase).to  eq('大阪 太郎')
    expect(results[0].host).to    eq('example.jp')
    expect(results[0].user).to    eq('osaka')
    expect(results[0].original).to eq(line)
  end

  it "local part only(treated as invalid)" do
    # if local part only, do not treat as an email address
    line = "localpartonly"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq('localpartonly')
    expect(results[0].address).to be_nil
    expect(results[0].name).to    eq('localpartonly')
    expect(results[0].phrase).to  eq('localpartonly')
    expect(results[0].host).to    be_nil
    expect(results[0].user).to    eq('')
    expect(results[0].original).to eq(line)
  end

  it "includes invalid addresses only among valid addresses " do
    line = "aaaa, xyz@example.com, bbbb"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq('aaaa')
    expect(results[0].address).to be_nil
    expect(results[0].name).to    eq('aaaa')
    expect(results[0].phrase).to  eq('aaaa')
    expect(results[0].host).to    be_nil
    expect(results[0].user).to    eq('')
    expect(results[0].original).to eq('aaaa')
    expect(results[1].format).to  eq('xyz@example.com')
    expect(results[1].address).to eq('xyz@example.com')
    expect(results[1].name).to    be_nil
    expect(results[1].phrase).to  eq('')
    expect(results[1].host).to    eq('example.com')
    expect(results[1].user).to    eq('xyz')
    expect(results[1].original).to eq('xyz@example.com')
    expect(results[2].format).to  eq('bbbb')
    expect(results[2].address).to be_nil
    expect(results[2].name).to    eq('bbbb')
    expect(results[2].phrase).to  eq('bbbb')
    expect(results[2].host).to    be_nil
    expect(results[2].user).to    eq('')
    expect(results[2].original).to eq('bbbb')
  end

  it "a lot of types of undisclosed recipients" do
    array = [
      'undisclosed-recipients: ;',
      'undisclosed-recipients:;',
      'undisclosed recipients: ;',
      'Undisclosed recipients: ;',
      'Undisclosed recipients:;',
      'Undisclosed-recipients: ;',
      'Undisclosed-recipients:;',
    ]

    array.each do |line|
      results = MailAddress.parse(line)
      expect(results[0].format).to eq(line)
      expect(results[0].address).to be_nil
      expect(results[0].name).to    eq(line)
      expect(results[0].phrase).to  eq(line)
      expect(results[0].host).to    be_nil
      expect(results[0].user).to    eq('')
      expect(results[0].original).to eq(line)
    end

    array = [
      '<"Undisclosed-Recipient:;"@587.jah.ne.jp>',
      '<"Undisclosed-Recipient:"@nifty.com;>',
    ]

    array.each do |line|
      results = MailAddress.parse(line)
      expect(results[0].format).to  eq(line)
      expect(results[0].address).to be_nil
      expect(results[0].name).to    eq(line)
      expect(results[0].phrase).to  eq(line)
      expect(results[0].host).to    be_nil
      expect(results[0].user).to    eq('')
      expect(results[0].original).to eq(line)
    end

    # a seemingly valid address
    # line = '"Undisclosed" <"recipients:"@nifty.com>'
    # results = MailAddress.parse(line)
    # expect(results[0].format).to  eq(line)
    # expect(results[0].address).to eq('"recipients:"@nifty.com')
    # expect(results[0].name).to    eq("Undisclosed")
    # expect(results[0].phrase).to  eq('"Undisclosed"')
    # expect(results[0].host).to    eq("nifty.com")
    # expect(results[0].user).to    eq('"recipients:"')
    # expect(results[0].original).to eq(line)
  end

  it "specify mime-encoded address" do
    line = "=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?= <osaka@example.jp>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq('=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?= <osaka@example.jp>')
    expect(results[0].address).to eq('osaka@example.jp')
    expect(results[0].name).to    be_nil
    expect(results[0].phrase).to  eq('=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?=')
    expect(results[0].host).to    eq('example.jp')
    expect(results[0].user).to    eq('osaka')
    expect(results[0].original).to eq(line)
  end

  it "obviously invalid address (has no '@')" do
    array = [
      'recipient list not shown: ;',
      '各位:;'
    ]

    array.each do |line|
      results = MailAddress.parse(line)
      line.gsub!(';', '')
      expect(results[0].format).to  eq(line)
      expect(results[0].address).to be_nil
      expect(results[0].name).to    eq(line.strip)
      expect(results[0].phrase).to  eq(line)
      expect(results[0].host).to    be_nil
      expect(results[0].user).to    eq('')
      expect(results[0].original).to eq(line)
    end
  end

  it "all are invalid" do
    line = 'aa aa, bb (bb), cccc'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('aa aa')
    expect(results[0].address).to be_nil
    expect(results[0].name).to eq('aa aa')
    expect(results[0].phrase).to eq('aa aa')
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq('')
    expect(results[0].original).to eq('aa aa')
    expect(results[1].format).to eq('bb (bb)')
    expect(results[1].address).to be_nil
    expect(results[1].name).to eq('bb (bb)')
    expect(results[1].phrase).to eq('bb (bb)')
    expect(results[1].host).to be_nil
    expect(results[1].user).to eq('')
    expect(results[1].original).to eq('bb (bb)')
    expect(results[2].format).to eq('cccc')
    expect(results[2].address).to be_nil
    expect(results[2].name).to eq('cccc')
    expect(results[2].phrase).to eq('cccc')
    expect(results[2].host).to be_nil
    expect(results[2].user).to eq('')
    expect(results[2].original).to eq('cccc')
  end

  it "empty string or nil" do
    # empty string
    line = ''
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('')
    expect(results[0].address).to be_nil
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq('')
    expect(results[0].original).to eq(line)
    # nil
    line = nil
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('')
    expect(results[0].address).to be_nil
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq('')
    expect(results[0].original).to eq('') # Note that it returns empty string NOT nil
  end

  it "suppress too much extraction" do
    line = 'john_doe@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('john_doe@example.com')
    expect(results[0].address).to eq('john_doe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('john_doe')
    expect(results[0].original).to eq(line)

    line = 'john.doe@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('john.doe@example.com')
    expect(results[0].address).to eq('john.doe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq('')
    expect(results[0].host).to eq('example.com')
    expect(results[0].user).to eq('john.doe')
    expect(results[0].original).to eq(line)
  end

  it "corrupted address" do
    line = 'john <john@example.com' # lack of right angle bracket
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('john <john@example.com')
    expect(results[0].address).to be_nil
    expect(results[0].name).to eq('john <john@example.com')
    expect(results[0].phrase).to eq('john <john@example.com')
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq('')
    expect(results[0].original).to eq(line)

    line = 'john <john@example.com> (last' # lack of right parenthesis
    expect {
      results = MailAddress.parse(line)
    }.to raise_error(StandardError, 'cannot find end paren')
  end

  it "unbelievable but existed address" do
    line = 'Sf 山田 太郎@example.com, valid@example.com'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('Sf 山田 太郎@example.com')
    expect(results[0].address).not_to eq("Sf@example.com") ## important!
    expect(results[0].address).to be_nil                   ## important!
    expect(results[0].name).to eq('Sf 山田 太郎@example.com')    ## I don't care whatever returns
    expect(results[0].phrase).to eq('Sf 山田 太郎@example.com')  ## I don't care whatever returns
    expect(results[0].host).to be_nil
    expect(results[0].user).to eq('')
    expect(results[0].original).to eq('Sf 山田 太郎@example.com')
  end

  it 'Perl Module TAP test data' do
    data = [
      # [ '"Joe & J. Harvey" <ddd @Org>, JJV @ BBN',
      #   '"Joe & J. Harvey" <ddd@Org>',
      #   'Joe & J. Harvey'],
      # [ '"Joe & J. Harvey" <ddd @Org>',
      #   '"Joe & J. Harvey" <ddd@Org>',
      #   'Joe & J. Harvey'],
      # [ 'JJV @ BBN',
      #   'JJV@BBN',
      #   ''],
      # [ '"spickett@tiac.net" <Sean.Pickett@zork.tiac.net>',
      #   '"spickett@tiac.net" <Sean.Pickett@zork.tiac.net>',
      #   'Spickett@Tiac.Net'],
      # [ 'rls@intgp8.ih.att.com (-Schieve,R.L.)',
      #   'rls@intgp8.ih.att.com (-Schieve,R.L.)',
      #   'R.L. -Schieve'],

      # [ 'bodg fred@tiuk.ti.com', ####  doesn't support this type of email address
      #   'bodg',
      #   ''],

      [ 'm-sterni@mars.dsv.su.se',
        'm-sterni@mars.dsv.su.se',
        ''],
      # [ 'jrh%cup.portal.com@portal.unix.portal.com',
      #   'jrh%cup.portal.com@portal.unix.portal.com',
      #   'Cup Portal Com'],
      # [ "astrachan@austlcm.sps.mot.com ('paul astrachan/xvt3')",
      #   "astrachan@austlcm.sps.mot.com ('paul astrachan/xvt3')",
      #   'Paul Astrachan/Xvt3'],
      # [ 'TWINE57%SDELVB.decnet@SNYBUFVA.CS.SNYBUF.EDU (JAMES R. TWINE - THE NERD)',
      #   'TWINE57%SDELVB.decnet@SNYBUFVA.CS.SNYBUF.EDU (JAMES R. TWINE - THE NERD)',
      #   'James R. Twine - The Nerd'],
      [ 'David Apfelbaum <da0g+@andrew.cmu.edu>',
        'David Apfelbaum <da0g+@andrew.cmu.edu>',
        'David Apfelbaum'],
      # [ '"JAMES R. TWINE - THE NERD" <TWINE57%SDELVB%SNYDELVA.bitnet@CUNYVM.CUNY.EDU>',
      #   '"JAMES R. TWINE - THE NERD" <TWINE57%SDELVB%SNYDELVA.bitnet@CUNYVM.CUNY.EDU>',
      #   'James R. Twine - The Nerd'],
      [ 'bilsby@signal.dra (Fred C. M. Bilsby)',
        'bilsby@signal.dra (Fred C. M. Bilsby)',
        'Fred C. M. Bilsby'],
      # [ '/G=Owen/S=Smith/O=SJ-Research/ADMD=INTERSPAN/C=GB/@mhs-relay.ac.uk', ### not supported
      #   '/G=Owen/S=Smith/O=SJ-Research/ADMD=INTERSPAN/C=GB/@mhs-relay.ac.uk',
      #   'Owen Smith'],
      [ 'apardon@rc1.vub.ac.be (Antoon Pardon)',
        'apardon@rc1.vub.ac.be (Antoon Pardon)',
        'Antoon Pardon'],
      # ['"Stephen Burke, Liverpool" <BURKE@vxdsya.desy.de>',
      #   '"Stephen Burke, Liverpool" <BURKE@vxdsya.desy.de>',
      #   'Stephen Burke'],
      ['Andy Duplain <duplain@btcs.bt.co.uk>',
        'Andy Duplain <duplain@btcs.bt.co.uk>',
        'Andy Duplain'],
      ['Gunnar Zoetl <zoetl@isa.informatik.th-darmstadt.de>',
        'Gunnar Zoetl <zoetl@isa.informatik.th-darmstadt.de>',
        'Gunnar Zoetl'],
      ['The Newcastle Info-Server <info-admin@newcastle.ac.uk>',
        'The Newcastle Info-Server <info-admin@newcastle.ac.uk>',
        'The Newcastle Info-Server'],
      ['wsinda@nl.tue.win.info (Dick Alstein)',
        'wsinda@nl.tue.win.info (Dick Alstein)',
        'Dick Alstein'],
      ['mserv@rusmv1.rus.uni-stuttgart.de (RUS Mail Server)',
        'mserv@rusmv1.rus.uni-stuttgart.de (RUS Mail Server)',
        'RUS Mail Server'],
      ['Suba.Peddada@eng.sun.com (Suba Peddada [CONTRACTOR])',
        'Suba.Peddada@eng.sun.com (Suba Peddada [CONTRACTOR])',
        'Suba Peddada'],
      ['ftpmail-adm@info2.rus.uni-stuttgart.de',
        'ftpmail-adm@info2.rus.uni-stuttgart.de',
        ''],
      # ['Paul Manser (0032 memo) <a906187@tiuk.ti.com>',
      #   'Paul Manser <a906187@tiuk.ti.com> (0032 memo)',
      #   'Paul Manser'],
      # ['"gregg (g.) woodcock" <woodcock@bnr.ca>',
      #   '"gregg (g.) woodcock" <woodcock@bnr.ca>',
      #   'Gregg Woodcock'],
      ['Clive Bittlestone <clyvb@asic.sc.ti.com>',
        'Clive Bittlestone <clyvb@asic.sc.ti.com>',
        'Clive Bittlestone'],
      # ['Graham.Barr@tiuk.ti.com',
      #   'Graham.Barr@tiuk.ti.com',
      #   'Graham Barr'],
      # ['"Graham Bisset, UK Net Support, +44 224 728109"  <GRAHAM@dyce.wireline.slb.com.ti.com.>',
      #   '"Graham Bisset, UK Net Support, +44 224 728109" <GRAHAM@dyce.wireline.slb.com.ti.com.>',
      #   'Graham Bisset'],
      # ['a909937 (Graham Barr          (0004 bodg))',
      #   'a909937 (Graham Barr          (0004 bodg))',
      #   'Graham Barr'],
      # ['a909062@node_cb83.node_cb83 (Colin x Maytum         (0013 bro5))',
      #   'a909062@node_cb83.node_cb83 (Colin x Maytum         (0013 bro5))',
      #   'Colin x Maytum'],
      # ['a909062@node_cb83.node_cb83 (Colin Maytum         (0013 bro5))',
      #   'a909062@node_cb83.node_cb83 (Colin Maytum         (0013 bro5))',
      #   'Colin Maytum'],
      # ['Derek.Roskell%dero@msg.ti.com',
      #   'Derek.Roskell%dero@msg.ti.com',
      #   'Derek Roskell'],
      # ['":sysmail"@ Some-Group. Some-Org, Muhammed.(I am the greatest) Ali @(the)Vegas.WBA',
      #   '":sysmail"@Some-Group.Some-Org',
      #   ''],
      # ["david d `zoo' zuhn <zoo@aggregate.com>",
      #   "david d `zoo' zuhn <zoo@aggregate.com>",
      #   "David D `Zoo' Zuhn"],
      ['"Christopher S. Arthur" <csa@halcyon.com>',
        '"Christopher S. Arthur" <csa@halcyon.com>',
        'Christopher S. Arthur'],
      ['Jeffrey A Law <law@snake.cs.utah.edu>',
        'Jeffrey A Law <law@snake.cs.utah.edu>',
        'Jeffrey A Law'],
      ['lidl@uunet.uu.net (Kurt J. Lidl)',
        'lidl@uunet.uu.net (Kurt J. Lidl)',
        'Kurt J. Lidl'],
      ['Kresten_Thorup@NeXT.COM (Kresten Krab Thorup)',
        'Kresten_Thorup@NeXT.COM (Kresten Krab Thorup)',
        'Kresten Krab Thorup'],
      ['hjl@nynexst.com (H.J. Lu)',
        'hjl@nynexst.com (H.J. Lu)',
        'H.J. Lu'],
      # ['@oleane.net:hugues@afp.com a!b@c.d foo!bar!foobar!root',
      #   '@oleane.net:hugues@afp.com',
      #   'Oleane Net:Hugues'],
#      ['(foo@bar.com (foobar), ned@foo.com (nedfoo) ) <kevin@goess.org>',
#        'kevin@goess.org (foo@bar.com (foobar), ned@foo.com (nedfoo) )',
#        ''],
      ["eBay's Half <half@ebay.com>",
        "eBay's Half <half@ebay.com>",
        "eBay's Half"],
      ['outlook@example.com; semicolons@example.com',
        'outlook@example.com',
        ''],
      ['"Foo; Bar" <both@example.com>, Baz <baz@example.com>',
        '"Foo; Bar" <both@example.com>',
        'Foo; Bar']
    ]

    data.each_with_index do |d, i|
      test_src = d[0]
      exp_format = d[1]
      exp_name = d[2]
#      p "#{i} #{test_src}"
      result = MailAddress.parse(test_src)[0]

      result_format = result.format || ''
      result_name = result.name || ''

      expect(result_name).to eq(exp_name)
      expect(result_format).to eq(exp_format)
   end
  end
end


