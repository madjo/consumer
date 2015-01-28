require 'test_helper'
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