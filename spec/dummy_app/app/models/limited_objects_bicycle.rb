# frozen_string_literal: true

class LimitedObjectsBicycle < Vehicle
  has_paper_trail objects_limit: 3
end
