require 'rubygems'
require 'htmlentities'

module GamesHelper
  def getchildtags(id,game)
    s="<table><tr>"
    children=Tag.order('name ASC').find_all_by_parent(id)
    children.each_with_index do |t,i|
      if i>0 and i % 3==0 then s+="</tr><tr>" end
      s+="<td><input type='checkbox' name='tags[]' value=#{t.id} class='tagbox' rel='#{t.name}' /"
      if game.tags.include?(t) then s+=" checked=checked " end
      s+="><span class='tagname'>#{t.name}</span></td>"
      
    end
    s+="</tr></table>"
    return s
  end
  
  def getchildgames(id)
    games=Game.order('year ASC').find_all_by_parent(id)
    render(:partial=>'childgames',:locals=>{:games=>games})
  end
  
  def gettags(game)
    tags=game.tags.all
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
          <span class='boldtext'>#{t.name}</span>"
        if t.type_id!=5
          s+="<input type='checkbox' class='parenttag' value=#{t.id} name='tags[]'  />"
        end
        s+=getchildtags(t.id,game)+"<br/></div>"
      else
        s+="<input type='checkbox' rel='#{t.name}' name='tags[]' value=#{t.id} class='tagbox'"
        if game.tags.include?(t) then s+=" checked=checked " end
        s+="/>
        <span class='tagname'>#{t.name}</span>&nbsp;&nbsp;<br/>"
      end
      if i>0 && i%10==0 then s+="</td><td valign='top'>" end
    end
    s+="</td></div>"
    return s
  end
  
  def build_browsing_category(tags,type,mode)
    s="<ul class='#{mode}'>"
    current=request.query_string
    current.gsub!(/(query=.*)/,'')
    if current.length>0
      current='?'+current+'&'
    else
      current='?'
    end
    tags.each do |t|
      s+="<li>"+build_tag_link(current,type,t)
      if t.children>0
        s+=build_browsing_category(Tag.find_all_by_parent(t.id),type,mode)
      end
      s+="</li>"
    end
    s+="</ul>"
    return s
  end
  
  def build_tag_link(current,type,t)
    return "<a href='/browse#{current}#{type}=#{t.id}'>#{t.name}</a>"
  end
  
  def get_rating_color(ratio)
    if ratio>1 then color='purple' end
    if ratio<=1 && ratio>=0.9 then color='red' end
    if ratio<0.9 && ratio>=0.75 then color='orange' end
    if ratio<0.75 && ratio>=0.5 then color='yellow' end
    return color
  end
end
