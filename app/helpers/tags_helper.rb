module TagsHelper
  def getchildren(id)
    children=Tag.order('name ASC').find_all_by_parent(id)
    render(:partial=>'partials/childtags',:locals=>{:tags=>children})
  end
  
  def getchildgames(id)
    games=Game.order('year ASC').find_all_by_parent(id)
    render(:partial=>'childgames',:locals=>{:games=>games})
  end
  
  def constructtags(tags)
    render(:partial=>'partials/taglist',:locals=>{:tags=>tags})
  end
end
