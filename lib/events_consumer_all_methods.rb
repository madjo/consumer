require "date"
require "minitest/autorun"

# If you want to see and run all the code in one place
# Suitable for checking my work

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


class TestStructDateEvent < Minitest::Test

  def test_build
    factory_date_event = EventsConsumer::DateEvent

    input = [{date: '2014-01-01', a: 5, b:1}]
    output = [factory_date_event.new("2014-01-01",{a: 5, b:1})]

    assert_equal output, factory_date_event.build(input)
  end
end

class TestEventsConsumer < Minitest::Test
  def setup
    @input = [
      {date: '2014-01-01', a: 5, b:1},
      {date: '2014-01-01', xyz: 11},
      {date: '2014-10-10', qbz: 5},
      {date: '2014-10-10', v: 4, q: 1, strpm: -99}
    ]

    @output = [
      {date: "2014-01-01", a: 5, b:1, xyz: 11 },
     {date: "2014-10-10", qbz: 5, v: 4, q: 1, strpm: -99}
    ]
  end

  def test_consume_events_regular_data
    event_consumer = EventsConsumer.new(@input)
    assert_equal @output, event_consumer.consume_events
  end

  def test_consume_events_with_no_date_key
    local_input = [ {xyz: 11}, {qbz: 5}, {v: 4, q: 1, strpm: -99} ]

    event_consumer = EventsConsumer.new(@input + local_input)
    assert_equal @output, event_consumer.consume_events
   end


  def test_consume_events_with_false_date
    local_input = [ 
      {date: '2014-15-14', qbz: 5}, 
      {date: '2014-13-13', v: 4, q: 1, strpm: -99}
    ]

    event_consumer = EventsConsumer.new(@input + local_input)
    assert_equal @output, event_consumer.consume_events
  end

  def test_consume_events_with_false_date_and_no_date_key
    local_input = [ 
      {xyz: 11}, {qbz: 5}, {v: 4, q: 1, strpm: -99},
      {date: '2014-15-14', qbz: 5}, 
      {date: '2014-13-13', v: 4, q: 1, strpm: -99}
    ]
   
    event_consumer = EventsConsumer.new(@input + local_input)
    assert_equal @output, event_consumer.consume_events
  end
end
