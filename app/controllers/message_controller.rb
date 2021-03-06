class MessageController < ApplicationController
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :delete ],
         :redirect_to => { :action => :manage }
         
  before_filter :authenticate, :except => [:plain, :faq, :loading, :login]
  
  caches_page :faq, :loading, :plain
  
  def plain
    @message = msg params[:id]
    render :action => :plain, :layout => false
  end
  
  def faq
    set_list Message::CONTEXT_FAQ
    render :action => :faq, :layout => 'application'
  end
  
  def loading
    render :action => :loading, :layout => false
  end
  
  def manage
    set_list params['context']
  end
  
  def add
    @message = Message.new
    @message.context = params['context']
  end
  
  def create
    @message = Message.new params['message']
    @message.position = Message.maximum(:position, :conditions => ['context = ?', @message.context]) + 1
    if @message.save
      expire_page :action => :faq if @message.context == Message::CONTEXT_FAQ
      flash[:notice] = 'The message has been created.'
      redirect_to :action => :manage, :context => @message.context
    else  
      render :action => :add
    end
  end
  
  def edit
    @message = Message.find params['id']
  end
  
  def update
    @message = Message.find params['id']
    if @message.update_attributes params['message']
      expire_page :action => :faq if @message.context == Message::CONTEXT_FAQ
      expire_page :action => :plain, :id => @message.key if @message.context == Message::CONTEXT_HELP
      @message.cache_store
      flash[:notice] = 'The message has been saved.'
      redirect_to :action => :manage, :context => @message.context
    else  
      render :action => :edit
    end
  end
  
  def delete
    @message = Message.find params['id']
    @message.destroy
    expire_page :action => :faq if @message.context == Message::CONTEXT_FAQ
    flash[:notice] = 'The message has been deleted.'
    redirect_to :action => :manage, :context => @message.context
  end
  
  def order
    position = 0
    params['messages'].each do |id|
      Message.find(id).update_attribute :position, position
      position += 1
    end
  end
  
  def login
    if params['login'] && Message.check_login(params['login'])
      session[:loggedin] = true
      redirect_to :action => :manage
    end
  end
  
private

  #Filter for check if user is logged in or not
  def authenticate
    unless session[:loggedin]
      redirect_to :action => 'login'
      return false
    end
    return true
  end 

  def set_list(context)
    @list = Message.find :all, 
                         :conditions => ['context = ?', context], 
                         :order => 'position'
  end
  
end
