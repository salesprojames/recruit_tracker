class GeneralMessagesController < ApplicationController
  before_action :set_general_message, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @general_messages = GeneralMessage.all
  end

  def show
  end

  def edit
  end

  def new
    @general_messages = GeneralMessage.new
  end

  def create
    @general_message = GeneralMessage.new(general_message_params)

    respond_to do |format|
      if @general_message.save
        TwilioLogic.new.send_outgoing_general_message(@recruit, @general_message)
        format.html { redirect_to root_path, notice: 'GeneralMessage was successfully created.' }
        format.json { render :show, status: :created, location: @general_message }
      else
        format.html { render :new }
        format.json { render json: @general_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @general_message.update(post_params)
        format.html { redirect_to root_path, notice: 'GeneralMessage was successfully updated.' }
        format.json { render :show, status: :ok, location: @general_message }
      else
        format.html { render :edit }
        format.json { render json: @general_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @general_message.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'GeneralMessage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_general_message
      @general_message = GeneralMessage.find(params[:id])
    end

    def general_message_params
      params.require(:general_message).permit(:body, :number)
    end

end
