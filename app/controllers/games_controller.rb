require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'sanitize'

class GamesController < ApplicationController
  def index
    @games = Game.order('name ASC').limit(15).find(:all,:conditions=>['parent=0'])
    @games.each do |g|
      puts g.name
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @games }
    end
  end

  def show
    @game = Game.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @game }
    end
  end
  
  #this could almost certainly be improved
  def browse
    params=CGI.parse(request.query_string)
    @results=[]
    if params.length>0
      pvalues=[]
      params.each do |k,v|
        if v.kind_of?(Array)
          v.each { |w| pvalues.push(w) }
        else
          pvalues.push(v)
        end
      end
      @tags=[]
      pvalues.each do |p|
        if p==pvalues.first
          @results=Tag.find(p).games
        else
          derp=Tag.find(p).games
          derp.each {|d| puts d.name }
          @results=@results&derp
        end
        @tags.push(Tag.find(p))
      end
    end
    @misc,@genres,@platforms=Tag.find_types(1..3,'children')
    @devs,@themes=Tag.find_types(4..5,'name')
    render :layout=>'main'
  end
  
  def load_new_games
    id=params[:id]
    offset=params[:offset].to_i
    puts offset
    @games=Game.order('name ASC').limit(15).offset(offset).find(:all,:conditions=>['parent=0'])
    @offset=offset+20
    puts @offset
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
  
  #---get the search results of the game name on either metacritic or gamerankings via ajax.---#
  def getsearchresults
    query=params['q'].gsub(' ','+')
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
        blurb1=s.at_css("span.blurb.blurb_collapsed").inner_html
        blurb2=s.at_css("span.blurb.blurb_expanded").inner_html
      end
      @desc=blurb1+blurb2
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
      @desc=doc.at_css("div.pod[2] > div.body > div.details").children.select{|e| e.text?}
    end
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def getparenttags
    game=Game.find(params[:parent])
    @tags=game.associations
    respond_to do |format|
      format.js {render :layout=>false}
    end
  end
  
  #---perform a query with the recommendation engine.---#
  def searchresults
    game=Game.find_by_name(params['query'])
    tags=game.tags
    games=Game.all
    @results={}
    games.each do |g|
      platforms=0
      sim=0
      cmmn=(tags&g.tags)
      cmmn.each do |c|
        platforms+=1 unless c.type_id!=3
        if c.type_id==2 and c.parent>0
          sim+=1 #subgenres are generally more specific than orphan genres and thus have a greater value in determining similarity.
        end
        sim+=c.type.value
      end
      sim=sim-(platforms-1) unless platforms<2 #if two games have more than one console in common it only counts as one. 
      @results[g]=sim unless sim<tags.length*0.7 #arbitrary, this could be better
    end
    @results=@results.sort {|a,b| b[1]<=>a[1]}
    @misc,@genres,@platforms=Tag.find_types(1..3,'children')
    @devs,@themes=Tag.find_types(4..5,'name')
    render :layout=>'main'
  end
    
  def new
    @game = Game.new
    @misc,@genres,@platforms=Tag.find_types(1..3,'children')
    @devs,@themes=Tag.find_types(4..5,'name')
    @parents=Game.find(:all,:conditions=>["type_of=1 and parent=0"])
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @game }
    end
  end

  def edit
    @game = Game.find(params[:id])
    @misc,@genres,@platforms=Tag.find_types(1..3,'children')
    @devs,@themes=Tag.find_types(4..5,'name')
    @parents=Game.find(:all,:conditions=>["type_of=1 and parent=0"])
    @associations=@game.associations
  end

      
  def create
    game=params[:game]
    @game = Game.create!(:name=>game[:name],:year=>game[:year],:rating=>game[:rating],:description=>game[:description],:parent=>game[:parent],:type_of=>game[:type_of],:tag_ids=>params['tags'])
    @tags=Tag.all
    respond_to do |format|
      if @game.valid?
        format.html { redirect_to(:action=>'new', :notice => 'Game was successfully created.') }
        format.xml  { render :xml => @game, :status => :created, :location => @game }
      else
        format.html { redirect_to( :action => "new") }
        format.xml  { render :xml => @game.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.xml
  def update
    @game = Game.find(params[:id])
    game=params[:game]
    params[:tags].each do |t|
    end
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

  def destroy
    respond_to do |format|
      if request.xhr?
        @game = Game.find(params[:game])
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
end
