# Lexicon object is a hash which has singleton methods added to it.
# The actual definitions are stored in the database.
# It is initialized with all existing definitions.
# Create, Update, and Destroy hooks on the database will update the Lexicon object.

Lexicon = {}
Lexicon[:verb_class] = Verb
Lexicon[:noun_class] = Noun
["noun", "verb"].each do |word_type|
  Lexicon[:"#{word_type}s"] = Lexicon[:"#{word_type}_class"].all.reduce({}) do |words, word|
    words.tap { |words| words[word.name.to_sym] = eval(word.action) }
  end
end


# Lexicon.get_noun calls the proc for a noun
Lexicon.define_singleton_method(:get_noun) do |noun, *args|
  self[:nouns][noun.to_sym].call(*args) rescue $driver.raise_error("Error getting noun: #{noun}")
end

# Lexicon.get_verb calls the proc for a verb
Lexicon.define_singleton_method(:get_verb) do |verb, *args|
  self[:verbs][verb.to_sym].call(*args) rescue $driver.raise_error("Error getting verb: #{verb}")
end

# Lexicon.copy_self_to extends the Lexicon's verbs and nouns to other objects
Lexicon.define_singleton_method(:copy_self_to) do |objects|
  self[:verbs].each { |name, func| objects[:verbs][name.to_sym] = func }
  self[:nouns].each { |name, func| objects[:nouns][name.to_sym] = func }
end

# Plug into the database hooks.
# Forward the results to other listeners.
["verb", "noun"].each do |word_type|
  Lexicon[:"#{word_type}_class"].define_singleton_method(:custom_save_hook) do |record|
    Lexicon[:on_create_or_update_hook].call(word_type, record)
  end
  Lexicon[:"#{word_type}_class"].define_singleton_method(:custom_destroy_hook) do |record|
    Lexicon[:on_destroy_hook].call(word_type, record)
  end
end