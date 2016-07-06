
# Lexicon object is a hash which has singleton methods added to it.
# The actual command definitions are stored in the database.

# The lexicons used by sentence_interpreter are VerbLexicon and NounLexicon.
# To update the sentence_interpreter, first call Lexicon.reload to get the state from the database
# then use Lexicon.copy_self_to(verbs: VerbLexicon, nouns: NounLexicon).

Lexicon = {}
Lexicon[:verb_class] = Verb
Lexicon[:noun_class] = Noun

# Lexicon.reload will load the database's state into the Lexicon object
Lexicon.define_singleton_method(:reload) do
  delete Lexicon[:verbs]
  delete Lexicon[:nouns]
  ["noun", "verb"].each do |word_type|
    Lexicon[:"#{word_type}s"] = Lexicon[:"#{word_type}_class"].all.reduce({}) do |words, word|
      
      begin

        # In the database, the 'action' attribute of words is a text representation of a proc,
        # i.e. { action: "->(){'return val'}" }
        # When loading the words into Lexicon from the database,
        # evaluate all these strings into Proc objects.
        words.tap { |words| words[word.name.to_sym] = eval(word.action) }

      rescue Exception => e # SyntaxError is not a descendent of StandardError,
                              # so rescue won't catch it by default.
                              # Without rescuing SyntaxError, calling eval on an invalid command string
                              # will halt the process.
        
        # If there is an error, set the action to a empty proc
        word.update(action: "->(){}")
        delete words[word.name.to_sym]
        words
        
      end
      
    end
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