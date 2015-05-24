#lang racket
(require 2htdp/image)
(require 2htdp/universe)

;;------------------------------------------------------------------------------

;; Purpose: Design a Bin-Packing game

;;-----------------------------Data Definitions---------------------------------
;; A Posn is a (make-posn Number Number)
;; x and y are positions in grid-square coordinates
 
 (define-struct posn (x y))
;; A Block is a (make-block Number Number Color)
;;x and y are the position of the block in grid-square coordinates

(define-struct block (x y color))

;Examples of Blocks:

(define block1 (make-block 0 0 "blue"))
(define block2 (make-block 3 -1 "red"))
(define block3 (make-block 8 19 "green"))
(define block4 (make-block 7 9 "purple"))
(define block5 (make-block 1 9 "purple"))
(define block6 (make-block -1 9 "purple"))
(define block7 (make-block 10 9 "purple"))
(define block8 (make-block 5 20 "purple"))

;;------------------

;; A Tetra is a (make-tetra Posn BSet)
;; The center point is the point around which the tetra rotates
;; when it spins in grid-square coordinates

(define-struct tetra (center blocks))

;Examples of Tetra:
;See constants for examples of initial Tetra
(define tetra1 (make-tetra (make-posn 4 9) 
                           (list (make-block 4 9 "green") 
                                 (make-block 5 9 "blue")
                                 (make-block 4 10 "purple") 
                                 (make-block 5 10 "yellow"))))
(define tetra2 (make-tetra (make-posn 6.5 5.5) 
                           (list (make-block 6 5 "blue") 
                                 (make-block 7 5 "blue")
                                 (make-block 8 5 "blue") 
                                 (make-block 9 5"blue"))))
(define tetra3 (make-tetra (make-posn 3.5 9.5) 
                           (list (make-block 3 10 "purple") 
                                 (make-block 4 10 "purple")
                                 (make-block 5 10 "purple") 
                                 (make-block 5 9 "purple"))))
(define tetra4 (make-tetra (make-posn .5 9.5)
                           (list (make-block 0 10 "purple")
                                 (make-block 1 10 "purple")
                                 (make-block 2 10 "purple")
                                 (make-block 2 9 "purple"))))
(define tetra5 (make-tetra (make-posn 7.5 9.5)
                           (list (make-block 7 10 "purple")
                                 (make-block 8 10 "purple")
                                 (make-block 9 10 "purple")
                                 (make-block 9 9 "purple"))))
(define tetra6 (make-tetra (make-posn 3.5 18.5)
                           (list (make-block 3 19 "purple")
                                 (make-block 4 19 "purple")
                                 (make-block 5 19 "purple")
                                 (make-block 5 18 "purple"))))
(define tetra7 (make-tetra (make-posn 3.5 2.5)
                           (list (make-block 3 1 "aqua")
                                 (make-block 3 2 "aqua")
                                 (make-block 4 2 "aqua")
                                 (make-block 5 2 "aqua"))))   
;;------------------

;; A Set of Blocks (BSet) is one of:
;; - empty
;; - (cons Block BSet)

;; Order does not matter.

;Examples of BSet:
(define bset1 empty)
(define bset2 (cons block1 empty))
(define bset3 (list block1 block2))
(define bset4 (list block1 block2 block3))
(define bset5 (list (make-block 6 18 "purple")
                    (make-block 6 19 "purple")
                    (make-block 5 19 "purple")
                    (make-block 4 19 "purple")
                    (make-block 3 19 "blue")
                    (make-block 2 19 "blue")
                    (make-block 1 19 "blue")
                    (make-block 0 19 "blue")
                    (make-block 9 18 "purple")
                    (make-block 9 19 "purple")
                    (make-block 8 19 "purple")
                    (make-block 7 19 "purple")))
(define bset6 (list (make-block 5 -3 "blue")
                    (make-block 5 -2 "blue")
                    (make-block 5 -1 "blue")
                    (make-block 5 0 "blue")))
