class Tag < ActiveRecord::Base
  validates_presence_of :name
  has_many :associations,:foreign_key=>"tag_id",:dependent=>:destroy
  has_many :reverse_associations,:foreign_key=>"game_id",:class_name=>"Association"
  has_many :games,:through=>:associations
  belongs_to :type
  attr_accessible :name,:type_of,:description,:parent,:children
  
  def self.find_types(types,mode)
    a=[]
    types.to_a.each do |t|
      items=self.order(mode+" ASC").find(:all,:conditions=>["type_id=? and parent=0",t])
      a.push(items)
    end
    return a
  end
end
