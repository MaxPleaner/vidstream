function appendToDom(word) {
  var $template = $("#template").clone()
  $template.attr("id", "")
  $template.attr("class", "word")
  $("#words_list").append($template)
  $template.find(".name").text(word['name'])
  $template.find(".type").html(word['type'])
  $template.find(".action").html(word['action'])
  $template.find(".remove_word").text("remove word")
  $template.find(".edit_word").text("edit word")
  removeWordListener()
  editWordListener()
}
