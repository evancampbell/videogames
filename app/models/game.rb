class Game < ActiveRecord::Base
  validates_numericality_of :year,:greater_than=>1971,:less_than=>2015,:allow_blank=>true
  validates_numericality_of :rating,:greater_than=>0,:less_than=>101,:allow_blank=>true
  validates_presence_of :name
  has_many :associations,:foreign_key=>"game_id", :dependent=>:destroy
  has_many :reverse_associations,:foreign_key=>"tag_id",:class_name=>"Association"
  has_many :tags,:through=>:associations,:uniq=>true
  validates_associated :tags
  has_many :links
  attr_accessor :tag_ids
  after_save :update_tags
  after_update :bequeath_tags,:if=>"type_of==1"
  
  def description=(val)
    write_attribute(:description,val.strip)
  end
  
  #if a series is assigned any new tags, pass them on to its child games
  def bequeath_tags 
    children=Game.find_all_by_parent(self.id)
    children.each do |c|
      c.associations.each do |a|
        tag_ids.delete(a.tag_id.to_s)
      end
      self.tag_ids.each do |t|
        c.associations.create(:tag_id=>t) unless t.blank?
      end
    end
  end
  
  #this does the work of creating/updating game-tag associations
  def update_tags
    unless tag_ids.nil?
      self.associations.each do |a|
      #destroy an association if its tag wasn't checked in the form
        a.destroy unless tag_ids.include?(a.tag_id.to_s)
      #for each existing association, delete its tag from the parameters(to prevent duplicate associations)
        tag_ids.delete(a.tag_id.to_s)
      end
      devs=Tag.find(:all,:conditions=>'type_id=4',:select=>'id').map(&:id)
      genres=Tag.find(:all,:conditions=>'type_id=2',:select=>'id').map(&:id)
      if (tag_ids&devs).length==0
        indie=Tag.find_by_name('Independent')
        # if no developer has been selected, assume "Independent"
        self.associations.create(:tag_id=>indie.id)
      end
      if (tag_ids&genres).length==0
        other=Tag.find_by_name('Other')
        # if no genre has been selected, assume "Other"
        self.associations.create(:tag_id=>other.id)
      end
      tag_ids.each do |t|
        self.associations.create(:tag_id=>t) unless t.blank?
      end
      reload
      self.tag_ids=nil
    end
  end
end
