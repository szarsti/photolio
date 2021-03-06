require 'test_helper'

class Admin::PhotosControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper

  def setup
    super
    login_as users(:aaron)
  end

  def test_should_get_index
    get :index, :site_id => 1
    assert_response :success
    assert_equal 4, assigns(:photos).size
  end

  def test_should_get_new
    get :new, :site_id => 1
    assert_response :success
  end

  def test_should_create_photo
    file_path = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/files/x.png")
    @temp_dir = File.join(RAILS_ROOT, 'tmp', "test_#{rand.to_s[2..-1]}")
    FileUtils.mkdir_p(@temp_dir)
    
    Photo.instance_variable_set :@public_path, @temp_dir
    assert_difference('Photo.count') do
      f = File.open(file_path, "r")
      post :create, :site_id => 1, :photo => { :file => f }
      f.close
    end
    Photo.instance_variable_set :@public_path, nil

    created_path = File.expand_path(@temp_dir + "/polinostudio/files/photos/x.png")
    assert((File.exists? created_path), "Does not exists: " + created_path)
    assert_redirected_to admin_site_photos_path(assigns(:site))

    FileUtils.rm_rf @temp_dir
  end

  def test_should_get_include
    get :include, :site_id => sites(:polinogroup).id
    assert_equal [photos(:p1), photos(:p6)], assigns(:photos)
    assert_response :success
  end

  def test_should_add_externals
    assert_difference('sites(:polinogroup).photos.count') do
      post( :add_externals, 
            :site_id => sites(:polinogroup).id , 
            :ids => [photos(:p1).id]
            )
    end
    assert_equal [photos(:p1), photos(:p2), photos(:p3)], sites(:polinogroup).external_photos
    assert_redirected_to admin_site_photos_path(assigns(:site))
  end

  def test_should_remove_external
    assert_difference('sites(:polinogroup).photos.count', -1) do
      post( :remove_external, 
            :site_id => sites(:polinogroup).id , 
            :id => [photos(:p2).id]
            )
    end
    assert_equal [photos(:p3)], sites(:polinogroup).external_photos
    assert_redirected_to admin_site_photos_path(assigns(:site))
  end

  def test_should_show_photo
    get :show, :site_id => 1, :id => photos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :site_id => 1, :id => photos(:one).id
    assert_response :success
  end

  def test_should_update_photo
    put :update, :site_id => 1, :id => photos(:one).id, :photo => { :file_name => 'new_name'}
    assert_redirected_to admin_site_photo_path(assigns(:site), assigns(:photo))
  end

  def test_should_destroy_photo
    assert_difference('Photo.count', -1) do
      delete :destroy, :site_id => 1, :id => photos(:one).id
    end

    assert_redirected_to admin_site_photos_path
  end
end
