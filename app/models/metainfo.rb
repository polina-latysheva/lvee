class Metainfo < ActiveRecord::Base
  validates_presence_of :language
  validates_presence_of :page
  validates_uniqueness_of :page, :scope => :language

  def self.for(lang, page)
    metainfo = Metainfo.find_by_language_and_page(lang, page) ||
      Metainfo.find_by_language_and_page(I18n.default_locale, page) ||
      Metainfo.new()
    metainfo.page = page
    metainfo.language = lang
    metainfo
  end

end
