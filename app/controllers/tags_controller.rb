class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  def index
    @misc,@genres,@platforms=Tag.order('children ASC').find_types(1..3,'children')
    @devs,@themes=Tag.order('children ASC').find_types(4..5,'name')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new
    @types=Type.all
    @tags=Tag.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
    @types=Type.all
    @tags=Tag.all
  end

  # POST /tags
  # POST /tags.xml
  def create
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
        format.html { redirect_to(:action=>'new', :notice => 'Tag was successfully created.') }
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
        format.html { redirect_to(:action=>'index', :notice => 'Tag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
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
