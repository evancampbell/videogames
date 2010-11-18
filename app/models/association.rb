class Association < ActiveRecord::Base
  belongs_to :game
  belongs_to :tag
  attr_accessible :tag_id
  
  validates :game_id,:presence=>true
  validates :tag_id,:presence=>true
  
  def is_tagged?(tag)
    associations.find_by_tag_id(tag)
  end
  
  def tag!(tag)
    self.associations.create(:tag_id=>tag.id)
  end
  
  def untag!(tag)
    self.associations.find_by_tag_id(tag).destroy
  end
end
