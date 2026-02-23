require 'simplecov'

if ENV['CI']
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
end

SimpleCov.start do
  add_filter '.bundle/'
end

require 'rubygems'
require 'mail_address'
