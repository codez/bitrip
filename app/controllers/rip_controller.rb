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
    build_from_form
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
    build_from_form
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
    build_from_form
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

  def build_from_form       
    @rip.attributes = params[:rip]
    
    @rip.bits.clear
    pos = 1
    params[:bit_order].split(',').each do |index|
      bit_attrs = params[:bits][index]
      if bit_attrs
        bit_attrs[:position] = pos
        @rip.bits.build(bit_attrs)
        pos += 1
      end  
    end
  end

end
