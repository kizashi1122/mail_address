# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pp'

describe MailAddress do

  it "normal case" do
    line = "John 'M' Doe <john@example.com> (this is a comment), 大阪 太郎 <osaka@example.jp>"
    results = MailAddress.parse(line)

    expect(results[0].format).to eq("John 'M' Doe <john@example.com> (this is a comment)")
    expect(results[0].address).to eq("john@example.com")
    expect(results[0].name).to eq("John 'M' Doe")
    expect(results[0].comment).to eq("(this is a comment)")
    expect(results[0].phrase).to eq("John 'M' Doe")
    expect(results[0].host).to eq("example.com")
    expect(results[0].user).to eq("john")

    # Perl module Mail::Address returns '大阪 太郎 <osaka@example.jp>' (no double quote)
    # because regular expression \w matches even multibyte characters.
    expect(results[1].format).to eq("\"大阪 太郎\" <osaka@example.jp>")

    expect(results[1].address).to eq("osaka@example.jp")
    expect(results[1].name).to eq("大阪 太郎")
    expect(results[1].comment).to eq("")
    expect(results[1].phrase).to eq("大阪 太郎")
    expect(results[1].host).to eq("example.jp")
    expect(results[1].user).to eq("osaka")
  end

  it "unparsable with mail gem (includes '[')" do
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
    expect(results[0].comment).to eq("")
    expect(results[0].phrase).to  eq("大阪 太郎")
    expect(results[0].host).to    eq("example.jp")
    expect(results[0].user).to    eq("osaka")
  end

  it "unparsable with mail gem (???)" do
    line = "大阪 太郎(ABC XYZ) <osaka@example.com>"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("\"大阪 太郎\" <osaka@example.com> (ABC XYZ)")
    expect(results[0].address).to eq("osaka@example.com")
    expect(results[0].name).to    eq("大阪 太郎")
    expect(results[0].comment).to eq("(ABC XYZ)")
    expect(results[0].phrase).to  eq("大阪 太郎")
    expect(results[0].host).to    eq("example.com")
    expect(results[0].user).to    eq("osaka")
  end

  it "unparsable with mail gem (???)" do
    line = "大阪 太郎 <osaka@example.jp> (日本)"
    results = MailAddress.parse(line)
    expect(results[0].format).to  eq("\"大阪 太郎\" <osaka@example.jp> (日本)")
    expect(results[0].address).to eq("osaka@example.jp")
    expect(results[0].name).to    eq("大阪 太郎")
    expect(results[0].comment).to eq("(日本)")
    expect(results[0].phrase).to  eq("大阪 太郎")
    expect(results[0].host).to    eq("example.jp")
    expect(results[0].user).to    eq("osaka")
  end

  it 'Perl Module Pod test data' do

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


