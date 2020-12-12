# functional-io-system-code

The implementation of UFO World and Universe from  **A Functional I/O System, or Fun for Freshmen Kids** by [Matthias Felleisen](http://www.ccs.neu.edu/~matthias/), [Robby Findler](http://www.cs.northwestern.edu/~robby/), [Matthew Flatt](http://www.cs.utah.edu/~mflatt/), [Shriram Krishnamurthi](http://www.cs.brown.edu/~sk/). Published in International Conference on Functional Programming (ICFP) 2009. 

Link to the paper: https://www2.ccs.neu.edu/racket/pubs/icfp09-fffk.pdf

Why does this repository exist? 

- Integrated the disparate code snippets from Section 4 and Section 5 into a working demo, fixed typos. The code snippet that shows the design in an object-oriented style is not included.
- Added a "stopping" state so that a world may be stopped by pressing `q`, I have also integrated the "resting" world state into all the handler functions.
- Added tests where the paper says ";; ... more test cases ..."
- I have defined a main function using launch-many-worlds/proc that accepts a list of world names then does the following in order:
    1. Starts the server.
    2. Starts all clients (each correspinding to a provided names) in parallel.
- ufo-universe.rkt is written in #lang htdp/asl (Advanced Student Language) as a Racket script (using #! /usr/bin/env racket). To run it, do either of the following:
  1. Open DrRacket and _Run_, or
  2. `$ ./ufo-universe.rkt` if you have racket in PATH. 