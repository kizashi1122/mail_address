# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pp'

#
# These tests are almost ports of the following test code:
#
# https://github.com/google/closure-library/blob/master/closure/goog/format/emailaddress_test.js
#

describe MailAddress do

  def assert_parsed_list(input, expected_list, opt_message = nil)
    result = MailAddress.parse_simple input
    expect(result.size).to eq(expected_list.size)
    expected_list.each_with_index do |expected, index|
      expect(result[index].address).to eq(expected)
    end
    result
  end

  it 'notrious docomo address' do
    assert_parsed_list( 'test..test@docomo.ne.jp',  ['test..test@docomo.ne.jp'] )
    assert_parsed_list( 'test.test.@docomo.ne.jp',  ['test.test.@docomo.ne.jp'] )
    assert_parsed_list( 'test..test.@docomo.ne.jp', ['test..test.@docomo.ne.jp'] )
  end

  it "simple parser - empty address" do
    assert_parsed_list( '', [] )
    assert_parsed_list( ',,', [] )
  end

  it "simple parser - single address" do
    assert_parsed_list( '<foo@gmail.com>',   ['foo@gmail.com'] )
    assert_parsed_list( '<foo@gmail.com>,',  ['foo@gmail.com'] )
    assert_parsed_list( '<foo@gmail.com>, ', ['foo@gmail.com'] )
    assert_parsed_list( ',<foo@gmail.com>',  ['foo@gmail.com'] )
    assert_parsed_list( ' ,<foo@gmail.com>', ['foo@gmail.com'] )
  end

  it "simple parser - single address" do
    assert_parsed_list( '<foo@gmail.com>, <bar@gmail.com>',   ['foo@gmail.com', 'bar@gmail.com'] )
    assert_parsed_list( '<foo@gmail.com>, <bar@gmail.com>,',   ['foo@gmail.com', 'bar@gmail.com'] )
    assert_parsed_list( '<foo@gmail.com>, <bar@gmail.com>, ',   ['foo@gmail.com', 'bar@gmail.com'] )
    assert_parsed_list(
      'John Doe <john@gmail.com>; Jane Doe <jane@gmail.com>, <jerry@gmail.com>',
      ['john@gmail.com', 'jane@gmail.com', 'jerry@gmail.com']
      )
    assert_parsed_list(
      'aaa@gmail.com, "bbb@gmail.com", <ccc@gmail.com>, (ddd@gmail.com), [eee@gmail.com]',
      ['aaa@gmail.com', nil, 'ccc@gmail.com', nil, nil],
      )
  end

  it "testparseListWithQuotedSpecialChars" do
    # res = assert_parsed_list(
    #   'a\\"b\\"c <d@e.f>,"g\\"h\\"i\\\\" <j@k.l>',
    #   ['d@e.f', 'j@k.l']
    #   )
    # expect(res[0].phrase).to eq('a"b"c')
    # expect(res[1].phrase).to eq('g"h"i\\')
  end

  it "testparseListWithCommaInLocalPart" do
    res = assert_parsed_list(
      '"Doe, John" <doe.john@gmail.com>, <someone@gmail.com>, "あいうえお" <abc@example.com>, かき くけこ <xyz@example.com>',
      ['doe.john@gmail.com', 'someone@gmail.com', 'abc@example.com', 'xyz@example.com'])
    expect(res[0].name).to eq('Doe, John')
    expect(res[1].name).to be_nil
    expect(res[2].name).to eq('あいうえお')
    expect(res[3].name).to eq('かき くけこ')
    expect(res[2].format).to eq('"あいうえお" <abc@example.com>')
    expect(res[2].original).to eq('"あいうえお" <abc@example.com>')
  end

  it "testparseListWithWhitespaceSeparatedEmails" do
    res = assert_parsed_list(
      'a@b.com abc <c@d.com> e@f.com "G H" <g@h.com> i@j.com',
      ['a@b.com', 'c@d.com', 'e@f.com', 'g@h.com', 'i@j.com']);
    expect(res[3].name).to eq('G H')
    expect(res[1].original).to eq('abc <c@d.com>')
    expect(res[1].format).to eq('abc <c@d.com>')
    expect(res[3].original).to eq('"G H" <g@h.com>')
    expect(res[3].format).to eq('G H <g@h.com>')
  end

  it "testparseListSystemNewlines" do
    # These Windows newlines can be inserted in IE8, or copied-and-pasted from
    # bad data on a Mac, as seen in bug 11081852.
    assert_parsed_list("a@b.com\r\nc@d.com", ['a@b.com', 'c@d.com'],
      'Failed to parse Windows newlines');
    assert_parsed_list("a@b.com\nc@d.com", ['a@b.com', 'c@d.com'],
      'Failed to parse *nix newlines');
    assert_parsed_list("a@b.com\n\rc@d.com", ['a@b.com', 'c@d.com'],
      'Failed to parse obsolete newlines');
    assert_parsed_list("a@b.com\rc@d.com", ['a@b.com', 'c@d.com'],
      'Failed to parse pre-OS X Mac newlines');
  end

end
