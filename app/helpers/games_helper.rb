require 'rubygems'
require 'htmlentities'

module GamesHelper
  def getchildtags(id,game)
    s=""
    children=Tag.find_all_by_parent(id)
    children.each_with_index do |t,i|
      if i % 3==0
        s+="<br/>"
      end
      s+="<input type='checkbox' name='tags[]' value=#{t.id} class='tagbox' rel='#{t.name}'/"
      if game.tags.include?(t)
        s+=" checked=checked "
      end
      s+=">#{t.name}&nbsp;&nbsp;"
    end
    return s
  end
  
  def getchildgames(id)
    games=Game.find_all_by_parent(id)
    render(:partial=>'childgames',:locals=>{:games=>games})
  end
  
  def gettags(game)
    tags=game.tags.find(:all,:conditions=>"children=0")
    s=''
    tags.each do |t|
      if t==tags.last
        s+="<span class='type#{t.type_id}'>#{t.name} </span>" 
      else
        s+="<span class='type#{t.type_id}'>#{t.name}, </span>" 
      end
    end
    return s
  end
  
  def buildtags(tags,game)
    s="<td valign='top'>"
    tags.each.with_index do |t,i|
      if t.children >= 1
        s+="<br/><div class='taglist'>
          <span class='boldtext'>#{t.name}</span>
          <input type='checkbox' class='parenttag' name='tags[]' value=#{t.id}/>
          "+getchildtags(t.id,game)+"<br/></div>"
      else
        s+="<input type='checkbox' name='tags[]' value=#{t.id} class='tagbox'"
        if game.tags.include?(t)
          s+=" checked=checked "
        end
        s+="/>
        <span class='tagname'>#{t.name}</span>&nbsp;&nbsp;<br/>"
      end
      if i>0 && i%10==0
        s+="</td><td valign='top'>"
      end
    end
    s+="</td></div>"
    return s
  end
  
  def build_browsing_category(tags,type)
    s="<ul class='browsing_category'>"
    current=request.query_string
    current.gsub!(/(query=.*)/,'')
    if current.length>0
      current='?'+current+'&'
    else
      current='?'
    end
    tags.each do |t|
      s+="<li><a href='/browse#{current}#{type}=#{t.id}'>#{t.name}</a>"
      if t.children>0
        s+=build_browsing_category(Tag.find_all_by_parent(t.id),type)
      end
      s+="</li>"
    end
    s+="</ul>"
    return s
  end
end
