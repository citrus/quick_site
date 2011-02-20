require 'test/unit'
require 'shoulda'

require_relative "../lib/settings.rb"


class ClassWithIncludeSettings  
  include Settings
end

class ClassWithExtendSettings  
  extend Settings
end


class TestSettings < Test::Unit::TestCase
  
  should "set a setting" do
    assert_equal "nothing", Settings.set(:something, "nothing")
  end
  
  should "get a setting" do
    Settings.set :this, "awesome"
    assert_equal "awesome", Settings.get(:this)
  end
  
  should "get a setting with a dynamic method" do
    Settings.set :this, "awesome"
    assert_equal "awesome", Settings.get(:this)
  end
  
  should "set multiple settings" do
    
    Settings.set :this => "that", :somthing => "nothing"
    
    assert_equal "nothing", Settings.something
    assert_equal "that",    Settings.this
  end
  
  context "when extended in a class" do
    
    setup do
      @inst = ClassWithExtendSettings.new
    end
  
    should "allow class interaction" do
      ClassWithExtendSettings.set :this, "that"
      assert_equal "that", ClassWithExtendSettings.get(:this)
      assert_equal "that", ClassWithExtendSettings.this
    end
    
  end
  
  context "when included in a class" do
  
    setup do
      @inst = ClassWithIncludeSettings.new
    end
  
    should "allow instance interaction" do
      @inst.set :this, "that"
      assert_equal "that", @inst.this
      assert_equal "that", @inst.get(:this)
    end
    
    should "have settings object" do
      @inst.set :this, "that"
      assert @inst.respond_to?(:settings)
      assert @inst.settings.is_a?(Hash)
      assert_equal "that", @inst.settings[:this]
    end
      
  end
  
end