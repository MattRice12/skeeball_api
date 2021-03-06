class WeeksController < ApplicationController
  def index
    begin
      weeks = Week.all
      return render json: { weeks: weeks }
    rescue
      render json: { error: INDEX_ERROR, status: 500 }
    end
  end

  def show
    week = Week.find_by(id: params.fetch(:id))
    if week
      return render json: WeekView.new(week)
    end
    render json: { error: "Week not found.", status: 404 }
  end
end
