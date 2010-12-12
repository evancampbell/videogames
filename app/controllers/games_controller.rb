require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'sanitize'


def calc_sim(tags,issource)
  total=0
  platforms=0
  devs=0
  tags.each do |t|
    if t.type_id==3
      platforms+=1
    elsif t.type.id==4
      devs+=2
    end
    if t.type_id==2 and t.parent>0 then total+=1 end
    total+=t.type.value
  end
  if issource==true
    total=total-(devs+platforms)
  else
    total=total-(platforms-1) unless platforms<2 #if two games have more than one console in common it only counts as one.
  end 
  return total
end
  
# TO DO
#   game links
#   voting
#   get game images
#   user tag adding
#   usage notes on theme tags
#   result colors

class GamesController < ApplicationController
  def index
    @title='All games'
    @games = Game.order('LOWER(name) ASC').limit(LIST_OFFSET).find(:all,:conditions=>['parent=0'])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end


  def show
    @game = Game.find(params[:id])
    @title=@game.name
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game }
    end
  end
  
  
  #this could almost certainly be improved
  def browse
    params=CGI.parse(request.query_string)
    @results=[]
    @tags=[]
    if params.length>0
      pvalues=[]
      params.each do |k,v|
        if v.kind_of?(Array)
          v.each { |w| pvalues.push(w) }
        else
          pvalues.push(v)
        end
      end
      pvalues.each do |p|
        if p==pvalues.first
          @results=Tag.find(p).games
        else
          derp=Tag.find(p).games
          @results=@results&derp
        end
        if p==pvalues.last
          @subtags=Tag.find_all_by_parent(p)
          @type=case Tag.find(p).type_id
            when 0 then 'misc'
            when 1 then 'genre'
            when 2 then 'platform'
            when 3 then 'dev'
            when 4 then 'theme'
          end
        end
        @tags.push(Tag.find(p))
      end
    end
    @misc,@genres,@platforms,@devs,@themes=Tag.find_types()
    render :layout=>'main'
  end
  
  
  def edit
    @title='Edit game'
    @game = Game.find(params[:id])
    @misc,@genres,@platforms,@devs,@themes=Tag.find_types()
    @parents=Game.order('name ASC').find(:all,:conditions=>["type_of=1 and parent=0"])
    @associations=@game.associations
  end


  def new
    @title='New game'
    @game = Game.new
    @misc,@genres,@platforms,@devs,@themes=Tag.find_types()
    @parents=Game.order('name ASC').find(:all,:conditions=>["type_of=1 and parent=0"])
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @game }
    end
  end
  
  
  def create
    game=params[:game]
    @game = Game.create!(:name=>game[:name],:year=>game[:year],:rating=>game[:rating],:description=>game[:description],:parent=>game[:parent],:type_of=>game[:type_of],:tag_ids=>params['tags'])
    @tags=Tag.all
    respond_to do |format|
      if @game.valid?
        format.html { redirect_to(:action=>'new') }
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { redirect_to( :action => "new") }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    @game = Game.find(params[:id])
    game=params[:game]
    respond_to do |format|
      if @game.update_attributes!(:name=>game[:name],:year=>game[:year],:rating=>game[:rating],:description=>game[:description],:parent=>game[:parent],:type_of=>game[:type_of],:tag_ids=>params['tags'])     
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  
  
  def load_new_games
    id=params[:id]
    offset=params[:offset].to_i
    @games=Game.order('LOWER(name) ASC').limit(LIST_OFFSET).offset(offset).find(:all,:conditions=>['parent=0'])
    @offset=offset+LIST_OFFSET
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
  
  
  #---perform a query with the recommendation engine.---#
  def recommend_search
    q=params['query']
    if params['query'][-8,8]=='(series)'
      type=1
      q.gsub!(' (series)','')
    else
      type=0
    end
    puts params['query'][0,-9]
    game=Game.find_by_type_of_and_name(type,q)
    @game=game.id
    tags=game.tags.find(:all,:conditions=>"children=0")
    games=Game.order('parent ASC').find(:all,:conditions=>['id != ?',game.id])
    games.insert(0,game)
    @indiv=[]
    @series=[]
    @full=0.0
    games.each do |g|
      sim=0.0
      relevance=0.0
      cmmn=(tags&g.tags)
      sim=calc_sim(cmmn,g==game)
      if g==game
        @full=sim
      else
        total=calc_sim(g.tags,true)
        source_total=calc_sim(tags,true)
        sim=sim-(((total/source_total)/10)*sim) #penalty for when the compared game has much greater tags than the source game 
        if sim>@full*0.5 #arbitrary, this could be better
          if g.rating==nil then rating=101 else rating=g.rating end
          ratio=sim/@full>1 ? 1 : sim/Float(@full)
          puts "#{g.name}: #{sim},#{@full},#{ratio},#{rating},#{Float(sim/@full)}"
          relevance=Float((ratio+rating/100.0)/2) #this could probably be improved
          
          if g.type_of==0
            @indiv.push({:game=>g,:sim=>sim,:relevance=>relevance})
          else
            @series.push({:game=>g,:sim=>sim,:relevance=>relevance})
          end
        end
      end
    end
    @indiv=@indiv.sort {|a,b| [ a[:relevance] ] <=> [b[:relevance] ]}.reverse
    @series=@series.sort {|a,b| [ a[:relevance] ] <=> [b[:relevance] ]}.reverse
    @misc,@genres,@platforms,@devs,@themes=Tag.find_types()
    render :layout=>'main'
  end
  
  
  def mass_delete
    params[:mass].each do |m|
      Game.destroy(m)
    end
    redirect_to(:action=>'index')
  end 
  
  #------------------------AJAX ACTIONS----------------------------#
  
  
  def destroy
    respond_to do |format|
      if request.xhr?
        @game = Game.find(params[:id])
        if @game.destroy
          format.js {render :json=>{:status=>:ok}}
        else
          format.js {render :json=>{:status=>:error}}
        end
      else 
        format.html { redirect_to(:action=>'index') }
      end
    end
  end
  
  
  def livesearch
    @search=Game.search do
      keywords(params[:id])
    end

    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
  
  
  #---get the search results of the game name on either metacritic or gamerankings via ajax.---#
  def getsearchresults
    query=params['q'].gsub(' ','+')
    query=query.gsub('/','%2F')
    if params[:site]=='metacritic'
      doc=Nokogiri::HTML(open("http://metacritic.com/search/game/#{query}/results"))
      doc.encoding='utf-8'
      @results=doc.css("li.result").inner_html
    elsif params[:site]=='gamerankings'
      doc=Nokogiri::HTML(open("http://www.gamerankings.com/browse.html?search=#{query}&numrev=3"))
      @results=doc.at_css("div#main_col > div.pod").inner_html
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def getgameinfo
    if params[:site]=='metacritic'
      doc=Nokogiri::HTML(open("http://metacritic.com#{params['href']}"))
      doc.encoding='utf-8'
      blurb1=''
      blurb2=''
      doc.css("li.summary_detail.product_summary").each do |s|
        if s.at_css('span.blurb').inner_html == nil
          blurb1=s.at_css('span.data').inner_html
        else
          blurb1=s.at_css("span.blurb.blurb_collapsed").inner_html
          blurb2=s.at_css("span.blurb.blurb_expanded").inner_html
        end
      end
      @desc=(blurb1+blurb2).strip
      @desc.gsub!(/\[[A-z\s1-2]*\]/,'')
      @platforms=[]
      doc.css("span[@class='platform']").each do |p|
        platform=p.at_css('a').content
        @platforms.push(platform)
      end
      doc.css("li.summary_detail.product_platforms").each do |p|
        p.css('a').inner_html.each do |a|
          @platforms.push(a)
        end
      end
      doc.css("li.summary_detail.developer").each do |d|
        @dev=d.at_css("span.data").inner_html
        @dev.strip!
      end
      
    elsif params[:site]=='gamerankings'
      doc=Nokogiri::HTML(open("http://gamerankings.com#{params[:href]}"))
      doc.encoding='utf-8'
      @desc=doc.at_css("div.pod[2] > div.body > div.details").children.select{|e| e.text?}.join('')
      @desc.strip!
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def getparenttags
    game=Game.find(params[:id])
    @tags=game.associations
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end

  def check_if_exists
    name=params[:id]
    if Game.exists?(:name=>name,:type_of=>0) then render :text=>'Exists as a <span class="boldtext">game</span>.' and return end
    if Game.exists?(:name=>name,:type_of=>1) then render :text=>'Exists as a <span class="italictext">series</span>.' and return end
    render :text=>'' and return
  end
  
  
  def getcommontags
    tags1=Game.find(params[:game1]).tags
    tags2=Game.find(params[:game2]).tags
    cmmn=(tags1&tags2)
    s="&nbsp;&nbsp;"
    cmmn.each do |c|
      if c==cmmn.last
        s+="#{c.name}"
      else
        s+="#{c.name} - "
      end
    end
    render :text=>s
  end
  
  
  def getalltags
    s=""
    tags=Game.find(params[:id]).tags
    tags.each do |t|
      if t==tags.last
        s+="#{t.name}"
      else
        s+="#{t.name} - "
      end
    end
    render :text=>s
  end
  
  
  def getgamespotlink
    query=params['id'].gsub(' ','+')
    query=query.gsub('/','%2F')
    doc=Nokogiri::HTML(open("http://gamespot.com/search.html?qs=#{params['q']}"))
    doc.encoding='utf-8'
    @results=doc.css("div#results > ul.search_results").inner_html
    puts doc.at_css("div#results").inner_html
    puts @results
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
  
  
  def getfullinfo
    @game=Game.find(params[:id])
    @misc,@genres,@platforms,@devs,@themes=@game.tags.find_types(1,'')
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
end
