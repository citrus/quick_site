#require 'helper'

require_relative './helper.rb'

class TestDeployer < Test::Unit::TestCase

  def setup
    Settings.set :site_root, Settings.root + "/test/sites"
    FileUtils.rm_r Settings.site_root if Dir.exists?(Settings.site_root)  
    @site = Site.new("Testing Site").save
    @deployer = Deployer.new(@site)
  end
  
  should "create a new deployer" do
    assert_equal @deployer.site, @site
  end
  
  should "compress into tar file" do
    assert @deployer.send(:compress)
    assert File.exists?(File.join(@site.root, @deployer.zip))
  end
  
  should "upload file to remote" do
    @deployer.send(:compress)
    @deployer.send(:upload)
    #assert File.exists?(File.join(@site.root, @deployer.zip))
  end
  
  

end  