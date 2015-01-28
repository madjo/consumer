require "events_consumer/version"
require "date"

class EventsConsumer
  attr_reader :dates_events
  def initialize(dates_based_events)
    @dates_events = DateEvent.build(dates_based_events)
  end
  
  # Usage : EventsConsumer.new(date_based_events).consume_events
  def consume_events
    dates_events.group_by(&:date).map do |date, group_dates_events|
      {date: date}.merge extract_output_events(group_dates_events)
    end
  end
  
  # No need to extract this factory like a class yet
  # if there is a need to extract it, create 2 classes DateEvent and 
  # DateEventFactory and inject DateEventFactory object in EventsConsumer
  DateEvent = Struct.new(:date, :events) do
    def self.build(dates_based_events)
      (dates_based_events.collect do |date_event|
        begin
          date = Date.parse(date_event.fetch(:date, nil))
          if date
            date_event.delete(:date)
            new(date.to_s, date_event)
          end
        rescue
          # we can log the bad format line with a logger
        end
      end).compact
    end
  end

  private
  
  # :nodoc:
  def extract_output_events(dates_events)
    dates_events.inject({}) do |events,date_event|
      events.merge!(date_event.events)
    end
  end

end
