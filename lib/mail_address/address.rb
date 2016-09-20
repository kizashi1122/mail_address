module MailAddress

  class Address

    attr_accessor :phrase, :address, :original

    def initialize(phrase, address, original)
      @address = address
      @phrase = phrase
      @original = original

      ###  validate afterwords
      # parse failed or invalid address
      unless (@address && @original.include?(@address)) && Address._check_address_with_regex(@address)
        @address = nil
      end

      # invalid address
      @phrase = original if @address.nil?
    end

    ATEXT = '[\-\w !#$%&\'*+/=?^`{|}~]'

    def format(enquote = false)
      addr = []
      return @original.gsub(/[;,]/, '') if @address.nil?

      email_address = enquote ? quoted_address : @address

      if !@phrase.nil? && @phrase.length > 0 then
        if @phrase.match(/\A\(/) && @phrase.match(/\)\z/)
          addr.push(email_address) if !@address.nil? && @address.length > 0
          addr.push(@phrase)
        else
          addr.push(
            @phrase.match(/^(?:\s*#{ATEXT}\s*)+$/) ? @phrase
            : @phrase.match(/(?<!\\)"/)            ? @phrase
            : %Q("#{@phrase}")
            )
          addr.push "<#{email_address}>" if !@address.nil? && @address.length > 0
        end
      elsif !@address.nil? && @address.length > 0 then
        addr.push(email_address)
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

    def quoted_address
      if @address
        local_part = self.user.gsub(/(\A"|"\z)/, '')
        if local_part.include?('..') || local_part.end_with?('.')
          return "\"#{local_part}\"@#{self.host}"
        end
      end
      @address
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

    def self._check_address_with_regex(email_address)
      return nil unless email_address
      # check if the address is compliant with RFC2822
      # regex check (see  http://blog.livedoor.jp/dankogai/archives/51189905.html)
#      email_address.match(/^(?:(?:(?:(?:[a-zA-Z0-9_!#\$\%&'*+\/=?\^`{}~|\-]+)(?:\.(?:[a-zA-Z0-9_!#\$\%&'*+\/=?\^`{}~|\-]+))*)|(?:"(?:\\[^\r\n]|[^\\"])*")))\@(?:(?:(?:(?:[a-zA-Z0-9_!#\$\%&'*+\/=?\^`{}~|\-]+)(?:\.(?:[a-zA-Z0-9_!#\$\%&'*+\/=?\^`{}~|\-]+))*)|(?:\[(?:\\\S|[\x21-\x5a\x5e-\x7e])*\])))$/)

      # permit Docomo/Au address
      EMAIL_ADDRESS_ =~ email_address
    end

  end

end
