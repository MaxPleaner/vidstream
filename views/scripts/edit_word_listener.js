function editWordListener() {
  $("#words_list").find(".edit_word").off("click").on("click", function(e){
    var $el = $(e.currentTarget)
    var word = getWordObjectFromDOM($el.parent(".word"))
    var $form = $("#new_word").find("form")
    $form.find("input[name='type']").val(word.type)
    $form.find("textarea[name='action']").val(word.action)
    $form.find("input[name='name']").val(word.name)
    scrollTo(0,0)
    return false
  })
}

