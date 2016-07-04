if Verb.count == 0
  Verb.create(
    name: "visit",
    action: <<-TXT
      -> (page_name) {
        url = Lexicon.get_noun(page_name)
        $driver.navigate.to(url) rescue $driver.raise_error("Error visiting url: \#{url}")
      }
    TXT
  )
end

if Noun.count == 0
  Noun.create(
    name: "google",
    action: <<-TXT
      -> () { "http://google.com" }
    TXT
  )
end
