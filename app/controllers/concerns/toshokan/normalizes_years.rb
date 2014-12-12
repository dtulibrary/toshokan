module Toshokan
  module NormalizesYears
    extend ActiveSupport::Concern

    def normalize_year year, forward_delta = 2, current_year = Time.now.year
      if year < 100
        current_century = current_year - (current_year % 100)
        cutoff_year     = current_year + forward_delta
        cutoff_century  = cutoff_year - (cutoff_year % 100)

        if year <= cutoff_year % 100
          year + cutoff_century
        else
          year + cutoff_century - 100
        end
      else
        year
      end
    end

    def empty_if_not_integer year
      Integer(year.strip.sub(/^0*/, '')) rescue ''
    end

    def normalize_year_range range
      b = empty_if_not_integer(range['begin'])
      e = empty_if_not_integer(range['end'])

      b = normalize_year(b) if b.is_a? Integer
      e = normalize_year(e) if e.is_a? Integer

      if b.is_a?(Integer) && e.is_a?(Integer) && b > e
        e = b
      end

      normalized_range = { 'begin' => b.to_s, 'end' => e.to_s }

      if normalized_range != range
        logger.info "Normalized range #{range} to #{normalized_range}"
      end

      normalized_range
    end
  end
end
