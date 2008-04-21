class News < ActiveRecord::Base

  belongs_to :user

  acts_as_authorizable

  attr_protected :user_id # публикуем только от своего имени

  named_scope :published, :conditions => { :published => 1 }, :order => 'created_at DESC'

end
