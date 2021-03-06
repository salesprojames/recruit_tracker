include ActionView::Helpers::NumberHelper

class RecruitsController < ApplicationController
  before_action :set_recruit, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


  def index
    @recruits = Recruit.all.uniq
    @recruits.each do |recruit|
      if (Date.today - recruit.start_date).to_f == 30
        recruit.closed = true
        recruit.save
      end
    end
  end

  def show
  end

  def edit
  end

  def new
    @recruit = Recruit.new
    @recruit.tasks.build
  end

  def create
    @recruit = Recruit.new(recruit_params)
    @recruit.phone_number = ToPhoneNumber.new.convert(@recruit.phone_number)

    respond_to do |format|
      if @recruit.save

        general_messages = GeneralMessage.where(number: @recruit.phone_number)
        general_messages.each do |general_message|
          @recruit.messages.create(body: general_message.body, sent_by_recruit: true)
        end
        general_messages.destroy_all

        format.html { redirect_to root_path, notice: 'Recruit was successfully created.' }
        format.json { render :show, status: :created, location: @recruit }
      else
        format.html { render :new }
        format.json { render json: @recruit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @recruit.update(recruit_params)
        format.html { redirect_to root_path, notice: 'Recruit was successfully updated.' }
        format.json { render :show, status: :ok, location: @recruit }
      else
        format.html { render :edit }
        format.json { render json: @recruit.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @recruit.destroy
    respond_to do |format|
      format.html { redirect_to recruits_path, notice: 'Recruit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_recruit
      @recruit = Recruit.find(params[:id])
    end

    def recruit_params
      params.require(:recruit).permit(:name, :phone_number, :email, :description, :start_date, :closed, tasks_attributes: [:id, :name, :due_date])
    end

end
