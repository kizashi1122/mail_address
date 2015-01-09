module MailAddress

  class Address

    def initialize(phrase, address, comment)
      @phrase = phrase
      @address = address
      @comment = comment
    end
    attr_accessor :phrase, :address, :comment

    ATEXT = '[\-\w !#$%&\'*+/=?^`{|}~]'

    def format
      addr = []
      if !@phrase.nil? && @phrase.length > 0 then
        addr.push(
          @phrase.match(/^(?:\s*#{ATEXT}\s*)+$/) ? @phrase
          : @phrase.match(/(?<!\\)"/)            ? @phrase
          : %Q("#{@phrase}")
          )
        addr.push "<#{@address}>" if !@address.nil? && @address.length > 0
      elsif !@address.nil? && @address.length > 0 then
        addr.push(@address)
      end

      if (!@comment.nil? && @comment.match(/\S/)) then
        @comment.sub!(/^\s*\(?/, '(')
        @comment.sub!(/\)?\s*$/, ')')
      end

      addr.push(@comment) if !@comment.nil? && @comment.length > 0
      addr.join(' ')
    end

    def name
      phrase = @phrase.dup
      addr   = @address.dup

      phrase = @comment.dup unless !phrase.nil? && phrase.length > 0

      name   = Address._extract_name(phrase)

      # first.last@domain address
      if (name == '') && (md = addr.match(/([^\%\.\@_]+([\._][^\%\.\@_]+)+)[\@\%]/)) then
        name = md[1]
        name.gsub!(/[\._]+/, ' ')
        name = Address._extract_name name
      end
      
      if (name == '' && addr.match(%r{/g=}i)) then   # X400 style address
        f = addr.match(%r{g=([^/]*)}i)
        l = addr.match(%r{s=([^/]*)}i)
        name = Address._extract_name "#{f[1]} #{l[1]}"
      end

      name.length > 0 ? name : nil
    end

    def host
      addr = @address || '';
      i = addr.rindex('@')
      i >= 0 ? addr[i + 1 .. -1] : nil
    end


    def user
      addr = @address || '';
      i = addr.rindex('@')
      i >= 0 ? addr[0 ... i] : addr
    end

    private

    # given a comment, attempt to extract a person's name
    def self._extract_name(name)
      # This function can be called as method as well
      return '' if name.nil? || name == ''

      # Using encodings, too hard. See Mail::Message::Field::Full.
      return '' if name.match(/\=\?.*?\?\=/)

      # trim whitespace
      name.sub!(/^\s+/, '')
      name.sub!(/\s+$/, '')
      name.sub!(/\s+/, ' ')

      # Disregard numeric names (e.g. 123456.1234@compuserve.com)
      return "" if name.match(/^[\d ]+$/)

      name.sub!(/^\((.*)\)$/, '\1') # remove outermost parenthesis
      name.sub!(/^"(.*)"$/, '\1')   # remove outer quotation marks
      name.gsub!(/\(.*?\)/, '')     # remove minimal embedded comments
      name.gsub!(/\\/, '')          # remove all escapes
      name.sub!(/^"(.*)"$/, '\1')   # remove internal quotation marks
      name.sub!(/^([^\s]+) ?, ?(.*)$/, '\2 \1') # reverse "Last, First M." if applicable
      name.sub!(/,.*/, '')

      # Change casing only when the name contains only upper or only
      # lower cased characters.
      unless ( name.match(/[A-Z]/) && name.match(/[a-z]/) ) then
        # Set the case of the name to first char upper rest lower
        name.gsub!(/\b(\w+)/io) {|w| $1.capitalize }  # Upcase first letter on name
        name.gsub!(/\bMc(\w)/io) { |w| "Mc#{$1.capitalize}" } # Scottish names such as 'McLeod'
        name.gsub!(/\bo'(\w)/io) { |w| "O'#{$1.capitalize}" } # Irish names such as 'O'Malley, O'Reilly'
        name.gsub!(/\b(x*(ix)?v*(iv)?i*)\b/io) { |w| $1.upcase } # Roman numerals, eg 'Level III Support'
      end

      # some cleanup
      name.gsub!(/\[[^\]]*\]/, '')
      name.gsub!(/(^[\s'"]+|[\s'"]+$)/, '')
      name.gsub!(/\s{2,}/, ' ')
      name
    end

  end

end
