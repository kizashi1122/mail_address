require 'simplecov'

begin
  require 'coveralls'
  Coveralls.wear!
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])
rescue LoadError
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.start do
  add_filter '.bundle/'
end

require 'rubygems'
require 'mail_address'
