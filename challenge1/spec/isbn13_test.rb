require "minitest/autorun"
require_relative "../lib/isbn13"

class ISBN13Test < Minitest::Test
  def test_adds_check_digit_to_valid_12_digit_isbn
    assert_equal "9780143007234", ISBN13.apply_isbn13_checkdigit("978014300723")
    assert_equal "9780306406157", ISBN13.apply_isbn13_checkdigit("978030640615")
    assert_equal "9780306406140", ISBN13.apply_isbn13_checkdigit("978030640614") # test 10/0
  end

  def test_accepts_formatted_isbns
    assert_equal "9780306406157", ISBN13.apply_isbn13_checkdigit("978-0-306-40615")
    assert_equal "9780306406157", ISBN13.apply_isbn13_checkdigit("978 0 306 40615")
    assert_equal "9780306406157", ISBN13.apply_isbn13_checkdigit(978030640615) # allow nums
  end

  def test_raises_an_error_when_isbn_is_invalid
    length_error = assert_raises(ArgumentError) do
      ISBN13.apply_isbn13_checkdigit("97803064061")
    end

    assert_equal 'expected "97803064061" to be 12 characters long', length_error.message

    char_error = assert_raises(ArgumentError) do
      ISBN13.apply_isbn13_checkdigit("97803064061A")
    end

    assert_equal 'expected "97803064061A" to contain only digits, spaces or hyphens', char_error.message
  end
end
