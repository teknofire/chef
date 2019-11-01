require "spec_helper"

RSpec.describe ChefUtils do
  class ThingWithDSL
    extend ChefUtils
  end

  (OS_HELPERS + ARCH_HELPERS + PLATFORM_HELPERS + PLATFORM_FAMILY_HELPERS + INTROSPECTION_HELPERS).each do |helper|
    it "has the #{helper} in the ChefUtils module" do
      expect(ThingWithDSL).to respond_to(helper)
    end
    it "has the #{helper} class method in the ChefUtils module" do
      expect(ChefUtils).to respond_to(helper)
    end
  end
end
