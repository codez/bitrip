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
    
    render_rip
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
  
  
private

  def render_rip
    @output = Scrubator.new(@rip).ripit 
    render :action => 'show', :layout => 'showrip'
  end

end
