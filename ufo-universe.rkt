#! /usr/bin/env racket

#lang htdp/asl

(require 2htdp/image)
(require 2htdp/universe)

(define-struct ufo (x y dx dy))
;;
;; WorldSt is one of:
;; - "resting"
;; - "stopped"
;; - (make-ufo Nat Nat Int Int)
;; 
;; Interpretation:
;;
;; "resting" when the the current world is
;;     resting and another world is active
;; "stopped" when the world has been stopped
;;     using the "q" button
;; "ufo represents the location (pixels) and
;;     velocity (pixels/tick) of the ufo

(define (resting? a)
  (and (string? a) (string=? a "resting")))


(define SIZE 400)
(define MT (empty-scene SIZE SIZE))
(define UFO
  (overlay (circle 10 "solid" "green")
           (rectangle 40 2 "solid" "green")))

(define REST (text "resting" (/ SIZE 4) "red"))
(define STOPPED (text "stopped" (/ SIZE 4) "red"))


;; WorldSt -> Image
;; place the ufo into MT at its current position
;; otherwise display "resting" or "stopped" status

(check-expect 
 (render "resting")
 (overlay (text "resting" 100 "red") MT))

(check-expect 
 (render "stopped") 
 (overlay (text "stopped" 100 "red") MT))

(check-expect 
 (render (make-ufo 10 20 -1 +1)) 
 (place-image UFO 10 20 MT))

(define (render w)
  (cond
    [(resting? w)
     (overlay REST MT)]
    [(stopped? w)
     (overlay STOPPED MT)]
    [(ufo? w)
     (place-image UFO (ufo-x w) (ufo-y w) MT)]))


;; WorldSt KeyEvt -> WorldSt
;; control the ufo’s direction via the arrow keys

(check-expect 
 (control "resting" "down")
 "resting")

(check-expect 
 (control "resting" "q") 
 "stopped")

(check-expect 
 (control "stopped" "up") 
 "stopped")

(check-expect 
 (control (make-ufo 5 8 -1 -1) "down") 
 (make-ufo 5 8 -1 +1))

(check-expect 
 (control (make-ufo 5 8 -1 -1) "up") 
 (make-ufo 5 8 -1 -1))

(check-expect 
 (control (make-ufo 5 8 -1 -1) "left") 
 (make-ufo 5 8 -1 -1))

(check-expect 
 (control (make-ufo 5 8 -1 -1) "right") 
 (make-ufo 5 8 +1 -1))

(check-expect 
 (control (make-ufo 5 8 -1 -1) "q") 
 "stopped")

(check-expect 
 (control (make-ufo 5 8 -1 -1) "z") 
 (make-ufo 5 8 -1 -1))

(define (control w ke)
  (cond
    [(resting? w)
     (if (key=? ke "q") "stopped" w)]
    [(stopped? w) w]
    [(ufo? w)
     (cond
       [(key=? ke "up") (set-ufo-dy w -1)]
       [(key=? ke "down") (set-ufo-dy w +1)]
       [(key=? ke "left") (set-ufo-dx w -1)]
       [(key=? ke "right") (set-ufo-dx w +1)]
       [(key=? ke "q") "stopped"]
       [else w])]))

;; WorldSt Int -> WorldSt
(define (set-ufo-dy u dy)
  (make-ufo (ufo-x u) (ufo-y u) (ufo-dx u) dy))

;; WorldSt Int -> WorldSt
(define (set-ufo-dx u dx)
  (make-ufo (ufo-x u) (ufo-y u) dx (ufo-dy u)))

;; WorldSt Nat Nat MouseEvt -> WorldSt
;; move the ufo to a new position on the canvas

(check-expect
 (hyper (make-ufo 10 20 -1 +1) 40 30 "button-up")
 (make-ufo 10 20 -1 +1))

(check-expect
 (hyper (make-ufo 10 20 -1 +1) 300 20 "button-down")
 (make-ufo 300 20 -1 +1))

(check-expect
 (hyper "stopped" 300 20 "button-down")
 "stopped")

(check-expect
 (hyper "resting" 300 20 "button-down")
 "resting")

(check-expect "resting" "resting")

(define (hyper w x y a)
  (cond
    [(resting? w) w]
    [(stopped? w) w]
    [(ufo? w)
     (if (mouse=? "button-down" a)
         (make-ufo x y (ufo-dx w) (ufo-dy w))
         w)]))


;; WorldSt -> Boolean
;; is the ufo is stopped state?

(check-expect (stopped? (make-ufo 5 (- SIZE 5) -1 +1)) false)
(check-expect (stopped? "stopped") true)

