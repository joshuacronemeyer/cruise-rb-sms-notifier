require 'test/unit'
require 'cruise_stubs'
require 'sms_notifier'
require 'rubygems'
require 'net/smtp'
require 'mocha'

class TestSmsNotifier < Test::Unit::TestCase
  
  def test_sms_notifier_doesnt_notify_on_build_failure
    #simulate the cruise_config.rb initializing recipients
    sms_notifier = SmsNotifier.new
    sms_notifier.recipients = ["555-555-5555"]
    build = Object.new
    build.expects(:failed?).returns(false)
    assert(!sms_notifier.build_finished(build))
  end

  def test_sms_notifier_doesnt_notify_if_no_recipients
    sms_notifier = SmsNotifier.new
    assert(!sms_notifier.build_finished(Object.new))

    #also check the build_fixed method
    sms_notifier = SmsNotifier.new
    build = Object.new
    assert(!sms_notifier.build_fixed(build, build))

  end

  def test_sms_notifier_notifies_on_failure
    sms_notifier = SmsNotifier.new
    sms_notifier.recipients = ["555-555-5555","666-666-6666"]
    build = Object.new
    project = Object.new
    project.expects(:name).returns("myproject")
    project.expects(:name).returns("myproject")
    build.expects(:failed?).returns(true)
    build.expects(:project).returns(project)
    build.expects(:project).returns(project)
    build.expects(:label).returns("1")
    sms_notifier.expects(:notify)
    sms_notifier.build_finished(build)
  end

  def test_notifies_on_build_fix
    sms_notifier = SmsNotifier.new
    sms_notifier.recipients = ["555-555-5555","666-666-6666"]
    build = Object.new
    project = Object.new
    project.expects(:name).returns("myproject")
    project.expects(:name).returns("myproject")
    build.expects(:project).returns(project)
    build.expects(:project).returns(project)
    build.expects(:label).returns("1")
    sms_notifier.expects(:notify)
    sms_notifier.build_fixed(build, build)   
  end

end
