class TasksController < ApplicationController
  before_action :load_recruit
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete]

  # dont know if i will need to use this page
  def index
    @tasks = Task.all
  end

  def show
  end

  def edit
  end

  def new
    @task = @recruit.tasks.new
  end

  def create
    @task = @recruit.tasks.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to root_path, notice: 'task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(post_params)
        format.html { redirect_to root_path, notice: 'task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def complete
    @task.complete = true
    @task.save
    if @recruit.tasks.where(complete: false).count == 0
      redirect_to new_recruit_task_path(@recruit)
    else
    redirect_to root_path
    end
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def load_recruit
      @recruit = Recruit.find(params[:recruit_id])
    end

    def task_params
      params.require(:task).permit(:name, :due_date, :recruit_id)
    end

end
