module TagsHelper
  def getchildren(id)
    children=Tag.find_all_by_parent(id)
    render(:partial=>'childtags',:locals=>{:tags=>children})
  end
  
  def constructtags(tags)
    render(:partial=>'taglist',:locals=>{:tags=>tags})
  end
end
