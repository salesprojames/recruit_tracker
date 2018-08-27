require 'twilio-ruby'
include ActionView::Helpers::NumberHelper

class TwilioLogic
  skip_before_action :verify_authenticity_token

  def initialize
    @client ||= Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    @twilio_number = "+18147534377"
    @james_number = '+12195774008'
  end

  def send_outgoing_message(recruit, message)
    @client.messages.create(
      from: @twilio_number,
      to: recruit.phone_number,
      body: message.body
    )
  end

  def send_alert_message(recruit)
    @client.messages.create(
      from: @twilio_number,
      to: @james_number,
      body: "New Message From " + recruit.name + "\n" + "https://recruits-tracker.herokuapp.com/recruits/#{recruit.id}/messages"
    )
  end

  def send_alert_general_message(from_number)
    @client.messages.create(
      from: @twilio_number,
      to: @james_number,
      body: "New Message From " + from_number + "\n" + "https://recruits-tracker.herokuapp.com/general_messages"
    )
  end

	def reply(params, request)

    from_number = params["From"]
    message_body = params["Body"]
    recruit = Recruit.find_by(phone_number: from_number)
    if recruit == nil
      GeneralMessage.create(body: message_body, number: from_number)
      send_alert_general_message(from_number)
    else
      Message.create(body: message_body, recruit_id: recruit.id, sent_by_recruit: true)
      send_alert_message(recruit)
    end

  end

end
