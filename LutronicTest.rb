#require 'test/unit'
require 'minitest/autorun'

#class TestLutronic < Test::Unit::TestCase
class TestLutronic < Minitest::Test
  def setup
    rsp = `curl "http://localhost:8081/?action=status&devicetype=K&address=01:06:05&button=1"`
    if rsp == 'switch:on'
      `curl "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`
      sleep(1)
    end
  end

  def test_simple
    assert_equal('switch:off',`curl "http://localhost:8081/?action=status&devicetype=K&address=01:06:05&button=1"`)
    sleep(1)
    assert_equal('switch:on',`curl "http://localhost:8081/?action=on&devicetype=K&address=01:06:05&button=1"`)
    sleep(1)
    assert_equal('noaction',`curl "http://localhost:8081/?action=on&devicetype=K&address=01:06:05&button=1"`)
    sleep(1)
    assert_equal('switch:off',`curl "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`)
    sleep(1)
    assert_equal('noaction',`curl "http://localhost:8081/?action=off&devicetype=K&address=01:06:05&button=1"`)
  end
end
