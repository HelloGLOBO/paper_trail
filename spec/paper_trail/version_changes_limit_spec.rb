# frozen_string_literal: true

require "spec_helper"

module PaperTrail
  ::RSpec.describe Cleaner, versioning: true do
    after do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_changes_limit = nil
    end

    it "cleans up objects with limit specified in model" do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_changes_limit = 10

      # LimitedBicycle overrides the global version_changes_limit
      bike = LimitedChangesBicycle.create(name: "Bike") # has_paper_trail changes_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end

      expect(LimitedChangesBicycle.find(bike.id).versions.where(object: nil).count).to eq(13)
      # 16 versions = 15 updates + 1 create.
      # we are expecting only {changes_limit} of them have object set
    end

    # TODO: not sure about this one, if the excess_versions is higher than
    # the excess_changes_versions then anything inside the
    # excess_changes_versions will already be destroyed by the default mechanism.
    it "cleans up object_changes, when there are older and more records found with version_limit" do
      PaperTrail.config.version_limit = 2
      PaperTrail.config.version_changes_limit = 3

      # LimitedBicycle overrides the global version_changes_limit
      bike = LimitedChangesBicycle.create(name: "Bike") # has_paper_trail changes_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      expect(LimitedChangesBicycle.find(bike.id).versions.where(object_changes: nil).count).to eq(4)
      # 16 versions = 15 updates + 1 create.
      # we are expecting only {changes_limit} of them have object set
    end
  end
end
