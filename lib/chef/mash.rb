
require "chef-utils/mash" unless defined?(ChefUtils::Mash)

# For historical reasons we inject Mash directly into the top level class namespace
Mash = ChefUtils::Mash unless defined?(Mash)
