# frozen_string_literal: true

require "spec_helper"

module PaperTrail
  ::RSpec.describe Cleaner, versioning: true do

    before :each do
      PaperTrail.config.version_changes_enabled = true
    end

    after :each do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_changes_enabled = false
    end

    it "cleans up old versions if disabled" do
      PaperTrail.config.version_changes_enabled = false
      PaperTrail.config.version_limit = 10

      # LimitedBicycle overrides the global version_limit
      bike = LimitedBicycle.create(name: "Bike") # has_paper_trail limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      expect(LimitedBicycle.find(bike.id).versions.count).to eq(4)
    end

    it "cleans up old versions if limits are equal" do
      PaperTrail.config.version_limit = 10
      PaperTrail.config.version_changes_limit = 10

      # LimitedBicycle overrides the global version_limit
      bike = LimitedBicycle.create(name: "Bike") # has_paper_trail limit: 3

      15.times do |i|
        bike.update(name: "Name #{i}")
      end
      expect(LimitedBicycle.find(bike.id).versions.count).to eq(4)
    end

    it "cleans up intersection of versions" do
      PaperTrail.config.version_limit = 10
      PaperTrail.config.version_changes_limit = 5
      widget = Widget.create

      15.times do |i|
        widget.update(name: "Name #{i}")
      end
      expect(Widget.find(widget.id).versions.count).to eq 11
      PaperTrail.config.version_limit = 5
      PaperTrail.config.version_changes_limit = 10
      widget = Widget.create

      15.times do |i|
        widget.update(name: "Name #{i}")
      end
      expect(Widget.find(widget.id).versions.count).to eq 11
    end


    it "cleans up intersection of versions with model options" do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_changes_limit = nil
      vehicle = LimitedChangesBicycle.create(name: "Name")

      15.times do |i|
        vehicle.update(name: "Name #{i}")
      end
      expect(LimitedChangesBicycle.find(vehicle.id).versions.count).to eq 11
    end

    it "deletes intersection of versions and cleans object changes" do
      PaperTrail.config.version_limit = nil
      PaperTrail.config.version_changes_limit = 10
      widget = Widget.create

      15.times do |i|
        widget.update(name: "Name #{i}")
      end
      # nothing gets deleted because of how it works on code TODO: confirm?
      expect(Widget.find(widget.id).versions.count).to eq 16

      expect(Widget.find(widget.id).versions.where(object: nil).count).to eq 6
    end

    it "deletes intersection of versions and cleans object changes" do
      PaperTrail.config.version_limit = 5
      PaperTrail.config.version_changes_limit = 10
      widget = Widget.create

      15.times do |i|
        widget.update(name: "Name #{i}")
      end
      expect(Widget.find(widget.id).versions.count).to eq 11

      expect(Widget.find(widget.id).versions.where(object_changes: nil).count).to eq 5
    end

    it "deletes intersection of versions and cleans object" do
      PaperTrail.config.version_limit = 10
      PaperTrail.config.version_changes_limit = 5
      widget = Widget.create

      15.times do |i|
        widget.update(name: "Name #{i}")
      end
      expect(Widget.find(widget.id).versions.count).to eq 11

      expect(Widget.find(widget.id).versions.where(object: nil).count).to eq 6
    end
  end
end
