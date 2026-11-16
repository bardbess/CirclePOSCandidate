# Adds the check digit to a 12-digit ISBN (returns a 13-digit ISBN).
module ISBN13
  class << self
    def apply_isbn13_checkdigit(isbn12)
      digits = isbn12.to_s.delete('- ')

      unless digits.match?(/\A\d{12}\z/)
        raise ArgumentError, 'ISBN must contain exactly 12 digits'
      end

      digitsum = digits.chars.each_with_index.sum do |num, index|
        num.to_i * (index.even? ? 1 : 3)
      end

      digits + calculate_checkdigit(digitsum).to_s
    end

    private

    # The checkdigit is a single digit derived from the sum total of the first 12 digits of an isbn number.
    # This method expects the calculated total of the 12 digits.
    def calculate_checkdigit(isbn12_sum)
      checkdigit = 10 - (isbn12_sum % 10)
      checkdigit % 10 # checkdigit must be a single digit (10 => 0)
    end
  end

end