(define bset7 (list block4 block5))
(define bset8 (cons block6 empty))
(define bset9 (cons block7 empty))  
(define bset10 (cons block8 empty))
(define bset11 (append bset5 (list 
                              (make-block 5 18 "purple")
                              (make-block 4 18 "purple")
                              (make-block 3 18 "blue")
                              (make-block 2 18 "blue")
                              (make-block 1 18 "blue")
                              (make-block 0 18 "blue")
                              (make-block 8 18 "purple")
                              (make-block 7 18 "purple"))))
;;------------------

;; A World is a (make-world Tetra BSet Number)

;; The BSet represents the pile of blocks at the bottom of the screen.
;; Score is a number that represents the number of blocks that are either in the pile
;; or were in a completed row.

(define-struct world (tetra pile score))

;Examples of World
(define world1 (make-world tetra1 bset1 0))
(define world2 (make-world tetra2 bset2 0))
(define world3 (make-world tetra3 bset3 0))
(define world4 (make-world tetra3 bset4 0))
(define world5 (make-world tetra7 bset5 0))
(define world6 (make-world tetra4 bset1 0))
(define world7 (make-world tetra5 bset1 0))
(define world8 (make-world tetra6 bset1 0))
(define world9 (make-world tetra6 bset6 0))
(define world10 (make-world tetra4 bset7 0))
(define world11 (make-world tetra5 bset7 0))
(define world12 (make-world tetra6 bset5 0))
(define world13 (make-world tetra1 bset11 0))

;;--------------Constants---------------
(define INITIAL-SCORE 0)
(define GAME-OVER-MESSAGE "Game Over")
(define GRID-SQUARE-SIZE 20)
(define EMPTY-SCENE (empty-scene (* 10 GRID-SQUARE-SIZE) 
                                 (* 20 GRID-SQUARE-SIZE)))
(define INITIAL-TETRA-O (make-tetra (make-posn 4.5 -.5) 
                                    (list (make-block 4 -1 "green") 
                                          (make-block 5 -1 "green")
                                          (make-block 4 0 "green") 
                                          (make-block 5 0 "green"))))

(define INITIAL-TETRA-I (make-tetra (make-posn 4.5 -.5) 
                                    (list (make-block 3 -1 "blue") 
                                          (make-block 4 -1 "blue")
                                          (make-block 5 -1 "blue") 
                                          (make-block 6 -1 "blue"))))

(define INITIAL-TETRA-L (make-tetra (make-posn 4.5 .5) 
                                    (list (make-block 3 0 "purple") 
                                          (make-block 4 0 "purple")
                                          (make-block 5 0 "purple") 
                                          (make-block 5 -1 "purple"))))

(define INITIAL-TETRA-J (make-tetra (make-posn 3.5 .5) 
                                    (list (make-block 3 -1 "aqua") 
                                          (make-block 3 0 "aqua")
                                          (make-block 4 0 "aqua") 
                                          (make-block 5 0 "aqua"))))

(define INITIAL-TETRA-T (make-tetra (make-posn 4.5 .5) 
                                    (list (make-block 3 0 "orange") 
                                          (make-block 4 0 "orange")
                                          (make-block 4 -1 "orange") 
                                          (make-block 5 0 "orange"))))

(define INITIAL-TETRA-Z (make-tetra (make-posn 4.5 .5) 
                                    (list (make-block 3 -1 "pink") 
                                          (make-block 4 -1 "pink")
                                          (make-block 4 0 "pink") 
                                          (make-block 5 0 "pink"))))

(define INITIAL-TETRA-S (make-tetra (make-posn 4.5 .5) 
                                    (list (make-block 3 0 "red") 
                                          (make-block 4 0 "red")
                                          (make-block 4 -1 "red") 
                                          (make-block 5 -1 "red"))))

;;--------------------------------------

;;rotate-cw: World -> World
;;rotate the tetra in world clock-wise
(define (rotate-cw world)
  (make-world (make-tetra (tetra-center (world-tetra world))
                          (bset-rotate-cw (tetra-blocks (world-tetra world))
                                          (tetra-center (world-tetra world))))
              (world-pile world)
              (world-score world)))
;;------------------

;;bset-rotate-cw: BSet Posn -> BSet
;;rotate bset blocks around posn clockwise
(define (bset-rotate-cw bset posn)
  (map (lambda (block) (block-rotate-cw block posn)) bset))

