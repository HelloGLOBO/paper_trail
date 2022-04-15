# frozen_string_literal: true

require "spec_helper"

module PaperTrail
  ::RSpec.describe Cleaner, versioning: true do
    # after each
    after do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_objects_limit = nil
    end

    # before each
    before do
      # enable version changes on all tests
      PaperTrail.config.enable_version_objects_limit = true
    end

    it "does not cleans up old versions objects when version_objects_limit is disabled" do
      PaperTrail.config.enable_version_objects_limit = false

      # LimitedBicycle overrides the global version_limit
      bike = LimitedObjectsBicycle.create(name: "Bike") # has_paper_trail objects_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      expect(LimitedObjectsBicycle.find(bike.id).versions.where(object: nil).count).to eq(1)
      # 1 create

      expect(LimitedObjectsBicycle.find(bike.id).versions.where(object_changes: nil).count).to eq(0)
      # 16 versions
    end

    it "cleans up old version objects when version_objects_limit is set on the model" do
      PaperTrail.config.version_limit = nil

      # LimitedBicycle overrides the global version_limit
      bike = LimitedObjectsBicycle.create(name: "Bike") # has_paper_trail objects_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      expect(LimitedObjectsBicycle.find(bike.id).versions.where(object: nil).count).to eq(13)
      # 13 versions = 12 updates + 1 create
    end

    it "cleans up old version objects when version_objects_limit is set globally" do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_objects_limit = 4

      # LimitedBicycle overrides the global version_limit
      bike = Bicycle.create(name: "Bike") # has_paper_trail objects_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      expect(Bicycle.find(bike.id).versions.where(object: nil).count).to eq(12)
      # 13 versions = 12 updates + 1 create
    end

    it "cleans up old versions when version_objects_limit and version_limit are equal" do
      PaperTrail.config.version_limit = 3

      # LimitedBicycle overrides the global version_limit
      bike = LimitedObjectsBicycle.create(name: "Bike") # has_paper_trail objects_limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      expect(LimitedObjectsBicycle.find(bike.id).versions.count).to eq(4)
      # 4 versions = 3 updates + 1 create.
    end

    it "cleans up old versions objects when version_objects_limit is lower than version_limit" do
      PaperTrail.config.version_limit = 6
      PaperTrail.config.version_objects_limit = 3

      # LimitedBicycle overrides the global version_limit
      bike = Bicycle.create(name: "Bike")

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      versions = Bicycle.find(bike.id).versions
      expect(versions.count).to eq(7)
      # 7 versions = 6 updates + 1 create

      expect(versions.where(object: nil).count).to eq(4)
      # 4 versions = 3 updates + 1 create.
    end

    it "cleans up old versions when version_objects_limit is greater than version_limit" do
      # this basically ignores version_objects_limit

      PaperTrail.config.version_limit = 4
      PaperTrail.config.version_objects_limit = 6

      # LimitedBicycle overrides the global version_limit
      bike = Bicycle.create(name: "Bike")

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      # 16 versions = 15 updates + 1 create.

      versions = Bicycle.find(bike.id).versions
      expect(versions.count).to eq(5)
      # 4 versions = 4 updates + 1 create
      expect(versions.where(object: nil).count).to eq(1)
      # 1 version = 1 create
    end
  end
end
