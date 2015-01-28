require 'test_helper'

class TestStructDateEvent < Minitest::Test

  def test_build
    factory_date_event = EventsConsumer::DateEvent

    input = [{date: '2014-01-01', a: 5, b:1}]
    output = [factory_date_event.new("2014-01-01",{a: 5, b:1})]

    assert_equal output, factory_date_event.build(input)
  end
end