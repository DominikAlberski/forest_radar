# frozen_string_literal: true

require 'rbconfig'

mode = ARGV.fetch(0) { abort 'choose --unit, --system, --live, or --all' }
abort 'unknown suite' unless %w[--unit --system --live --all].include?(mode)
suites = mode == '--all' ? %w[unit system] : [mode.delete_prefix('--')]
failed = false
suites.each do |suite|
  files = Dir[File.join(__dir__, suite, '**', '*_test.rb')]
  abort "#{suite} suite is absent" if files.empty?
  files.each { |file| failed = true unless system(RbConfig.ruby, file) }
end
exit 1 if failed
