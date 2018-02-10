require 'twilio-ruby'
include ActionView::Helpers::NumberHelper

class TwilioLogic

  def initialize
    @client ||= Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    @twilio_number = "+18147534377"
    #@james_number = '+12195774008'
    @james_number = '+8145024125'
  end

  def send_outgoing_message(recruit, message)
    @client.messages.create(
      from: @twilio_number,
      to: recruit.phone_number,
      body: message.body
    )
  end

  def send_alert_message(from_number="", recruit_name="")
    @client.messages.create(
      from: @twilio_number,
      to: @james_number,
      body: "New Message From " + from_number + recruit_name
    )
  end

	def reply(params, request)

    from_number = params["From"]
    message_body = params["Body"]
    recruit = Recruit.find_by(phone_number: from_number)
    if recruit == nil
      # make a GeneralMessage not assigned to any recruit
      send_alert_message(from_number)
    else
      Message.create(body: message_body, recruit_id: recruit.id, sent_by_recruit: true)
      send_alert_message(recruit.name)
    end

  end

end