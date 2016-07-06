function removeWordListener() {
  $("#words_list").find(".remove_word").off("click").on("click", function(e){
    var $el = $(e.currentTarget)
    var $word = $el.parent(".word")
    var word = getWordObjectFromDOM($word)
    $word.remove()
    ws.send(
      "remove_word " +
      word.type + " " +
      word.name
    )
  })
}

removeWordListener()