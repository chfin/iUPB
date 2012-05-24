class CoursesController < ApplicationController
  before_filter :set_cache_header, :except => :search

  def index
  end
  
  def show
    @course = Course.find(params[:id])
    set_next_class @course
    if @course.course_type == 'course'
      @groups = Course.where(paul_id: @course.paul_id).where(course_type: 'group').excludes(id: @course.id).order_by([[:title_downcase, :asc]]).entries
      attach_next_class @groups
    end
    # If the request is stale according to the given timestamp and etag value
    # (i.e. it needs to be processed again) then execute this block
    #if stale?(:last_modified => Time.now - 7.days, :etag => @course)
    #  expires_in 7.days, :public => true, 'max-stale' => 0
    #end
  end
 
  def search
    query = params[:query].downcase
    @courses = []
    @courses = Course.where(course_type: 'course').where(title_downcase: /.*#{query}.*/).limit(10).entries if query.length > 2
    
    attach_next_class @courses
    set_cache_header(60*60) # only cache 1 hour
  end
  def set_next_class(course)
    min_interval = 100.days
    course.course_data.each do |data|
      next_class = data['date'].to_date
      #TODO: this will cause problems with multiple timezones
      #TODO: this is more a hotfix. It should normally work out of the box
      time_from = Time.new(next_class.year, next_class.mon, next_class.day, data['time_from'].hour, data['time_from'].min, 0, data['time_from'].utc_offset).in_time_zone(Time.zone)
      time_to = Time.new(next_class.year, next_class.mon, next_class.day, data['time_to'].hour, data['time_to'].min, 0, data['time_to'].utc_offset).in_time_zone(Time.zone)
      data['time_from'] = time_from
      data['time_to'] = time_to
      interval = time_from - Time.now
      if time_from >= Time.now and interval < min_interval
        course['next_class'] = {
          room: data['room'].length == 0 ? t('courses.room_na') : data['room'],
          time_from: time_from,
          time_to: time_to
          #instructor: data['instructor']
        }
        min_interval = interval
      end
    end
  end
  def attach_next_class(courses)
    courses.each do |course|
      set_next_class course
    end
  end
end
