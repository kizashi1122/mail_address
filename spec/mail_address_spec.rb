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
    expect(results[0].phrase).to eq("")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # <address> only
    line = '<johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to be_nil
    expect(results[0].phrase).to eq("")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # name + <address> (single byte only)
    line = 'John Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('John Doe <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John Doe")
    expect(results[0].phrase).to eq("John Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # name + <address> (multi byte)
    line = 'ジョン ドゥ <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"ジョン ドゥ" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("ジョン ドゥ")
    expect(results[0].phrase).to eq("ジョン ドゥ")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # name + <address> (multi byte) name is quoted
    line = '"ジョン ドゥ" <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"ジョン ドゥ" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("ジョン ドゥ")
    expect(results[0].phrase).to eq('"ジョン ドゥ"')
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # address + (note)
    line = 'johndoe@example.com (John Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John Doe")
    expect(results[0].phrase).to eq("(John Doe)")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # address + (note) # note has special char
    line = 'johndoe@example.com (John@Doe)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('johndoe@example.com (John@Doe)')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John@Doe")
    expect(results[0].phrase).to eq("(John@Doe)")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # name + <address> + (note)
    line = 'John Doe <johndoe@example.com> (Extra)'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John Doe (Extra)" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John Doe")
    expect(results[0].phrase).to eq("John Doe (Extra)")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # name + <address> (name has starting paren but doesn't have ending paren)
    line = 'John(Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John(Doe" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John(Doe")
    expect(results[0].phrase).to eq("John(Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')

    # ditto
    line = 'John ( Doe <johndoe@example.com>'
    results = MailAddress.parse(line)
    expect(results[0].format).to eq('"John ( Doe" <johndoe@example.com>')
    expect(results[0].address).to eq('johndoe@example.com')
    expect(results[0].name).to eq("John ( Doe")
    expect(results[0].phrase).to eq("John ( Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('johndoe')


    # "address1" <address2>
    # line = '"michael@example.jp" <johndoe@example.com>'
    # results = MailAddress.parse(line)
    # expect(results[0].format).to eq('"michael@example.jp" <johndoe@example.com>')
    # expect(results[0].address).to eq('johndoe@example.com')
    # expect(results[0].name).to eq("michael@example.jp")
    # expect(results[0].phrase).to eq("michael@example.jp")
    # expect(results[0].host).to eq("example.com")
    # expect(results[0].user).to eq('johndoe')
  end

  it "normal case (multiple address)" do
    line = "John 'M' Doe <john@example.com>, 大阪 太郎 <osaka@example.jp>"
    results = MailAddress.parse(line)

    expect(results[0].format).to eq("John 'M' Doe <john@example.com>")
    expect(results[0].address).to eq("john@example.com")
    expect(results[0].name).to eq("John 'M' Doe")
#    expect(results[0].comment).to eq("(this is a comment)")
    expect(results[0].phrase).to eq("John 'M' Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq("john")

    # Perl module Mail::Address returns '大阪 太郎 <osaka@example.jp>' (no double quote)
    # because regular expression \w matches even multibyte characters.
    expect(results[1].format).to eq("\"大阪 太郎\" <osaka@example.jp>")
    expect(results[1].address).to eq("osaka@example.jp")
    expect(results[1].name).to eq("大阪 太郎")
#    expect(results[1].comment).to eq("")
    expect(results[1].phrase).to eq("大阪 太郎")
    expect(results[1].host).to eq("example.jp")
    expect(results[1].user).to eq("osaka")
  end

  it "normal case (rfc-violated(RFC822) but commonly used in AU/DoCoMo)" do
    # dot before @
    line = 'John Doe <"johndoe."@example.com>'
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <"johndoe."@example.com>')
    expect(results[0].address).to eq('"johndoe."@example.com')
    expect(results[0].name).to eq("John Doe")
    expect(results[0].phrase).to eq("John Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('"johndoe."')

    # contains '..'
    line = 'John Doe <"john..doe"@example.com>'
    results = MailAddress.parse(line)

    expect(results[0].format).to eq('John Doe <"john..doe"@example.com>')
    expect(results[0].address).to eq('"john..doe"@example.com')
    expect(results[0].name).to eq("John Doe")
    expect(results[0].phrase).to eq("John Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq('"john..doe"')
  end

  it "unparsable with mail gem (includes non-permitted char'[')" do
    line = "Ello [Do Not Reply] <do-not-reply@ello.co>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("\"Ello [Do Not Reply]\" <do-not-reply@ello.co>")
    expect(results[0].address).to eq("do-not-reply@ello.co")
    expect(results[0].name).to    eq("Ello")
    expect(results[0].phrase).to  eq("Ello [Do Not Reply]")
    expect(results[0].comment).to eq("")
    expect(results[0].host).to    eq("ello.co")
    expect(results[0].user).to    eq("do-not-reply")
  end

  it "unparsable with mail gem (no whitespace before <)" do
    line = "大阪 太郎<osaka@example.jp>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("\"大阪 太郎\" <osaka@example.jp>")
    expect(results[0].address).to eq("osaka@example.jp")
    expect(results[0].name).to    eq("大阪 太郎")
#    expect(results[0].comment).to eq("")
    expect(results[0].phrase).to  eq("大阪 太郎")
    expect(results[0].host).to    eq("example.jp")
    expect(results[0].user).to    eq("osaka")
  end

  it "no address" do
    line = "localpartonly"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("localpartonly")
    expect(results[0].address).to eq("localpartonly")
    expect(results[0].name).to    be_nil
    expect(results[0].comment).to eq("")
    expect(results[0].phrase).to  eq("")
    expect(results[0].host).to    be_nil
    expect(results[0].user).to    eq("localpartonly")
  end

  it "specify mime-encoded address" do
    line = "=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?= <osaka@example.jp>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?= <osaka@example.jp>")
    expect(results[0].address).to eq("osaka@example.jp")
    expect(results[0].name).to    be_nil
    expect(results[0].comment).to eq("")
    expect(results[0].phrase).to  eq("=?ISO-2022-JP?B?GyRCQmc6ZRsoQiAbJEJCQE86GyhC?=")
    expect(results[0].host).to    eq("example.jp")
    expect(results[0].user).to    eq("osaka")
  end

  xit 'Perl Module Pod test data' do
    data = [
      [ '"Joe & J. Harvey" <ddd @Org>, JJV @ BBN',
        '"Joe & J. Harvey" <ddd@Org>',
        'Joe & J. Harvey'],
      [ '"Joe & J. Harvey" <ddd @Org>',
        '"Joe & J. Harvey" <ddd@Org>',
        'Joe & J. Harvey'],
      [ 'JJV @ BBN',
        'JJV@BBN',
        ''],
      [ '"spickett@tiac.net" <Sean.Pickett@zork.tiac.net>',
        '"spickett@tiac.net" <Sean.Pickett@zork.tiac.net>',
        'Spickett@Tiac.Net'],
      [ 'rls@intgp8.ih.att.com (-Schieve,R.L.)',
        'rls@intgp8.ih.att.com (-Schieve,R.L.)',
        'R.L. -Schieve'],
      [ 'bodg fred@tiuk.ti.com',
        'bodg',
        ''],
      [ 'm-sterni@mars.dsv.su.se',
        'm-sterni@mars.dsv.su.se',
        ''],
      [ 'jrh%cup.portal.com@portal.unix.portal.com',
        'jrh%cup.portal.com@portal.unix.portal.com',
        'Cup Portal Com'],
      [ "astrachan@austlcm.sps.mot.com ('paul astrachan/xvt3')",
        "astrachan@austlcm.sps.mot.com ('paul astrachan/xvt3')",
        'Paul Astrachan/Xvt3'],
      [ 'TWINE57%SDELVB.decnet@SNYBUFVA.CS.SNYBUF.EDU (JAMES R. TWINE - THE NERD)',
        'TWINE57%SDELVB.decnet@SNYBUFVA.CS.SNYBUF.EDU (JAMES R. TWINE - THE NERD)',
        'James R. Twine - The Nerd'],
      [ 'David Apfelbaum <da0g+@andrew.cmu.edu>',
        'David Apfelbaum <da0g+@andrew.cmu.edu>',
        'David Apfelbaum'],
      [ '"JAMES R. TWINE - THE NERD" <TWINE57%SDELVB%SNYDELVA.bitnet@CUNYVM.CUNY.EDU>',
        '"JAMES R. TWINE - THE NERD" <TWINE57%SDELVB%SNYDELVA.bitnet@CUNYVM.CUNY.EDU>',
        'James R. Twine - The Nerd'],
      [ 'bilsby@signal.dra (Fred C. M. Bilsby)',
        'bilsby@signal.dra (Fred C. M. Bilsby)',
        'Fred C. M. Bilsby'],
      [ '/G=Owen/S=Smith/O=SJ-Research/ADMD=INTERSPAN/C=GB/@mhs-relay.ac.uk',
        '/G=Owen/S=Smith/O=SJ-Research/ADMD=INTERSPAN/C=GB/@mhs-relay.ac.uk',
        'Owen Smith'],
      [ 'apardon@rc1.vub.ac.be (Antoon Pardon)',
        'apardon@rc1.vub.ac.be (Antoon Pardon)',
        'Antoon Pardon'],
      ['"Stephen Burke, Liverpool" <BURKE@vxdsya.desy.de>',
        '"Stephen Burke, Liverpool" <BURKE@vxdsya.desy.de>',
        'Stephen Burke'],
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
      ['Paul Manser (0032 memo) <a906187@tiuk.ti.com>',
        'Paul Manser <a906187@tiuk.ti.com> (0032 memo)',
        'Paul Manser'],
      ['"gregg (g.) woodcock" <woodcock@bnr.ca>',
        '"gregg (g.) woodcock" <woodcock@bnr.ca>',
        'Gregg Woodcock'],
      ['Clive Bittlestone <clyvb@asic.sc.ti.com>',
        'Clive Bittlestone <clyvb@asic.sc.ti.com>',
        'Clive Bittlestone'],
      ['Graham.Barr@tiuk.ti.com',
        'Graham.Barr@tiuk.ti.com',
        'Graham Barr'],
      ['"Graham Bisset, UK Net Support, +44 224 728109"  <GRAHAM@dyce.wireline.slb.com.ti.com.>',
        '"Graham Bisset, UK Net Support, +44 224 728109" <GRAHAM@dyce.wireline.slb.com.ti.com.>',
        'Graham Bisset'],
      ['a909937 (Graham Barr          (0004 bodg))',
        'a909937 (Graham Barr          (0004 bodg))',
        'Graham Barr'],
      ['a909062@node_cb83.node_cb83 (Colin x Maytum         (0013 bro5))',
        'a909062@node_cb83.node_cb83 (Colin x Maytum         (0013 bro5))',
        'Colin x Maytum'],
      ['a909062@node_cb83.node_cb83 (Colin Maytum         (0013 bro5))',
        'a909062@node_cb83.node_cb83 (Colin Maytum         (0013 bro5))',
        'Colin Maytum'],
      ['Derek.Roskell%dero@msg.ti.com',
        'Derek.Roskell%dero@msg.ti.com',
        'Derek Roskell'],
      ['":sysmail"@ Some-Group. Some-Org, Muhammed.(I am the greatest) Ali @(the)Vegas.WBA',
        '":sysmail"@Some-Group.Some-Org',
        ''],
      ["david d `zoo' zuhn <zoo@aggregate.com>",
        "david d `zoo' zuhn <zoo@aggregate.com>",
        "David D `Zoo' Zuhn"],
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
      ['@oleane.net:hugues@afp.com a!b@c.d foo!bar!foobar!root',
        '@oleane.net:hugues@afp.com',
        'Oleane Net:Hugues'],
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
      p "#{i} #{test_src}"
      result = MailAddress.parse(test_src)[0]

      result_format = result.format || ""
      result_name = result.name || ""

      expect(result_name).to eq(exp_name)
      expect(result_format).to eq(exp_format)
   end
  end
end


