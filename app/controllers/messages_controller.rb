class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :reply
  before_action :load_recruit, except: :reply
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  def reply
    TwilioLogic.new.reply(params, request)
  end

  def index
    @messages = @recruit.messages.all
  end

  def show
  end

  def edit
  end

  def new
    @message = @recruit.messages.new
  end

  def create
    @message = @recruit.messages.new(message_params)

    respond_to do |format|
      if @message.save
        TwilioLogic.new.send_outgoing_message(@recruit, @message)
        format.html { redirect_to root_path, notice: 'message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @message.update(post_params)
        format.html { redirect_to root_path, notice: 'message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'message was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_message
      @message = Message.find(params[:id])
    end

    def load_recruit
      @recruit = Recruit.find(params[:recruit_id])
    end

    def message_params
      params.require(:message).permit(:body, :recruit_id, :sent_by_recruit)
    end

end
