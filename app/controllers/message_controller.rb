class MessageController < ApplicationController
  
  layout nil
  
  def plain
    @message = msg params[:id]
  end
  
  
end
