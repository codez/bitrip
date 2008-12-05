require File.dirname(__FILE__) + '/../profile_test_helper'

class ProfileTest < ActionController::TestCase
  include RubyProf::Test
  
  tests RipController
 

  def test_index
    setup_controller_request_and_response
    get :index
    assert_response :success
  end
    
  def test_edit_sandbox
    setup_controller_request_and_response
    get :sandbox
    assert_response :success
  end
  
end   
