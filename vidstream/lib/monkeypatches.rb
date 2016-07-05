
# Requires files from **this file's directory** ( this file is vidstream/lib/monkeypatches )

class Object
  def then_require_from_lib(list)
    list.compact.each { |dep| require_relative dep }
    return nil
  end
end