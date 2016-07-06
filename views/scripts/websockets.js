var show = function(el){
  return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
}(document.getElementById('msgs'));

var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
ws.onopen    = function()  { show('websocket opened'); };
ws.onclose   = function()  { show('websocket closed'); }
ws.onmessage = function(m) {
  if (m.data.includes("mp4")) {
    SetVideoSrc(m.data)
  } else {
    $("#msgs").append($(`<li>${m.data}</li>`))
  }
};

window.testSocket = ws
