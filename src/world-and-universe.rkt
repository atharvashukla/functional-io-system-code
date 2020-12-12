;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname world-and-universe) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

(define-struct ufo (x y dx dy))
;; WorldSt = (make-ufo Nat Nat Int Int)
;; interp. the location (pixels)
;; and velocity (pixels/tick)
 
(define SIZE 400)
(define MT (empty-scene SIZE SIZE))
(define UFO
  (overlay (circle 10 "solid" "green")
           (rectangle 40 2 "solid" "green")))


;; WorldSt -> WorldSt
;; move the ufo for one tick of the clock

(check-expect (move (make-ufo 10 20 -1 +1))
              (make-ufo 9 21 -1 +1))

(define (move w)
  (make-ufo (+ (ufo-x w) (ufo-dx w))
            (+ (ufo-y w) (ufo-dy w))
            (ufo-dx w)
            (ufo-dy w)))

;; WorldSt -> Scene
;; place the ufo into MT at its current position

(check-expect (render (make-ufo 10 20 -1 +1))
              (place-image UFO 10 20 MT))

(define (render w)
  (place-image UFO (ufo-x w) (ufo-y w) MT))




;; WorldSt KeyEvt -> WorldSt
;; control the ufo’s direction via the arrow keys

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
 (control (make-ufo 5 8 -1 -1) "z")
 (make-ufo 5 8 -1 -1))

(define (control w ke)
  (cond
    [(key=? ke "up") (set-ufo-dy w -1)]
    [(key=? ke "down") (set-ufo-dy w +1)]
    [(key=? ke "left") (set-ufo-dx w -1)]
    [(key=? ke "right") (set-ufo-dx w +1)]
    [else w]))

;; WorldSt Int -> WorldSt
(define (set-ufo-dy u dy)
  (make-ufo (ufo-x u) (ufo-y u)
            (ufo-dx u) dy))

;; WorldSt Int -> WorldSt
(define (set-ufo-dx u dx)
  (make-ufo (ufo-x u) (ufo-y u)
            dx (ufo-dy u)))

;; WorldSt Nat Nat MouseEvt -> WorldSt
;; move the ufo to a new position on the canvas
(check-expect (hyper (make-ufo 10 20 -1 +1)
                     40 30 "button-up")
              (make-ufo 10 20 -1 +1))

(check-expect (hyper (make-ufo 10 20 -1 +1)
                     300 20 "button-down")
              (make-ufo 300 20 -1 +1))

(define (hyper w x y a)
  (cond
    [(mouse=? "button-down" a)
     (make-ufo x y (ufo-dx w) (ufo-dy w))]
    [else w]))

;; WorldSt -> Boolean
;; has the ufo landed?
(check-expect (landed? (make-ufo 5 (- SIZE 5) -1 +1))
              false)

(check-expect (landed? (make-ufo 5 SIZE -1 +1))
              true)

(define (landed? w)
  (>= (ufo-y w) SIZE))


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


;; WorldSt -> WorldSt
;; run a complete world program,
;; starting in state w0
(define (main w0)
  (big-bang w0
    (on-tick move)
    (on-draw render)
    (on-mouse hyper)
    (on-key control)
    (stop-when landed?)))

#;(main (make-ufo 20 10 -1 +1))

;; WorldSt is one of:
;; --- "rest"
;; --- (make-ufo Nat Nat Int Int)

;; WorldSt -> (U WorldSt Package) 
(define (move.global w)
  (cond
    [(string? w) w]
    [else (local ((define v (move w)))
            (if (not (landed? v))
                v
                (make-package "rest" "done")))]))


;; WorldSt "your-turn" -> WorldSt
;; assume: messages arrive only
;; if the state is "rest"
(define (receive w msg)
  (make-ufo 20 10 -1 +1))


;; String -> WorldSt
(define (main-for-client n)
  (big-bang "rest"
    (on-tick move.global)
    (on-draw (λ (w) (if (string? w) MT (render w))))
    (on-key (λ (w ke) (if (string? w) w (control w ke))))
    (on-receive receive)
    (on-mouse (λ (w x y a) (if (string? w) w (hyper w x y a))))
    (name n)
    (register LOCALHOST)))

(launch-many-worlds/proc
 (λ () (universe '()
                 (on-new add-world)
                 (on-msg switch)
                 (on-disconnect del-world)))

 (λ () (main-for-client "earth"))
 (λ () (main-for-client "mars"))
 (λ () (main-for-client "venus")))