;;--------------------------------------

;;block-rotate-cw : Block Posn -> Block
;;rotate the block 90 degrees clockwise around the posn.
(define (block-rotate-cw b c)
  (make-block (+ (posn-x c)
                 (- (posn-y c)
                    (block-y b)))
              (+ (posn-y c)
                 (- (block-x b)
                    (posn-x c)))
              (block-color b)))
;;------------------

;;rotate-ccw: World -> World
;;rotate tetra in world around counterclockwise
(define (rotate-ccw world)
  (rotate-cw (rotate-cw (rotate-cw world))))

;;------------------

;;add-block-to-scene: Block Image-> Image 
;;add a block image to scene
(define (add-block-to-scene block scene)
  (place-image (overlay (square GRID-SQUARE-SIZE "outline" "black") 
                        (square GRID-SQUARE-SIZE "solid" (block-color block)))
               (+ (* GRID-SQUARE-SIZE (block-x block)) (/ GRID-SQUARE-SIZE 2)) 
               (+ (* GRID-SQUARE-SIZE (block-y block)) (/ GRID-SQUARE-SIZE 2))
               scene))

;;------------------

;;add-bset-to-scene: Bset Image -> Image
;;create an image of the blocks of bset
(define (add-bset-to-scene bset scene)
  (foldr add-block-to-scene scene bset))

;;------------------

;;draw-world: World -> Image
;;create an image containing world
(define (draw-world world)
  (add-bset-to-scene (tetra-blocks (world-tetra world)) 
                     (add-bset-to-scene (world-pile world)
                                        EMPTY-SCENE)))
;;------------------

;;random-tetra: Number -> Tetra
;;return tetra that is a random number num
(define (random-tetra num)
  (cond[(= num 0) INITIAL-TETRA-O]
       [(= num 1) INITIAL-TETRA-I]
       [(= num 2) INITIAL-TETRA-L]
       [(= num 3) INITIAL-TETRA-J]
       [(= num 4) INITIAL-TETRA-T]
       [(= num 5) INITIAL-TETRA-Z]
       [(= num 6) INITIAL-TETRA-S]))

;;------------------

;new-world: Number -> World
;;make a new blank world where num is the inital tetra for world
(define (new-world num)
  (make-world (random-tetra num) empty INITIAL-SCORE))

;;------------------

;;move-down: World -> World
;move tetra in world down one block
(define (move-down world)
  (make-world (make-tetra (move-posn (tetra-center (world-tetra world)) 0 1)  
                          (move-bset (tetra-blocks (world-tetra world)) 0 1))
              (world-pile world)
              (world-score world)))

;;------------------

;;handle-key: World Key-Event -> World 
;;change world based on ke
(define (handle-key world ke)
  (cond[(and (string=? ke "left") 
             (no-overlap? (move-left world))) 
        (move-left world)]
       [(and (string=? ke "right")
             (no-overlap? (move-right world)))
        (move-right world)]
       [(and (string=? ke "s")
             (no-overlap? (rotate-cw world)))
        (rotate-cw world)]
       [(and(string=? ke "a")
            (no-overlap? (rotate-ccw world)))
        (rotate-ccw world)]
       [(string=? ke "r") (new-world (random 7))]
       [else world]))

;;------------------

;;move-bset: Bset Number Number-> Bset
;;move blocks in bset by x and y
(define (move-bset bset x y)
  (map (lambda (block)
         (make-block (+ (block-x block) x)
                     (+ (block-y block) y)
                     (block-color block)))
       bset))

;;------------------

;;move-posn: Posn Number Number -> Posn
;;move posn values by x and y
(define (move-posn posn x y)
  (make-posn (+ (posn-x posn) x) (+ (posn-y posn) y)))

;;------------------

;;move-left: World -> World
;;move tetra in world left one grid-square
(define (move-left world)
  (make-world (make-tetra (move-posn (tetra-center (world-tetra world)) -1 0) 
                          (move-bset (tetra-blocks (world-tetra world)) -1 0))
              (world-pile world)
              (world-score world)))

;;------------------

