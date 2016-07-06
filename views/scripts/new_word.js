$("#new_word").find("form").on("submit", function(e){
  var $el = $(e.currentTarget)
  e.preventDefault()
  var name = $el.find("[name='name']").val()
  var type = $el.find("[name='type']").val()
  var action = $el.find("[name='action']").val()
  ws.send(
    "add_word " +
    type + " " +
    name + " " +
    action
  )
  word = {
    name: name,
    type: type,
    action: action
  }
  appendToDom(word)
})

