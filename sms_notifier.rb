require 'net/smtp'

class SmsNotifier
  attr_accessor :recipients

  def initialize(project = nil)
    @recipients = []
  end

  def build_finished(build)
    return if @recipients.empty? or not build.failed? 
    notify "#{build.project.name} build #{build.label} failed", build.project.name
  end

  def build_fixed(build, previous_build)
    return if @recipients.empty?
    notify "#{build.project.name} build #{build.label} fixed", build.project.name
  end
  
  private
	def notify(message, project)
		sms = Sms.new('cruise@thoughtworks.com', "Cruise Status: #{project}", message, @recipients)
		sms.post_message()
	end
  
end

class Sms

  Sms::MESSAGE_MAX = 160
  attr_reader :smtp
  
  def initialize(sender, subject, message, recipients)
    @smtp = smtp_connection(ActionMailer::Base.smtp_settings[:address], 
                           ActionMailer::Base.smtp_settings[:port])
    @sender=sender
  	@subject=subject
  	@recipients=recipients.map{|x| x.gsub(/\D/,'')}
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
      begin
			smtp_send(ActionMailer::Base.smtp_settings[:domain], 
                ActionMailer::Base.smtp_settings[:user_name],
                ActionMailer::Base.smtp_settings[:password], message, recipient)
      CruiseControl::Log.event("Sent sms to #{@recipients.size == 1 ? '1 person' : '#{@recipients.size} people'}", :debug)
      rescue OpenSSL::SSL::SSLError => e
        CruiseControl::Log.event('SSLError: perhaps the smtp server disconnected prematurely... ' + 
                                  e.message + ' : ' + e.backtrace.join("\n") )
      rescue => e
        settings = ActionMailer::Base.smtp_settings.map { |k,v| "  #{k.inspect} = #{v.inspect}" }.join("\n")
        CruiseControl::Log.event("Error sending e-mail - current server settings are :\n#{settings}", :error)
      raise
      end
		end
	end
	
	private
	
	def smtp_connection(server, port)
  	Net::SMTP.new(server, port)
	end
	
	def smtp_send(domain, user, pass, message, recipient)
    @smtp.start(domain, user, pass, :plain) do |smtp|
      smtp.send_message(message , @sender, "#{recipient}@teleflip.com")
    end
	end

end

Project.plugin :sms_notifier
