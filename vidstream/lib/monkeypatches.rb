
# Requires files from vidstream/lib/

# Some dependencies need to be required in a specific order.
# This added method helps make that ordering explicit.

# Example:
# - Before:
#     require_relative './lib/database'
#     require_relative './lib/seeds'
# - After:
#     require_relative('./lib/database').then_require_from_lib(['./seeds.rb'])

class Object
  def then_require_from_lib(list)
    list.compact.each { |dep| require_relative dep }
    return nil
  end
end