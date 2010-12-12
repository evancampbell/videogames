class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  def index
    @misc,@genres,@platforms,@devs,@themes=Tag.find_types()
    @title='All tags'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    @tag = Tag.find(params[:id])
    @title=@tag.name
    games=@tag.games
    @games=games.clone
    games.each do |g|
      if games.exists?(g.parent)
        @games.delete(g)
      end
    end
    @games=@games.sort {|a,b| a[:name] <=> b[:name] }
    @allgames=Game.order('name ASC')
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def new
    @title='New tag'
    @tag = Tag.new
    @types=Type.all
    @tags=Tag.all
    @indie=Tag.find_by_name('Independent').id
    @theme_types=Tag.find(:all,:conditions=>['id>227 and id<232'])
    @genre_types=Tag.find_all_by_type_id_and_parent(2,0)
    @platform_types=Tag.find_all_by_type_id_and_parent(3,0)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @title='Edit tag'
    @tag = Tag.find(params[:id])
    @types=Type.all
    @tags=Tag.all
    @indie=Tag.find_by_name('Independent').id
    @theme_types=Tag.find(:all,:conditions=>['id>227 and id<232'])
    @genre_types=Tag.find_all_by_type_id_and_parent(2,0)
    @platform_types=Tag.find_all_by_type_id_and_parent(3,0)
  end

  # POST /tags
  # POST /tags.xml
  def create
    if params[:tag][:parent]==nil then params[:tag][:parent]=0 end
    if params[:tag][:parent].to_i>0
      parent=Tag.find(params[:tag][:parent])
      parent.children+=1
      parent.save
    end
    @tag = Tag.create(params[:tag])
    @tag.type_id=params[:tag][:type_id]
    @tag.save
    respond_to do |format|
      if @tag.valid?
        format.html { redirect_to(:action=>'new') }
      else
        format.html { redirect_to(:action=>'new') }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        if params[:tag][:parent].to_i>0
          parent=Tag.find(params[:tag][:parent])
          parent.children+=1
          parent.save
        end
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  def associate
    game=params[:game]
    tag=params[:tag]
    game=Game.find(game)
    if game.associations.create(:tag_id=>tag)
      render :text=>"<span class='okay' style='display:none;'>Created</span>"
    else
      render :text=>"<span class='error' style='display:none;'>Something went wrong.</span>"
    end
  end
  
  
  def dissociate
    game=params[:game]
    tag=params[:tag]
    assoc=Association.find_by_game_id_and_tag_id(game,tag)
    if assoc.destroy
      render :json=>{:status=>:ok}
    else
      render :json=>{:status=>:error}
    end
  end
  
  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    respond_to do |format|
      if request.xhr?
        @tag = Tag.find(params[:tag])
        if @tag.destroy
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