(define (stopped? w)
  (and (string? w) (string=? w "stopped")))


;; UniSt = IWld*
;; interp. list of worlds in the order they take
;; turns, starting with the active one
;; the active world (if any) is first

;; UniSt IWld -> Bundle
;; nw is joining the universe
(check-expect
 (add-world (list iworld2) iworld1)
 (make-bundle (list iworld2 iworld1) '() '()))

(check-expect
 (add-world '() iworld1)
 (make-bundle (list iworld1)
              (list (make-mail iworld1 "your-turn"))
              '()))

(define (add-world ust nw)
  (if (empty? ust)
      (make-bundle (list nw) (m2 nw) '())
      (make-bundle (append ust (list nw)) '() '())))


;; IWld -> Mail*
;; create single-item list of mail to w
;; no test cases
(define (m2 w)
  (list (make-mail w "your-turn")))


;; UniSt IWld "done" -> Bundle
;; mw sent message m; assume mw = (first ust), m = "done"

(check-expect
 (switch (list iworld1 iworld2) iworld1 "done")
 (make-bundle (list iworld2 iworld1) (m2 iworld2) '()))

(check-expect
 (switch (list iworld1) iworld1 "done")
 (make-bundle (list iworld1) (m2 iworld1) '()))

(define (switch ust mw m)
  (local ((define l (append (rest ust) (list mw)))
          (define nxt (first l)))
    (make-bundle l (m2 nxt) '())))

;; UniSt IWld -> Bundle
;; dw disconnected from the universe

(check-expect
 (del-world (list iworld1 iworld3) iworld3)
 (make-bundle (list iworld1) '() '()))

(check-expect
 (del-world (list iworld1) iworld1)
 (make-bundle '() '() '()))

(check-expect
 (del-world (list iworld1 iworld2) iworld1)
 (make-bundle (list iworld2) (m2 iworld2) '()))

(define (del-world ust dw)
  (if (not (iworld=? (first ust) dw))
      (make-bundle (remove dw ust) '() '())
      (local ((define l (rest ust)))
        (if (empty? l)
            (make-bundle '() '() '())
            (local ((define nxt (first l))
                    (define mll (m2 nxt)))
              (make-bundle l mll '()))))))


;; WorldSt -> (U WorldSt Package) 
(define (move w)
  (cond
    [(and (string? w) (string=? "resting")) w]
    [(and (string? w) (string=? "stopped")) w]
    [(ufo? w) (move.global w)]))

(define (move.global w)
  (local ((define v (move-ufo w)))
    (if (not (landed? v))
        v
        (make-package "resting" "done"))))

;; WorldSt -> WorldSt
;; move the ufo for one tick of the clock

(check-expect (move-ufo (make-ufo 10 20 -1 +1))
              (make-ufo 9 21 -1 +1))

(define (move-ufo w)
  (make-ufo (+ (ufo-x w) (ufo-dx w))
            (+ (ufo-y w) (ufo-dy w))
            (ufo-dx w)
            (ufo-dy w)))


;; WorldSt -> Boolean
;; has the ufo landed?
(check-expect (landed? (make-ufo 5 (- SIZE 5) -1 +1))
              false)

(check-expect (landed? (make-ufo 5 SIZE -1 +1))
              true)

(define (landed? w)
  (>= (ufo-y w) SIZE))


;; WorldSt "your-turn" -> WorldSt
;; assume: messages arrive only
;; if the state is "resting"
(define (receive w msg)
  (make-ufo (/ SIZE 2) (/ SIZE 2) -1 +1))


;; String WorldSt -> WorldSt
;; starts a big-bang with an initial world state
(define (main-for-client n worldst-init)
  (big-bang worldst-init
    [on-draw render]
    [on-tick move]
    [on-key control]
    [on-mouse hyper]
    [stop-when stopped? render]
    [name n]
    [on-receive receive]
    [register LOCALHOST]))

;; UniSt -> UniSt
;; starts the universe with an initial universe state
(define (main-for-server unist-init)
  (universe unist-init
            (on-new add-world)
            (on-msg switch)
            (on-disconnect del-world)))


;; [List-of String] -> UniSt WorldSt ...
;; Launches an initial universe server followed by
;; one client per client-name in parallel
(define (main client-names)
  (apply launch-many-worlds/proc
         (cons (λ () (main-for-server '()))
               (map (λ (name)
                      (λ () (main-for-client name "resting")))
                    client-names))))


;; Use arrow keys to control the UFO, use the mouse click
;; to teleport the UFO, and "q" to quit. When the UFO lands
;; The control transfers to the other UFOs


(main '("earth" "mars" "venus"))
