(define (domain blocks-world-safe)
  (:requirements :strips :typing :numeric-fluents)

  (:types block)

  (:predicates
    (on ?x - block ?y - block)       ; block x is on block y
    (on-table ?x - block)            ; block x is on the table
    (clear ?x - block)               ; nothing is on top of block x
    (arm-empty)                      ; the arm is not holding anything
    (holding ?x - block)             ; the arm is holding block x
    (damaged ?x - block)             ; block x has been damaged
  )

  (:functions
    (weight ?x - block)              ; the weight of block x
    (max-load ?x - block)            ; max weight block x can bear on top
    (total-weight-above ?x - block)  ; cumulative weight currently above block x
  )

  ; Pick up a block from the table (only if not damaged)
  (:action pickup
    :parameters (?x - block)
    :precondition (and (clear ?x)
                       (on-table ?x)
                       (arm-empty)
                       (not (damaged ?x)))
    :effect (and (holding ?x)
                 (not (on-table ?x))
                 (not (clear ?x))
                 (not (arm-empty)))
  )

  ; Put a block down on the table
  (:action putdown
    :parameters (?x - block)
    :precondition (holding ?x)
    :effect (and (on-table ?x)
                 (clear ?x)
                 (arm-empty)
                 (not (holding ?x))
                 (assign (total-weight-above ?x) 0))
  )

  ; Stack block x on top of block y — only if y can bear x's weight
  (:action stack
    :parameters (?x - block ?y - block)
    :precondition (and (holding ?x)
                       (clear ?y)
                       (not (damaged ?x))
                       (not (damaged ?y))
                       (<= (+ (weight ?x) (total-weight-above ?y))
                           (max-load ?y)))
    :effect (and (on ?x ?y)
                 (clear ?x)
                 (arm-empty)
                 (not (holding ?x))
                 (not (clear ?y))
                 (assign (total-weight-above ?x) 0)
                 (increase (total-weight-above ?y) (weight ?x)))
  )

  ; Unstack block x from on top of block y (only if neither is damaged)
  (:action unstack
    :parameters (?x - block ?y - block)
    :precondition (and (on ?x ?y)
                       (clear ?x)
                       (arm-empty)
                       (not (damaged ?x))
                       (not (damaged ?y)))
    :effect (and (holding ?x)
                 (clear ?y)
                 (not (on ?x ?y))
                 (not (clear ?x))
                 (not (arm-empty))
                 (decrease (total-weight-above ?y) (weight ?x)))
  )
)