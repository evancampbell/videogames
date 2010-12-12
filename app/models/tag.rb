class Tag < ActiveRecord::Base
  validates_presence_of :name
  has_many :associations,:foreign_key=>"tag_id",:dependent=>:destroy
  has_many :reverse_associations,:foreign_key=>"game_id",:class_name=>"Association"
  has_many :games,:through=>:associations
  belongs_to :type
  attr_accessible :name,:type_id,:description,:parent,:children
  
  def self.find_types(mode=0,conditions='and parent=0')
    a=[]
    mode==1 ? ordering='name' : ordering='children'
    for t in (1..5)
      if mode==0 and t==4
        items=self.order('name ASC').find(:all,:conditions=>["type_id=? "+conditions,t])
      else
        items=self.order(ordering+" ASC").find(:all,:conditions=>["type_id=? "+conditions,t])
      end
      a.push(items)
    end
    return a
  end
end
