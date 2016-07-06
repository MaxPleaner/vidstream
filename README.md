# vidstream
A voice-controlled browser within the browser

### About

The code is split up into two groups:

1. The sinatra server (residing in `/server`)
2. The vidstream process (in `/vidstream`)

To explain the functionality in broad brushstores:

1. The sinatra server sends an HTML page and communicates with it using websockets. 
2. On the HTML page, the user defines "nouns" and "verbs".
3. The server takes these word definitions and adds them to the "Lexicon" of the vidstream process
4. On the HTML page, the user speaks a command, and using HTML5 Voice Recognition it is sent to the server.
5. The server sends the voice command to the vidstream process, which interprets it.
6. The vidstream process's commands interact with a running a selenium browser in a headless scope.
7. Every time the vidstream process runs a headless browser command, it takes a video of itself doing so.
8. The video filepath is pushed to the browser via websockets.
9. The browser starts playing the video when it receives the filepath

Code organization:

- [`./start_server.rb`](./start_server.rb): server entry point (*can be run (blocking) or required (non-blocking)*)
- [`./server/`](./server/): server lib
- [`./vidstream/start_vidstream.rb`](./vidstream/start_vidstream.rb): vidstream entry point (*can be run (blocking) or required (non-blocking)*)
- [`./vidstream/lib/`](./vidstream/lib/): vidstream lib
- [`./public/`](./public/) the destination for videos created by vidstream. Excluded from source control
- [`./views/root.erb`](./views/root.erb): the entry point for the single-page-app's HTML and Javascript
- [`./views/components/`](./views/components/): view partials (HTML fragments with embedded Ruby)
- [`./views/scripts/`](./views/scripts/): script partials (Javascript fragments) 

Hopefully the comments in the source should give enough explanation to understand what's going on.

### Usage

  Install the dependencies, then run `ruby start_server.rb

### Todo

* make a gemfile
* add CSS
* stream video using fragmented MP4
* test edge cases

