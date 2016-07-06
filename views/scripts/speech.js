  window.recognition = new webkitSpeechRecognition();
  $("#speakButton").on("click", function(e){
    recognition.onresult = function(event) {
      result = event.results[0][0].transcript
      console.log(`TRANSCRIPT: ${result}`)
      ws.send(`browser_cmd ${result}`)
      $("#speakNow").hide()
    }
    recognition.start();
    $("#speakNow").show()
  })
  $("#speakNow").hide()

