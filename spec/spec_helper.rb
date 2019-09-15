require 'simplecov'
require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start do
  add_filter '.bundle/'
end

require 'rubygems'
require 'mail_address'
