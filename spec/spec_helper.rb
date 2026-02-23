require 'simplecov'

begin
  require 'coveralls_reborn'
  Coveralls.wear! do
    add_filter '.bundle/'
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ])
rescue LoadError
  SimpleCov.start do
    add_filter '.bundle/'
  end
end

require 'rubygems'
require 'mail_address'
