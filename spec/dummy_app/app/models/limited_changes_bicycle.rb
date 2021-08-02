# frozen_string_literal: true

class LimitedChangesBicycle < Vehicle
  has_paper_trail changes_limit: 3
end
