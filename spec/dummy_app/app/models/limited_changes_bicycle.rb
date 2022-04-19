# frozen_string_literal: true

class LimitedChangesBicycle < Vehicle
  has_paper_trail limit: 10, changes_limit: 5
end
