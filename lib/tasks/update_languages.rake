$KCODE='u'

require File.join(RAILS_ROOT, 'config', 'initializers', 'i18n.rb')
require File.join(RAILS_ROOT, 'vendor', 'gems', 'ya2yaml-0.26', 'lib', 'ya2yaml.rb')

require 'language_update_helper'
include LanguageUpdateHelper

def update_language(lang, def_lang)
  cur_lang = YAML.load_file("#{LOCALE_DIR}/#{lang}.yml")

  store_merged_language(def_lang, cur_lang, lang)
end

desc "Updates languages"
task :update_languages do
  puts "Updating..."
  languages = %w(be hu pl ru uk)

  def_lang = YAML.load_file("#{LOCALE_DIR}/en.yml")

  languages.each { |lang|
    puts "Updating #{lang}..."
    update_language(lang, def_lang)
  }
end
