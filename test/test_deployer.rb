#require 'helper'

require_relative './helper.rb'

class TestDeployer < Test::Unit::TestCase

  def setup
    Settings.set :site_root, Settings.root + "/test/sites"
    Settings.set :use_git, true
    
    FileUtils.rm_r Settings.site_root if Dir.exists?(Settings.site_root)  
    @site = Site.new("Testing Site").save
    
    @deployer = Deployer.new(@site)
    @release_path = File.join(@site.config[:remote_root], "releases", @deployer.key)
  end
  
  should "create a new deployer" do
    assert_equal @deployer.site, @site
  end
  
  should "compress into tar file" do
    assert @deployer.send(:compress)
    assert File.exists?(File.join(@site.root, @deployer.tar))
  end
  
  should "upload file to remote" do
    assert @deployer.send(:compress)
    assert @deployer.send(:upload)
    assert @deployer.remote_exists?(File.join(@release_path, @deployer.tar))
  end
  
  should "unzip uploaded tar file" do
    assert @deployer.send(:compress)
    assert @deployer.send(:upload)
    assert @deployer.send(:unzip)
    
    # remote tar file deleted after unzip?
    assert !@deployer.remote_exists?(File.join(@release_path, @deployer.tar))
    
    # unzipped exists
    assert @deployer.remote_exists?(File.join(@release_path, "public"))
  end
  
  should "symlink release path to current path" do
    assert @deployer.send(:compress)
    assert @deployer.send(:upload)
    assert @deployer.send(:unzip)
    assert @deployer.send(:symlink)
    assert @deployer.remote_exists?(File.join(@site.config[:remote_root], 'current'))
  end
  
  should "run entire ssh deploy" do
    Settings.set :use_git, false
    assert @deployer.deploy!
    assert @deployer.remote_exists?(File.join(@site.config[:remote_root], 'current'))
  end
  
  should "run entire git deploy" do
    assert @deployer.deploy!
    assert @deployer.remote_exists?(File.join(@site.config[:remote_root], 'current'))
  end
  
end