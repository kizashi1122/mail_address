
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
        if end_paren_idx == -1
          # end paren doesn't exist
          # but nothing to do
        end
        rem = tokens[idx .. end_paren_idx]
        phrase.push(rem.join(''))
      elsif (substr == '<') then
        depth += 1
      elsif (substr == '>') then
        depth -= 1 if depth > 0
      elsif (substr == ',' || substr == ';') then
        original.sub!(/[,;]\s*\z/, '')

        if depth > 0
          # raise "Unmatched '<>' in line"
          o = MailAddress::Address.new(original, nil, original)
          phrase.clear; address.clear
        else
          o = _complete(phrase, address, original)
        end

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
    words = []

    line.gsub!(/\\/, '')
    line.sub!(/\A\s+/, '')
    line.gsub!(/[\r\n]+/,' ')

    while (line != '')
      tmp = nil
      if (
          line.match(/"[^"]+"/) && line.sub!(/\A(\\?"(?:[^"\\]+|\\.)*")(\s*)/, '')  || # "..."
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

    name = phrase.join('').strip

    name = self.collapse_whitespace(name)
    name = name[1 .. -2] if name.start_with?('\'') && name.end_with?('\'')
    name = name[1 .. -2] if name.start_with?('"') && name.end_with?('"')

    # Replace escaped quotes and slashes.
    name = name.gsub(ESCAPED_DOUBLE_QUOTES_, '"')
    name = name.gsub(ESCAPED_BACKSLASHES_, '\\')

    new_address = MailAddress::Address.new(name, address.join(''), original)
    phrase.clear; address.clear
    new_address
  end

end
