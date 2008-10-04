class RipController < ApplicationController
  
  def index
    @list = Rip.find :all, :order => 'name'
    @rip = Rip.find params[:id] if params[:id]
  end
  
  def preview
    @rip = Rip.find params[:id]
  end
  
  def preview_temp
    @rip = Rip.new
    @rip.build_from params
    render_rip
  end
  
  def show
    @rip = Rip.find_by_name params[:id]
    if @rip.nil?
      raise ActiveRecord::RecordNotFound, "No rip named '#{params[:id]}' found"
    end
    
    fill_params
    @rip.all_required_set? ? render_rip : query
  end
  
  def edit
    @rip = Rip.find params[:id]
    @form_action = 'update'
  end

  def update
    @rip = Rip.find params[:id]
    @rip.build_from params
    # TODO: should validate all first?
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was saved successfully"
      redirect_to :action => 'index', :id => @rip
    else
      render :action => 'edit'
    end  
  end
  
  def add
    @rip = Rip.new
    @rip.bits.build :xpath => '/'
  end
  
  def create
    @rip = Rip.new 
    @rip.build_from params
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was added successfully"
      redirect_to :action => 'index', :id => @rip
    else
      render :action => 'add'
    end  
  end
  
  def query
    @rip ||= Rip.find params[:id]
    render :action => 'query', :layout => 'showrip'
  end
  
  
private

  def render_rip
    Scrubator.new(@rip).ripit 
    render :action => 'show', :layout => 'showrip'
  end
  
  def fill_params
    @rip.navi_actions.each do |navi|
      navi.form_fields.each do |field|
        field.value = params[field.name] if params[field.name]
      end
    end
  end

end
