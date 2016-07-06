function getWordObjectFromDOM($word) {
  var name = $word.find(".name").text()
  var type = $word.find(".type").text()
  var action = $word.find(".action").text()
  return { name: name, type: type, action: action }
}
