# functional-io-system-code

The implementation of UFO World and Universe from  **A Functional I/O System, or Fun for Freshmen Kids** by [Matthias Felleisen](http://www.ccs.neu.edu/~matthias/), [Robby Findler](http://www.cs.northwestern.edu/~robby/), [Matthew Flatt](http://www.cs.utah.edu/~mflatt/), [Shriram Krishnamurthi](http://www.cs.brown.edu/~sk/). Published in International Conference on Functional Programming (ICFP) 2009. 

Link to the paper: https://www2.ccs.neu.edu/racket/pubs/icfp09-fffk.pdf

My additions:

- Integrated into a working demo, fixed typos and errors.
- Updated all the handlers to accomodate the "resting" state (when the control transfers to other worlds) and a "stopping" state (so that a world may be stopped by pressing `q`)
- Added tests where the paper says ";; ... more test cases ..."
- Defined a main function using launch-many-worlds/proc that accepts a list of world names. First, it starts the server, then it spawns all the clients in parallel.
- Wrote the whole thing in #lang htdp/asl (Advanced Student Language) as a Racket script (using #! /usr/bin/env racket)