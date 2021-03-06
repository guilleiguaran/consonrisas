#encoding: utf-8
class FacilitatorsController < ApplicationController
  before_filter :authenticate_member!, :except => [:index]
  # GET /facilitators
  # GET /facilitators.xml
  def index
    #@facilitators = Facilitator.all
    @meta_name = "Facilitadores y voluntarios de eventos y proyectos sociales en Colombia"
    @meta_desc = "Estos son los facilitadores dispuestos a ayudar con la misión de llenar de magia y alegría los corazones de los colombianos. Ellos apoyan eventos y proyectos sociales en Colombia, latinoamérica y pronto en todo el mundo. Ellos apoyan de la manera que puedan, con recursos, tiempo, transporte etc. Si no estás registrado puedes registrarte para averiguar como puedes ayudar."    
    @facilitators = Facilitator.where("name IS NOT NULL AND name != ''").order("name").page(params[:page]).per(8)
    @num_facilitators = Facilitator.count
  end
  
  def list
    @facilitators = Facilitator.all #paginate :page => params[:page], :order => 'name'
  end  

  # GET /facilitators/1
  # GET /facilitators/1.xml
  def show
    @facilitator = Facilitator.find(params[:id])
  end

  # GET /facilitators/new
  # GET /facilitators/new.xml
  def new
    @facilitator = Facilitator.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @facilitator }
    end
  end

  # GET /facilitators/1/edit
  def edit
    @facilitator = Facilitator.find(params[:id])
  end

  # POST /facilitators
  # POST /facilitators.xml
  def create
    @facilitator = Facilitator.new(params[:facilitator])

    respond_to do |format|
      if @facilitator.save
        format.html { redirect_to(@facilitator, :notice => 'Facilitator was successfully created.') }
        format.xml  { render :xml => @facilitator, :status => :created, :location => @facilitator }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @facilitator.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /facilitators/1
  # PUT /facilitators/1.xml
  def update
    @facilitator = Facilitator.find(params[:id])

    respond_to do |format|
      if @facilitator.update_attributes(params[:facilitator])
        @facilitator.populations.clear
        @facilitator.populations << Population.find(params[:population_ids]) if params[:population_ids]
        @facilitator.member.update_attributes(:use_facebook_pic=>true) if params[:use_facebook_pic] == "1"
        @facilitator.member.update_attributes(:use_facebook_pic=>false) unless params[:use_facebook_pic] == "1"
        
        @facilitator.member.update_attributes(:emailNotifications=>true) if params[:emailNotifications] == "1"
        
        @facilitator.member.update_attributes(:emailNotifications=>false) unless params[:emailNotifications] == "1"        
        
        @facilitator.member.update_attributes(:emailInstantly=>true) if params[:emailInstantly] == "1"
        
        @facilitator.member.update_attributes(:emailInstantly=>false) unless params[:emailInstantly] == "1"                
        
        @facilitator.member.update_attributes(:emailDaily=>true) if params[:emailDaily] == "1"
        @facilitator.member.update_attributes(:emailDaily=>false) unless params[:emailDaily] == "1"                

        @facilitator.member.update_attributes(:emailWeekly=>true) if params[:emailWeekly] == "1"
        @facilitator.member.update_attributes(:emailWeekly=>false) unless params[:emailWeekly] == "1"                        
               
        
#        format.html { redirect_to(@facilitator, :notice => 'Facilitator was successfully updated.') }
        format.html { redirect_to member_path(@facilitator.member), :notice => 'Tus cambios han sido guardados' }
        format.xml  { head :ok }
        format.json { render :json=>{:resp =>"ok"} }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @facilitator.errors, :status => :unprocessable_entity }
        format.json { render :json=>{:resp =>"error"} }
      end
    end
  end

  # DELETE /facilitators/1
  # DELETE /facilitators/1.xml
  def destroy
    @facilitator = Facilitator.find(params[:id])
    @facilitator.destroy

    respond_to do |format|
      format.html { redirect_to(facilitators_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def add_follower
    facilitator = Facilitator.find(params[:facilitator_id])
    followed = Facilitator.find(params[:followed_id])
    facilitator.facilitators.push(followed)
    respond_to do |format|
      format.json {render :json=> 'ok'}
    end
  end
  
  def remove_follower
    facilitator = Facilitator.find(params[:facilitator_id])
    followed = Facilitator.find(params[:followed_id])
    facilitator.facilitators.delete(followed)
    respond_to do |format|
      format.json {render :json=> 'ok'}
    end
  end  
  
  def send_msg
    resp = {"resp" => "ok"}
    facilitator = Member.find(params[:alert]["member_id"]).facilitator
    facilitator.send_msg(params[:alert])   
    respond_to do |format|
      format.json { render :json => resp }
    end
  end  
  
end
