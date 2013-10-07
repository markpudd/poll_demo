class PollsController < ApplicationController
  # GET /polls
  # GET /polls.json
  def index
    @polls = Poll.order("created_at")
    poll = @polls.first
    if poll
      redirect_to @polls.first
    else
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @polls }
      end
    end
  end

  # GET /polls/1
  # GET /polls/1.json
  def show
    @poll = Poll.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @poll }
    end
  end


end
