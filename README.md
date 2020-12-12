# functional-io-system-code

The implementation of UFO World and Universe from  **A Functional I/O System, or Fun for Freshmen Kids** by [Matthias Felleisen](http://www.ccs.neu.edu/~matthias/), [Robby Findler](http://www.cs.northwestern.edu/~robby/), [Matthew Flatt](http://www.cs.utah.edu/~mflatt/), [Shriram Krishnamurthi](http://www.cs.brown.edu/~sk/). Published in International Conference on Functional Programming (ICFP) 2009. 

Link to the paper: https://www2.ccs.neu.edu/racket/pubs/icfp09-fffk.pdf

The code in the paper is...

- Integrated into a working demo. The code snippet that shows the design in an object-oriented style is not included.
- Updated with "stopping" state so that a world may be stopped by pressing `q`, and "resting". All the handlers are updated to accomodate the new world state.
- Updated with tests where the paper says ";; ... more test cases ..."
- The main function is defined using launch-many-worlds/proc that accepts a list of world names and then, first, starts the server, followed by all the clients in parallel.
- Written in #lang htdp/asl (Advanced Student Language) as a Racket script (using #! /usr/bin/env racket)