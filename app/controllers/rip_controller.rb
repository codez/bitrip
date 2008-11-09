class RipController < ApplicationController
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update ],
         :redirect_to => { :action => :index }
         
  ID_METHODS = ['preview', 'show', 'query', 'edit']
  
  def index
    @list = Rip.find :all, :order => 'name', :conditions => ['parent_id IS NULL AND current'] 
    @rip = current 
  end
  
  def preview
    @rip ||= current
    render :action => :preview
  end
  
  def preview_temp
    @rip = Rip.new
    @rip.build_from params
    render_rip
  end
  
  def show
    @rip ||= current
    if @rip.nil?
      return redirect_to :action => :index if params[:id] == controller_name
      raise ActiveRecord::RecordNotFound, "No rip named '#{params[:id]}' found"
    end
    
    fill_params
    @rip.all_required_set? ? render_rip : query
  end
    
  # query for params before show
  def query
    @rip ||= current
    render :action => :query, :layout => 'showrip'
  end
  
  def history
    @list = Rip.find :all, 
                     :order => 'revision DESC', 
                     :conditions => ['parent_id IS NULL AND name = ?', params[:id]]
    @rip = Rip.find params[:i].to_i if params[:i].to_i > 0
    @title = "History of #{params[:id]}"
    @use_id = true
    render :action => :index
  end
  
  def edit
    @rip ||= current
    @form_action = 'update'
    render :action => :edit
  end

  def update
    @rip = new_unless_sandbox
    @rip.build_from params
    if @rip.save_revision params[:id]     
      flash[:notice] = "#{@rip.name} bitRip was saved successfully"
      redirect_to :action => 'index', :id => @rip.name
    else
      @rip.id = params[:id]   # set id because @rip is new
      render :action => 'edit'
    end 
  end
  
  def add
    @rip = Rip.new
    bitRip = @rip
    bitRip = @rip.children.build :position => 1 if params['style'] != 'single'
    @rip.start_page = 'http://' if params['style'] != 'multi'
    bitRip.bits.build :xpath => '/', :generalize => false 
  end
  
  def create
    @rip = Rip.new :revision => 1, :current => true
    @rip.build_from params
    @rip.validate_uniqueness_of_name
    if @rip.save
      flash[:notice] = "#{@rip.name} bitRip was added successfully"
      redirect_to :action => 'index', :id => @rip.name
    else
      render :action => 'add'
    end  
  end
  
  def sandbox
    params[:id] = Rip::SANDBOX_NAME
    @rip = current
    if params['style']
      add   
      @rip.name = Rip::SANDBOX_NAME
    end
  end
  
  def add_subrip
    @rip = Rip.new :position => params['subrip_index'].to_i + 1
    @rip.bits.build :xpath => '/', :generalize => false 
  end
  
  def remove_subrip
  end

  def method_missing(symbol, *args)
    if method = id_method?(symbol)
      p method
      @rip = Rip.find params[:id]
      @use_id = true
      self.send method
    else
      super(symbol, args)
    end
  end
  
  def respond_to?(symbol, include_private = false)
    super(symbol, include_private) || id_method(symbol)
  end


private

  def current
    Rip.find :first, :conditions => ['name = ? AND current', params[:id]]
  end

  def render_rip
    message = Scrubator.new(@rip).ripit 
    if message.nil?
      render :action => :show, :layout => 'showrip'
    else 
      render :controller => :message, :action => :plain, :id => message
    end
  end
  
  def fill_params
    @rip.navi_actions.each do |navi|
      navi.form_fields.each do |field|
        field.value = params[field.name] if params[field.name]
      end
    end
  end
  
  def id_method?(symbol)
    (symbol =~ /^(.*)_id$/ && ID_METHODS.include?($1)) ? $1 : nil
  end

  def new_unless_sandbox
    prev = Rip.find(params[:id])
    (prev && prev.name == 'sandbox') ? prev : Rip.new
  end
end