;;move-right:  World -> World
;;move tetra in world left one grid-square
(define (move-right world)
  (make-world (make-tetra (move-posn (tetra-center (world-tetra world)) 1 0) 
                          (move-bset (tetra-blocks (world-tetra world)) 1 0)) 
              (world-pile world)
              (world-score world)))

;;------------------

;;in-bounds?: BSet -> Boolean
;;are there no block in bset that are out of bounds?
(define (in-bounds? bset)
  (andmap (lambda (block) 
            (and(<= 0 (block-x block))
                (>= 9 (block-x block))
                (>= 19 (block-y block))))
          bset))

;;------------------

;;add-to-pile: World -> World
;;add tetra to pile of world
(define (add-to-pile world)
  (make-world (world-tetra world)
              (append (world-pile world) 
                      (tetra-blocks (world-tetra world)))
              (world-score world)))

;;------------------

;;check-collide-block?: Block BSet -> Boolean
;;is block overlaping the blocks in pile?
(define (check-collide-block? block pile)
  (ormap (lambda (pile-block)
            (and (= (block-y block) (block-y pile-block))
                      (= (block-x block) (block-x pile-block))))
         pile))

;;------------------

;;check-collide-bset?: BSet BSet -> Boolean
;;are the blocks in tetra overlaping blocks in pile?
(define (check-collide-bset? tetra pile)
  (ormap (lambda (block)
                  (check-collide-block? block pile))
         tetra))

;;------------------

;;no-overlap?: World -> Boolean
;;is tetra in world in bounds and not overlaping any blocks in world's pile?
(define (no-overlap? world)
  (and (in-bounds? (tetra-blocks (world-tetra world)))
   	(not (check-collide-bset? (tetra-blocks (world-tetra world))
                             	(world-pile world)))))

;;------------------

;;cycle-tetra: World -> World
;;add current terta to pile and give world a new tetra
(define (cycle-tetra world) 
  (make-world (random-tetra (random 7)) 
              (world-pile (add-to-pile world)) 
              (world-score world)))

;;------------------

;;next-world: World -> World
;;create the next world 
(define (next-world world)
  (cond[(not (no-overlap? (move-down world))) (remove-lines (cycle-tetra world))]
       [else (move-down world)]))

;;------------------

;;remove-lines: World -> World
;;removes lines that are complete in world, 
;;moves blocks above moved lines down one block,
;;and adds removed blocks to score
(define (remove-lines world)
  (foldr (lambda (row base-world) 
           (if (= 10 (length (filter 
                              (lambda (block) (= (block-y block) row)) 
                              (world-pile base-world)))) 
               (remove-row base-world row) base-world))
           world  
           (reverse (build-list 20 add1))))

;;------------------

;;remove-row: World Number -> World
;;removes blocks with a y value of row in world and adds blocks to score
(define (remove-row world row)
  (make-world (world-tetra world) 
              (foldr (lambda (block rest) 
                       (if (not (= (block-y block) row)) 
                           (if (< (block-y block) row) 
                               (cons (make-block (block-x block)
                                           (add1 (block-y block))
                                           (block-color block)) rest)
                               (cons block rest))
                           rest)) 
                     empty (world-pile world))
              (+ 10 (world-score world))))

;;------------------

;;over?: World -> Boolean
;;are any blocks in pile above the screen?
(define (over? world)
  (ormap (lambda (block) 
           (> 0 (block-y block)))
         (world-pile world)))

;;------------------

;;score: World -> Number
;;calculate the number of blocks in world
(define (score world)
  (+ (length (world-pile world)) (world-score world)))

;;------------------

;;game-over: World -> Image
;;display score and game over message
(define (game-over world)
  (place-image (text (number->string 
                      (floor (/ (score world) 4))) 24 "black") 
               100 
               200
               (place-image 
                (text GAME-OVER-MESSAGE 24 "black") 100 50
                (draw-world world)))) 

;;------------------

;;BIG BANG
(define INITIAL-WORLD (make-world (random-tetra (random 7)) bset1 INITIAL-SCORE))
(big-bang INITIAL-WORLD
          (on-tick next-world .20)
          (to-draw draw-world)
          (on-key handle-key)
          (stop-when over? game-over)) 