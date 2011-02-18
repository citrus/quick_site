require 'helper'

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  
  def setup
    set :site_root, settings.root + "/test/sites"
    FileUtils.rm_r settings.site_root if Dir.exists?(settings.site_root)  
  end

  should "get homepage" do
    get '/'
    assert last_response.ok?    
    assert last_response.body.include?("Quick Site")
    assert last_response.body.include?("New Site")
    assert last_response.body.include?("Site Root: #{settings.site_root}")
    assert last_response.body.include?("Sites")
  end

  should "post and create new site" do
    post '/create', :name => 'Testing Site'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 200, last_response.status
    assert_equal 'http://example.org/sites/testing_site', last_request.url
  end

  should "throw a 404" do
    get '/some-non-existant-page'
    assert_equal 404, last_response.status
  end
  
  should "redirect to homepage" do
    get '/sites/non-existant-site'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal 'http://example.org/', last_request.url
    assert_equal 200, last_response.status
  end
  
  
  context "an existing site" do
    
    setup do
      @site = Site.new("Testing Site").save
    end
        
    should "get found" do
      get '/sites/testing_site'
      assert last_response.ok?
      
      puts last_response.body
      
      assert last_response.body.include?("Testing Site")
    end
    
    should "create new page" do
      get '/sites/testing_site/some_new_page'
      assert last_response.ok?
      assert last_response.body.include?("Some New Page")
      assert last_response.body.include?("some_new_page.haml")
      assert File.exists?(File.join(@site.view_path, 'some_new_page.haml'))
    end
    
    should "create nested page" do
      get '/sites/testing_site/some/new/nested/page'
      assert last_response.ok?
      assert last_response.body.include?("Some New Nested Page")
      assert last_response.body.include?("some_new_nested_page.haml")
      assert File.exists?(File.join(@site.view_path, 'some_new_nested_page.haml'))
    end
    
  end
  
end