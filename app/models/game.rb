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
  after_create :update_tags
  after_update :update_tags
  
  searchable do
    text :name,:as=>:name_textp
  end
  
  
  def description=(val)
    write_attribute(:description,val.strip)
  end
  
  #this does the work of creating/updating game-tag associations
  def update_tags
    tags=self.tag_ids.clone
    unless tags.nil?
      self.associations.each do |a|
      #destroy an association if its tag wasn't checked in the form
        a.destroy unless tags.include?(a.tag_id.to_s)
      #for each existing association, delete its tag from the parameters(to prevent duplicate associations)
        tags.delete(a.tag_id.to_s)
      end
      devs=Tag.find(:all,:conditions=>'type_id=4',:select=>'id').map{|d| d.id.to_s}
      genres=Tag.find(:all,:conditions=>'type_id=2',:select=>'id').map{|g| g.id.to_s}
      if (tags&devs).length==0
        indie=Tag.find_by_name('Independent')
        # if no developer has been selected, assume "Independent"
        self.associations.create(:tag_id=>indie.id)
      end
      if (tags&genres).length==0
        other=Tag.find_by_name('Other')
        # if no genre has been selected, assume "Other"
        self.associations.create(:tag_id=>other.id)
      end
      tags.each do |t|
        self.associations.create(:tag_id=>t) unless t.blank?
      end
      reload
    end
  end
  
  
end
