require 'helper'

class TestSite < Test::Unit::TestCase

  def setup
    set :site_root, settings.root + "/test/sites"
    FileUtils.rm_r settings.site_root if Dir.exists?(settings.site_root)
  end
  
  should "return array of sites" do
    assert_equal Array, Site.all.class
    assert_equal 0, Site.all.length
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
      @expected_root = settings.site_root + "/testing_site"
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
    
    should "build all necessary parts" do
      @site.save
      assert Dir.exists?(@expected_root + "/public")
      assert Dir.exists?(@expected_root + "/views")
      assert File.exists?(@expected_root + "/config.yml")
      assert File.exists?(@expected_root + "/public/stylesheets/styles.css")
      assert File.exists?(@expected_root + "/views/index.haml")
      assert File.exists?(@expected_root + "/views/layout.haml")
    end
    
    should "create git repository" do
      @site.save
      assert Dir.exists?(@expected_root + "/.git")
      assert File.exists?(@expected_root + "/.gitignore")
    end
    
  end
  
  context "an existing site" do
  
    setup do
      @existing_site = Site.new("Testing Site").save
    end
   
    should "find existing site" do
      @site = Site.find("Testing Site")
      assert_equal @existing_site, @site
    end
    
    should "not overwrite existing site" do
      @site = Site.new("Testing Site")
      assert !@site.valid?
    end
    
  end
  
end