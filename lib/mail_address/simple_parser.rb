module MailAddress

  # --------------------------------------------------------------------------------------------------
  # This module is ported from Google Closure JavaScript Library
  #  -> https://github.com/google/closure-library/blob/master/closure/goog/format/emailaddress.js
  # --------------------------------------------------------------------------------------------------

  OPENERS_ = '"<(['
  CLOSERS_ = '">)]'
  # SPECIAL_CHARS = '()<>@:\\\".[]'
  ADDRESS_SEPARATORS_ = ',;'
  # CHARS_REQUIRE_QUOTES_ = SPECIAL_CHARS + ADDRESS_SEPARATORS_
  ESCAPED_DOUBLE_QUOTES_ = /\\\"/
  ESCAPED_BACKSLASHES_ = /\\\\/
  QUOTED_REGEX_STR_ = '[+a-zA-Z0-9_.!#$%&\'*\\/=?^`{|}~-]+'
  UNQUOTED_REGEX_STR_ = '"' + QUOTED_REGEX_STR_ + '"'
  LOCAL_PART_REGEXP_STR_ = '(?:' + QUOTED_REGEX_STR_ + '|' + UNQUOTED_REGEX_STR_ + ')'
  DOMAIN_PART_REGEXP_STR_ = '([a-zA-Z0-9-_]+\\.)+[a-zA-Z0-9]{2,63}'
  EMAIL_ADDRESS_ = Regexp.new('\\A' + LOCAL_PART_REGEXP_STR_ + '@' + DOMAIN_PART_REGEXP_STR_ + '\\z')

  def self.parse_simple(str)
    result = []
    email = token = ''

    # Remove non-UNIX-style newlines that would otherwise cause getToken_ to
    # choke. Remove multiple consecutive whitespace characters for the same
    # reason.
    str = self.collapse_whitespace(str)
    i = 0
    while (i < str.length)
      token = get_token(str, i)
      if self.is_address_separator(token) || (token == ' ' && self.is_valid(self.parse_internal(email)))
        if !self.is_empty_or_whitespace(email)
          result.push(self.parse_internal(email))
        end
        email = ''
        i += 1
        next
      end
      email << token
      i += token.length
    end

    # Add the final token.
    if (!self.is_empty_or_whitespace(email))
      result.push(self.parse_internal(email))
    end
    return result
  end

  def self.parse_internal(addr)
    name = ''
    address = ''
    i = 0
    while (i < addr.length)
      token = get_token(addr, i)
      if (token[0] == '<' && token.index('>'))
        end_i = token.index('>')
        address = token[1, end_i - 1]
      elsif (address == '')
        name << token
      end
      i += token.length
    end

    # Check if it's a simple email address of the form "jlim@google.com".
    if (address == '' && name.index('@'))
      address = name
      name = ''
    end

    name = self.collapse_whitespace(name)
    name = name[1 .. -2] if name.start_with?('\'') && name.end_with?('\'')
    name = name[1 .. -2] if name.start_with?('"') && name.end_with?('"')

    # Replace escaped quotes and slashes.
    name = name.gsub(ESCAPED_DOUBLE_QUOTES_, '"')
    name = name.gsub(ESCAPED_BACKSLASHES_, '\\')

    #address = goog.string.collapseWhitespace(address);
    address.strip!

    addr = addr.strip
    MailAddress::Address.new(name, address, addr)
  end

  def self.get_token(str, pos)
    ch = str[pos]
    p = OPENERS_.index(ch)
    return ch unless p

    if (self.is_escaped_dbl_quote(str, pos))
      # If an opener is an escaped quote we do not treat it as a real opener
      # and keep accumulating the token.
      return ch
    end
    closer_char = CLOSERS_[p]
    end_pos = str.index(closer_char, pos + 1)

    # If the closer is a quote we go forward skipping escaped quotes until we
    # hit the real closing one.
    while (end_pos && end_pos >= 0 && self.is_escaped_dbl_quote(str, end_pos))
      end_pos = str.index(closer_char, end_pos + 1)
    end

    token = (end_pos && end_pos >= 0) ? str[pos .. end_pos] : ch
    return token
  end

  def self.is_escaped_dbl_quote(str, pos)
    return false if str[pos] != '"'
    slash_count = 0

    for idx in (pos - 1).downto(0)
      break unless str[idx] == '\\'
      slash_count += 1
    end
    (slash_count % 2) != 0
  end

  def self.collapse_whitespace(str)
    str.gsub(/[\s\xc2\xa0]+/, ' ').strip
  end

  def self.is_empty_or_whitespace(str)
    /\A[\s\xc2\xa0]*\z/ =~ str
  end

  def self.is_address_separator(ch)
    ADDRESS_SEPARATORS_.include? ch
  end

  def self.is_valid(address)
    EMAIL_ADDRESS_ =~ address.address
  end

  class << self
    alias_method :g_parse, :parse_simple
  end

end
