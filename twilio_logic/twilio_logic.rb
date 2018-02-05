require 'twilio-ruby'

class TwilioLogic

  def initialize
    @client ||= Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    @from_number = params["From"]
    @twilio_number = params["To"]
    @merchant = Merchant.find_by(phone_number: @twilio_number)
  end

  def send_outgoing_message(send_outgoing_message_merchant, message)
    if check_if_message_sent_in_last_hour(send_outgoing_message_merchant)
      send_outgoing_message_merchant.customers.each do |customer|
        if customer.permission_to_text
          client.messages.create(
            from: send_outgoing_message_merchant.phone_number,
            to: customer.phone_number,
            body: message.body
          )
        end
      end
    else
      redirect_to :root_path, notice: "You Already Sent Out A Message In The Past Hour"
    end
  end

	def reply(params, request)

    message_body = params["Body"]
    save_message_body(request, message_body)
    merchant_user = MerchantUser.find_by(phone_number: from_number)

    if merchant_user.present?

      role = MerchantRole.find_by(id: merchant_user.merchant_role_id)

      if role.merchant_permissions.include?( MerchantPermission.find_by(id: 27) )
          send_response(request, role, message_body)
          set_timeout() if request.session[:confirmation_sent]
      else
        send_insufficient_permissions_response(role)
      end
    else
      if %w{START SUBSCRIBE UNSTOP}.include?(message_body.upcase)
        send_successful_subscribed_message()
      elsif %w{STOP UNSUBSCRIBE}.include?(message_body.upcase)
        send_successful_unsubscribed_message()
      else
        send_fail_response()
      end
    end

  end


  def send_response(request, user_role, message_body)
    set_session_variable(request)

    if request.session[:confirmation_sent]
      if message_body.downcase == "yes"
        send_out_message(request, user_role)
        send_success_response(request, user_role)
        request.session[:message_body] = ""
      else
        send_cancel_response(user_role)
        request.session[:message_body] = ""
      end
      request.session[:confirmation_sent] = false
    else
      send_confirmation(user_role)
      request.session[:confirmation_sent] = true
    end
  end

  def check_if_message_sent_in_last_hour
    merchant.timeout_end > Time.now.to_s
  end

  def send_permission_to_text_request(customer)
    client.messages.create(
        from: customer.merchant.phone_number,
        to: customer.phone_number,
        body: "Text START to receive special deals delivered right to your phone by #{customer.merchant.name}!\nReply STOP at any time to stop, HELP to help. Msg & Data Rates apply."
      )
  end

  def send_successful_subscribed_message()
    customer = merchant.customers.where(phone_number: from_number).first_or_initialize
    customer.phone_number = from_number if customer.phone_number.nil?
    customer.permission_to_text = true
    customer.save

    client.messages.create(
        from: merchant.phone_number,
        to: customer.phone_number,
        body: "Thank you for subcribing to #{merchant.name}!"
      )
  end

  def send_successful_unsubscribed_message()
    if merchant.customers.include?(Customer.find_by(merchant_id: merchant.id, phone_number: from_number))
      customer = Customer.find_by(merchant_id: merchant.id, phone_number: from_number)
      customer.permission_to_text = false
      customer.save
    else
    end
  end

  def send_too_many_messages_error(user_role)
    client.messages.create(
        from: merchant.phone_number,
        to: from_number,
        body: "You Already Sent Out A Message In The Past Hour"
      )
  end

  def set_timeout
    merchant.timeout_end = 1.hour.from_now
    merchant.save
  end


  def send_confirmation(user_role)
    client.messages.create(
        from: merchant.phone_number,
        to: from_number,
        body: "You Are About To Send Out The Following Message: \n #{message_body} \n Respond 'yes' To Send It. Anything Else Will Cancel."
      )
  end

  def send_success_response(request, user_role)
    client.messages.create(
        from: merchant.phone_number,
        to: from_number,
        body: "You Sent Out The Following Message: \n #{request.session[:message_body]}"
      )

  end

  def send_cancel_response(user_role)
    client.messages.create(
        from: merchant.phone_number,
        to: from_number,
        body: "Message Canceled"
      )
  end

  def send_fail_response
    client.messages.create(
        from: Rails.application.secrets.twilio_number,
        to: from_number,
        body: "Please text START to subscribe to this number or STOP to unsubscribe."
      )
  end

  def set_session_variable(request)
    if request.session[:confirmation_sent] != true
      request.session[:confirmation_sent] = false
    end
    return request.session[:confirmation_sent]
  end

  def save_message_body(request, message_body)
    if request.session[:message_body] == ""
      request.session[:message_body] = message_body
    end
    return request.session[:message_body]
  end

  def send_insufficient_permissions_response(user_role)
    client.messages.create(
        from: merchant.phone_number,
        to: from_number,
        body: "Insufficient Permissions"
      )
  end

  def send_out_message(request, user_role)
    merchant.customers.each do |customer|
      if customer.permission_to_text == true
        client.messages.create(
          from: merchant.phone_number,
          to: customer.phone_number,
          body: request.session[:message_body] + "\nReply STOP to stop"
        )
      end
    end
    save_message_to_database
    UpdateMessageCount.new.run(merchant)
  end

  def save_message_to_database
    Message.create(body: request.session[:message_body], merchant_id: merchant.id)

  end

end