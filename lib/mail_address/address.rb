module MailAddress

  class Address

    attr_accessor :phrase, :address, :original

    def initialize(phrase, address, original)
      # validate
      if address.nil? || original.include?(address)
        @address = address
      else
        @address = nil # wrongly constructed address
      end
      @phrase = phrase
      @original = original
    end

    ATEXT = '[\-\w !#$%&\'*+/=?^`{|}~]'

    def format
      addr = []
      return @original if @address.nil?

      if !@phrase.nil? && @phrase.length > 0 then
        if @phrase.match(/\A\(/) && @phrase.match(/\)\z/)
          addr.push(@address) if !@address.nil? && @address.length > 0
          addr.push(@phrase)
        else
          addr.push(
            @phrase.match(/^(?:\s*#{ATEXT}\s*)+$/) ? @phrase
            : @phrase.match(/(?<!\\)"/)            ? @phrase
            : %Q("#{@phrase}")
            )
          addr.push "<#{@address}>" if !@address.nil? && @address.length > 0
        end
      elsif !@address.nil? && @address.length > 0 then
        addr.push(@address)
      end
      addr.join(' ')
    end

    def name
      phrase = @phrase.dup
      name   = Address._extract_name(phrase)
      name.length > 0 ? name : nil
    end

    def host
      addr = @address || '';
      i = addr.rindex('@')
      i.nil? ? nil : addr[i + 1 .. -1]
    end

    def user
      addr = @address || '';
      i = addr.rindex('@')
      i.nil? ? addr : addr[0 ... i]
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
      name.gsub!(/\\/, '')          # remove all escapes
      name.sub!(/^"(.*)"$/, '\1')   # remove internal quotation marks

      # some cleanup
      name.gsub!(/\[[^\]]*\]/, '')
      name.gsub!(/(^[\s'"]+|[\s'"]+$)/, '')
      name.gsub!(/\s{2,}/, ' ')
      name
    end

  end

end
