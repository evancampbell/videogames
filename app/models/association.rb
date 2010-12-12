class Association < ActiveRecord::Base
  belongs_to :game
  belongs_to :tag
  attr_accessible :tag_id
  validates_uniqueness_of :tag_id,:scope=>:game_id
  validates :game_id,:presence=>true
  validates :tag_id,:presence=>true
  after_create :bequeath_games
  
  def is_tagged?(tag)
    associations.find_by_tag_id(tag)
  end
  
  def tag!(tag)
    self.associations.create(:tag_id=>tag.id)
  end
  
  def untag!(tag)
    self.associations.find_by_tag_id(tag).destroy
  end
  
  #if a series is assigned a new tag, pass it on to its child games
  def bequeath_games
    game=Game.find(game_id)
    if Game.exists?(:parent=>game)
      children=Game.find(:all,:conditions=>['parent=?',game])
      children.each do |c|
        c.associations.create(:tag_id=>tag_id)
      end
    end
  end
end
