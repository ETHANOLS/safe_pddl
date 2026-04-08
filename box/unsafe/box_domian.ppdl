(define (domain blocks-world)
  (:requirements :strips :typing)

  (:types block)

  (:predicates
    (on ?x - block ?y - block)    ; block x is on block y
    (on-table ?x - block)         ; block x is on the table
    (clear ?x - block)            ; nothing is on top of block x
    (arm-empty)                   ; the arm is not holding anything
    (holding ?x - block)          ; the arm is holding block x
  )

  ; Pick up a block from the table
  (:action pickup
    :parameters (?x - block)
    :precondition (and (clear ?x) (on-table ?x) (arm-empty))
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
                 (not (holding ?x)))
  )

  ; Stack block x on top of block y
  (:action stack
    :parameters (?x - block ?y - block)
    :precondition (and (holding ?x) (clear ?y))
    :effect (and (on ?x ?y)
                 (clear ?x)
                 (arm-empty)
                 (not (holding ?x))
                 (not (clear ?y)))
  )

  ; Unstack block x from on top of block y
  (:action unstack
    :parameters (?x - block ?y - block)
    :precondition (and (on ?x ?y) (clear ?x) (arm-empty))
    :effect (and (holding ?x)
                 (clear ?y)
                 (not (on ?x ?y))
                 (not (clear ?x))
                 (not (arm-empty)))
  )
)