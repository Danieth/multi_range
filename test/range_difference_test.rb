# frozen_string_literal: true

require 'test_helper'

class RangeDifferenceTest < Minitest::Test
  def setup
    @degree_range = MultiRange.new([0...360])
    @empty_range = MultiRange.new([])
    @multi_range = MultiRange.new([0..100, 200..300, 500..600])
    @float_range = MultiRange.new([1.2..1.5, 1.7..1.8, 3.5..7.2])
  end

  def test_empty_range
    assert_before_and_after(
      proc{ @empty_range.ranges },
      proc{ @empty_range -= 5..10 },
      :before => [],
      :after  => []
    )
  end

  def test_when_full_cover_excluded_range
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= 50..120 },
      :before => [0...360],
      :after  => [0...50, 121..359]
    )
  end

  def test_when_right_cover_excluded_range
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= -10..20 },
      :before => [0...360],
      :after  => [21..359]
    )
  end

  def test_when_left_cover_excluded_range
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= 330..400 },
      :before => [0...360],
      :after  => [0...330]
    )
  end

  def test_when_not_cover_excluded_range
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= -30..400 },
      :before => [0...360],
      :after  => []
    )
  end

  def test_when_smaller_and_not_overlap
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= -30..-10 },
      :before => [0...360],
      :after  => [0...360]
    )
  end

  def test_when_larger_and_not_overlap
    assert_before_and_after(
      proc{ @degree_range.ranges },
      proc{ @degree_range -= 370..400 },
      :before => [0...360],
      :after  => [0...360]
    )
  end

  def test_multi_range
    assert_before_and_after(
      proc{ @multi_range.ranges },
      proc{ @multi_range -= 50..550 },
      :before => [0..100, 200..300, 500..600],
      :after  => [0...50, 551..600]
    )
  end

  def test_other_multi_range
    assert_before_and_after(
      proc{ @multi_range.ranges },
      proc{ @multi_range -= MultiRange.new([50..60, 110..120, 180..550, 700]) },
      :before => [0..100, 200..300, 500..600],
      :after  => [0...50, 61..100, 551..600]
    )
  end

  def test_other_multi_range_and_not_overlap
    assert_before_and_after(
      proc{ @multi_range.ranges },
      proc{ @multi_range -= MultiRange.new([-10..-5, 105..199, 400, 700..900]) },
      :before => [0..100, 200..300, 500..600],
      :after  => [0..100, 200..300, 500..600]
    )
  end

  def test_float
    assert_before_and_after(
      proc{ @float_range.ranges },
      proc{ @float_range -= MultiRange.new([1.45..1.55, 5...6]) },
      :before => [1.2..1.5, 1.7..1.8, 3.5..7.2],
      :after  => [1.2...1.45, 1.7..1.8, 3.5...5, 6..7.2]
    )

    # We cannot exclude 1.4 from range begin.
    # The expected output is 1.4...1.45 without 1.4 itself.
    err = assert_raises(TypeError){ @float_range -= MultiRange.new([1.3..1.4]) }
    assert_equal 'cannot exclude non Integer end value', err.message
  end
end
