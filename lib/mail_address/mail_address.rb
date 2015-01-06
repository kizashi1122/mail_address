
module MailAddress

  def self.parse(*addresses)
    lines = addresses.grep(String)
    line = lines.join('')

    phrase, comment, address, objs = [], [], [], []
    depth, idx = 0, 0

    tokens = _tokenize lines
    len    = tokens.length
    _next  = _find_next idx, tokens, len

    for idx in 0 ... len do
      token = tokens[idx]
      substr = token[0, 1]
      if (substr == '(') then
        comment.push(token)
      elsif (token == '<') then
        depth += 1
      elsif (token == '>') then
        depth -= 1 if depth > 0
      elsif (token == ',' || token == ';') then
        raise "Unmatched '<>' in line" if depth > 0
        o = _complete(phrase, address, comment)

        objs.push(o) if o
        depth = 0
        _next = _find_next idx+1, tokens, len
      elsif (depth > 0) then
        address.push(token)
      elsif (_next == '<') then
        phrase.push(token)
      elsif ( token.match(/^[.\@:;]/) || address.empty? || address[-1].match(/^[.\@:;]/) ) then
        address.push(token)
      else
        raise "Unmatched '<>' in line" if depth > 0
        o = _complete(phrase, address, comment)
        objs.push(o) if o
        depth = 0
        address.push(token)
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
      if ( line.sub!(/^\s*\(/, '(') )    # (...)
        depth = 0

        catch :PAREN do
          while line.sub!(/\A(\(([^\(\)\\]|\\.)*)/, '') do
            field << $1
            depth += 1
            while line.sub!(/\A(([^\(\)\\]|\\.)*\)\s*)/, '') do
              field << $1
              depth -= 1
              throw :PAREN if depth == 0
              field << $1 if line.sub!(/\A(([^\(\)\\]|\\.)+)/, '')
            end
          end
        end
        raise "Unmatched () '#{field}' '#{line}'" if depth > 0

        field.sub!(/\s+\Z/, '')
        words.push(field)

        next
      end

      tmp = nil
      if (
          line.sub!(/\A("(?:[^"\\]+|\\.)*")\s*/, '')      || # "..."
          line.sub!(/\A(\[(?:[^\]\\]+|\\.)*\])\s*/, '')   || # [...]
          line.sub!(/\A([^\s()<>\@,;:\\".\[\]]+)\s*/, '') ||
          line.sub!(/\A([()<>\@,;:\\".\[\]])\s*/, '')
          )
        words.push($1)
        next
      end
      raise "Unrecognized line: #{line}"
    end

    words.push(',')
    words
  end

  def self._find_next(idx, tokens, len)
    while (idx < len)
      c = tokens[idx]
      return c if c == ',' || c == ';' || c == '<'
      idx += 1
    end
    ""
  end

  def self._complete (phrase, address, comment)
    phrase.length > 0 || comment.length > 0 || address.length > 0 or return nil
    MailAddress::Address.new(phrase.join(' '), address.join(''), comment.join(' '))
  end

end
