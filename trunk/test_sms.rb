require 'test/unit'
require 'project'
require 'sms_notifier'

class Test_Sms < Test::Unit::TestCase
  def setup
    @sms_sender = "sender"
    @sms_subject = "subject"
    @sms_message = "message"
    @sms = Sms.new(@sms_sender, @sms_subject,@sms_message,"recipients")
    @empty_sms = Sms.new("","","","")
  end
  
  def test_message_size_is_length_of_subject_plus_message_plus_sender
    correct_message_size = @sms_sender.length + @sms_subject.length + @sms_message.length
    assert_equal(correct_message_size, @sms.size_is)
  end
  
  def test_zero_message_size_message_length_is_correct
    assert_equal(0, @empty_sms.size_is)
  end
  
  def test_message_sizes_are_limited_if_message_size_greater_than_max
    big_sms = Sms.new("","",message_of_length((Sms::MESSAGE_MAX) + 1),"")
    assert_equal(Sms::MESSAGE_MAX - 1, big_sms.size_is)
  end
  
  def test_message_size_doesnt_change_for_message_size_smaller_than_max
    small_sms = Sms.new("","",message_of_length(1),"")
    assert_equal(1, small_sms.size_is)
  end
  
  private
  def message_of_length(length)
    dummy_character = "x"
    message = ""
    (1..length).each{|i| message << dummy_character}
    message
  end
end
