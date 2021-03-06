class EventSessionsController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :destroy]
  before_filter :find_event
  before_filter :validate_checkiner!, only: [:index]
  before_filter :validate_organizer!, only: [:destroy]

  def index
    @checkin_counts = @event.checkin_counts
  end

  def show
    event_session = @event.event_sessions.find(params[:id])
    ics = IcsGenerator.new.event_session_ics(event_session)

    respond_to do |format|
      format.ics { render text: ics, layout: false }
      format.all { head status: 404 }
    end
  end

  def destroy
    event_session = @event.event_sessions.find(params[:id])
    if @event.event_sessions.count > 1 && !event_session.has_rsvps?
      event_session.destroy
      flash[:notice] = "Session #{event_session.name} deleted!"
    else
      flash[:notice] = "Can't delete that session!"
    end
    redirect_to edit_event_path(@event)
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
