class SmsNotifier
  
  def initialize(project = nil)
    @phones = ['xxx-xxx-xxxx']#eventually, this will be configureable
  end

  def build_finished(build)
    return if @phones.empty? or not build.failed?
    notify "#{build.project.name} build #{build.label} failed", build.project.name
  end

  def build_fixed(build, previous_build)
    return if @phones.empty?
    notify "#{build.project.name} build #{build.label} fixed", build.project.name
  end
  
  private
	def notify(message, project)
		sms = Sms.new('cruise@thoughtworks.com', "Cruise Status: #{project}", message, @phones)
		sms.post_message()
	end
  
end

class Sms

  MESSAGE_MAX = 160

  def initialize(sender, subject, message, recipients)
    @sender=sender
  	@subject=subject
  	@recipients=recipients
  	@message=message
  	limit_message_size()
  end

  def size_is()
    return @subject.size + @message.size + @sender.size
  end

  def limit_message_size()
    if size_is > MESSAGE_MAX
      remaining_message_capacity = MESSAGE_MAX - (@sender.size + @subject.size)
      @message = @message[0,remaining_message_capacity-1]
    end
  end

	def post_message()
		@recipients.each do |recipient|
    	message = "From: <#{@sender}>\nTo: <#{recipient}@teleflip.com>\nSubject: #{@subject}\n\n#{@message}"
			smtp = Net::SMTP.new("smtp.gmail.com", 587)
    	smtp.start("thoughtworks.com", "user", "pass", :plain) do |smtp|
  			smtp.send_message(message , @sender, "#{recipient}@teleflip.com")
    	end
		end
	end

end

Project.plugin :sms_notifier
