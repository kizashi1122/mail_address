
module MailAddress

  def self.parse(*addresses)
    lines = addresses.grep(String)
    line = lines.join('')

    # empty
    if line.strip.empty?
      return [ MailAddress::Address.new(line, nil, line) ]
    end

    # undisclosed-recipient
    if line.match(/undisclosed[ \-]recipients?: ?;?/i)
      return [ MailAddress::Address.new(line, nil, line) ]
    end

    phrase, address, objs = [], [], []
    original = ''
    depth, idx, end_paren_idx = 0, 0, 0

    tokens = _tokenize lines
    len    = tokens.length
    _next  = _find_next idx, tokens, len

    for idx in 0 ... len do

      token = tokens[idx]
      substr = token[0, 1]
      original << token

      if (end_paren_idx > 0 && end_paren_idx >= idx)
        next
      end

      if (substr == '(' && !address.empty?) then
        end_paren_idx = _find_next_paren(idx, tokens, len)
        raise "cannot find end paren" if end_paren_idx == -1 # end paren must exists after address
        rem = tokens[idx .. end_paren_idx]
        phrase.push(rem.join(''))
      elsif (substr == '<') then
        depth += 1
      elsif (substr == '>') then
        depth -= 1 if depth > 0
      elsif (substr == ',' || substr == ';') then
        raise "Unmatched '<>' in line" if depth > 0

        original.sub!(/[,;]\s*\z/, '')

        o = _complete(phrase, address, original)

        objs.push(o) if o
        depth = 0
        end_paren_idx = 0
        original = ''
        _next = _find_next idx+1, tokens, len
      elsif (depth > 0) then
        token.strip!
        address.push(token)
      elsif (_next == '<') then
        phrase.push(token)
      elsif ( token.match(/^[.\@:;]/) || address.empty? || address[-1].match(/^[.\@:;]/) ) then
        token.strip!
        address.push(token)
      else
        phrase.push(token)
      end
    end
    objs
  end

  private

  def self._tokenize(addresses)
    line = addresses.join(',') # $_
    words, snippet, field = [], [], []

    line.sub!(/\A\s+/, '')
    line.gsub!(/[\r\n]+/,' ')

    while (line != '')
      field = ''
      tmp = nil
      if (
          line.sub!(/\A("(?:[^"\\]+|\\.)*")(\s*)/, '')      || # "..."
          line.sub!(/\A(\[(?:[^\]\\]+|\\.)*\])(\s*)/, '')   || # [...]
          line.sub!(/\A([^\s()<>\@,;:\\".\[\]]+)(\s*)/, '') ||
          line.sub!(/\A([()<>\@,;:\\".\[\]])(\s*)/, '')
          )
        words.push("#{$1}#{$2}")
        next
      end
      raise "Unrecognized line: #{line}"
    end

    words.push(',')
    words
  end

  def self._find_next(idx, tokens, len)
    while (idx < len)
      c = tokens[idx].strip
      return c if c == ',' || c == ';' || c == '<'
      idx += 1
    end
    ""
  end

  # find next ending parenthesis
  def self._find_next_paren(idx, tokens, len)
    while (idx < len)
      c = tokens[idx].strip
      return idx if c.include?(')')
      idx += 1
    end
    -1
  end

  def self._complete (phrase, address, original)
    phrase.length > 0 || address.length > 0 or return nil
    new_address = MailAddress::Address.new(phrase.join('').strip, address.join(''), original)
    phrase.clear; address.clear
    new_address
  end

end
