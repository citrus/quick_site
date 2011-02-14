require 'helper'

class TestSite < Test::Unit::TestCase

  def setup
    puts "SETUP"
  end
  
  context "a new site" do
  
    setup do
      @site = Site.new("Testing Site")
    end
    
    should "not be valid" do
      assert !@site.valid?
    end
    
  end
  
end