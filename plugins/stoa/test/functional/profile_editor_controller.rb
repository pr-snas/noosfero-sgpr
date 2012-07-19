require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/my_profile/profile_editor_controller'

# Re-raise errors caught by the controller.
class ProfileEditorController; def rescue_action(e) raise e end; end

class ProfileEditorTest < ActionController::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + '/config.yml'))['salt']

  def setup
    @controller = ProfileEditorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = User.create(:login => 'test_user', :email => 'test_user@example.com', :password => 'test', :password_confirmation => 'test').person
    login_as(@person.identifier)
    Environment.default.enable_plugin(StoaPlugin.name)
    db = Tempfile.new('stoa-test')
    ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => db.path}
  end

  attr_accessor :person

  should 'show usp_id field if person did not filled it' do
    get :edit, :profile => person.identifier
    assert_match /USP number/, @response.body
  end

  should 'not show usp_id field if person already filled it' do
    person.usp_id = 12345
    person.save
    get :edit, :profile => person.identifier
    assert_no_match /USP number/, @response.body
  end

  should 'not display field if profile is an organization' do
    organization = fast_create(Organization)
    get :edit, :profile => organization.identifier
    assert_no_match /USP number/, @response.body
  end

  should 'display error if usp_id does not match with supplied confirmation' do
    StoaPlugin::UspUser.stubs(:matches?).returns(false)
    post :edit, :profile => person.identifier, :profile_data => {:usp_id => 12345678}, :confirmation_field => 'cpf', :cpf => 99999999
    assert assigns(:profile_data).errors.invalid?(:usp_id)
  end

  should 'save usp_id if everyhtings is ok' do
    StoaPlugin::UspUser.stubs(:matches?).returns(true)
    post :edit, :profile => person.identifier, :profile_data => {:usp_id => 12345678}, :confirmation_field => 'cpf', :cpf => 99999999
    person.reload
    assert_equal '12345678', person.usp_id
  end

end