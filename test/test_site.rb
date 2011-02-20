require 'helper'

class TestSite < Test::Unit::TestCase

  def setup
    Settings.set :site_root, Settings.root + "/test/sites"
    FileUtils.rm_r Settings.site_root if Dir.exists?(Settings.site_root)
  end
  
  should "return array of sites" do
    assert_equal Array, Site.all.class
    assert_equal 0, Site.all.length
    @site = Site.new("Testing Site").save
    assert_equal 1, Site.all.length
  end
  
  
  context "an empty new site" do
  
    setup do
      @site = Site.new("")
    end
    
    should "not be valid" do
      assert !@site.valid?
    end
    
    should "not save" do
      assert !@site.save
      assert_equal 0, Site.all.length
    end
    
  end
  
  
  context "a valid new site" do
  
    setup do
      @site = Site.new("Testing Site")
      @expected_root = Settings.site_root + "/testing_site"
    end
    
    should "be new" do
      assert @site.new?
    end
    
    should "be valid" do
      assert @site.valid?
    end
    
    should "save and build" do
      assert @site.save, "Validates, saves & builds"
      assert Dir.exists?(@expected_root)
      assert_equal 1, Site.all.length
    end

    context "that is saved saved" do
  
      setup do
        @site.save
      end
      
      should "build all necessary parts" do
        assert Dir.exists?(@expected_root + "/public")
        assert Dir.exists?(@expected_root + "/views")
        assert File.exists?(@expected_root + "/config/application.yml")
        assert File.exists?(@expected_root + "/public/stylesheets/styles.css")
        assert File.exists?(@expected_root + "/views/index.haml")
        assert File.exists?(@expected_root + "/views/layout.haml")
      end
      
      #should "apply mustache to deploy script" do
      #  rb = File.read(File.join(@site.root, "config/deploy.rb"))
      #  assert rb.include?(@site.dir_name)
      #end
      
      should "create git repository" do
        assert Dir.exists?(@expected_root + "/.git")
        assert File.exists?(@expected_root + "/.gitignore")
      end
      
    end  
  end
  
  
  context "an existing site" do
  
    setup do
      @existing_site = Site.new("Testing Site").save
    end
   
    should "be found" do
      @site = Site.find("Testing Site")
      assert_equal @existing_site, @site
    end
    
    should "not overwrite existing site" do
      @site = Site.new("Testing Site")
      assert !@site.valid?
      assert !@site.save
    end
    
    should "create a new page" do
      view = @existing_site.haml('some_page')
      assert view.is_a?(Symbol)
      assert File.exists?(@existing_site.root + "/views/some_page.haml")
    end
    
    should "create a new nested page" do
      view = @existing_site.haml('some/nested/page')
      assert view.is_a?(Symbol)
      assert File.exists?(@existing_site.root + "/views/some/nested/page.haml")
    end
    
  end
  
end