class EventsController < ApplicationController
  before_filter :authenticate_member!, :except => [:index, :show, :gallery, :all_events]
  # GET /events
  # GET /events.xml
  def index
#    @events = Event.all
    @events = Event.order("date DESC").page(params[:page]).per(8)
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @meta_event_name = @event.name if @event.name
    @meta_event_desc = @event.desc[0, 350] if @event.desc
    if @event.pic(:thumb) and @event.pic(:thumb).include? "s3"
      @meta_event_img = @event.pic(:thumb)
    else
      @meta_event_img = "http://www.consonrisas.co/" << @event.pic.url(:thumb)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end
  
  def show_gallery
    @event = Event.find(params[:event_id])
    render :partial => "photo_gallery", :layout => false
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
#    5.times {@event.photos.build}
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
#    5.times {@event.photos.build}    
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    if params[:fundation_id] and params[:fundation_id] != ""
      fundation = Fundation.find(params[:fundation_id]) 
      @event.fundations.push(fundation)
    end
    respond_to do |format|
      if @event.save
        EventAdmin.create(:member_id =>params[:member_id], :event_id => @event.id, :active=>true, :is_owner=>true)
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    resp = {"resp" => "ok"}
    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
      format.json { render :json=>resp}
    end
  end
  
  def all_events
    @events = Event.order("date DESC").limit(30)
    respond_to do |format|
      format.html {render :layout=> false}
      format.json {render :json=>@events}
    end    
  end
  
  def add_provider 
    @event = Event.find(params[:event_id])
    @provider = Provider.find(params[:provider_id])
    @event.providers.push(@provider)
    redirect_to event_path(@event)
  end
  
  def add_providers
    resp = {"resp" => "ok"}
    if params[:providers_ids].empty?
      resp = {"resp" => "error", "message" => "Debes escoger al menos un Proveedor"}
    else
      @event = Event.find(params[:event_id])
      @event.add_providers params[:providers_ids]
    end
    respond_to do |format|
      format.js {head:ok}
      format.html {redirect_to event_path(@event)}
      format.json { render :json=>resp}
    end
  end    
    
  def add_facilitator
    @event = Event.find(params[:event_id])
    @facilitator = Facilitator.find(params[:facilitator_id])

    unless current_member.id == @facilitator.member.id
      Alert.create(:member_id=> @facilitator.member.id, :news=> I18n.t('events.facilitator_invite'), :link=>@event.id) 
      begin
        EventInvitation.invite_facilitator(@facilitator.member, @event).deliver unless @event.facilitators.exists?(@facilitator.id)
      rescue
        Feedback.create(:message=>"Error sending mail #{$!}")
      end
    end
    
    @event.facilitators.push(@facilitator)
    respond_to do |format|
      format.js {head:ok}
      format.html {redirect_to event_path(@event)}
    end
  end
  
  def add_facilitators
    resp = {"resp" => "ok"}
    if params[:facilitators_ids].empty?
      resp = {"resp" => "error", "message" => "Debes escoger al menos un facilitador a invitar"}
    else
      @event = Event.find(params[:event_id])
      @event.add_facilitators params[:facilitators_ids]
    end
    respond_to do |format|
      format.js {head:ok}
      format.html {redirect_to event_path(@event)}
      format.json { render :json=>resp}
    end
  end
  
  def add_fundation
    @event = Event.find(params[:event_id])
    @fundation = Fundation.find(params[:fundation_id])
    @event.fundations.push(@fundation)
    redirect_to event_path(@event)
  end  
  
  def add_fundations
    resp = {"resp" => "ok"}
    if params[:fundations_ids].empty?
      resp = {"resp" => "error", "message" => "Debes escoger al menos un Proyecto Social"}
    else
      @event = Event.find(params[:event_id])
      @event.add_fundations params[:fundations_ids]
    end
    respond_to do |format|
      format.js {head:ok}
      format.html {redirect_to event_path(@event)}
      format.json { render :json=>resp}
    end
  end  
  
  def remove_provider 
    @event = Event.find(params[:event_id])
    @provider = Provider.find(params[:provider_id])
    @event.providers.delete(@provider)
    redirect_to event_path(@event)
  end
  
  def remove_facilitator
    @event = Event.find(params[:event_id])
    @facilitator = Facilitator.find(params[:facilitator_id])
    @event.facilitators.delete(@facilitator)
    respond_to do |format|
      format.js {head:ok}
    end
  end
  
  def remove_fundation
    @event = Event.find(params[:event_id])
    @fundation = Fundation.find(params[:fundation_id])
    @event.fundations.delete(@fundation)
    redirect_to event_path(@event)
  end    
  
  
  def add_show
    @event = Event.find(params[:event_id])
    @show = Show.find(params[:show_id])
    @event.shows.push(@show)
    redirect_to event_path(@event)    
  end
  
  def ask_admin
    event = Event.find(params[:event_id])
    event.ask_admin params[:member_id] if params[:member_id].to_s != "-1" and params[:member_id].to_s != ""
    event.ask_admin_by_mail params[:mail] if params[:mail].to_s != "mail" and params[:mail].to_s != ""
    respond_to do |format|
      format.js {head :ok}
    end
  end  
    
end
