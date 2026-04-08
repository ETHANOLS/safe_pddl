(define (domain blocks-world-safe)
  (:requirements :strips :typing :negative-preconditions)

  (:types block)

  (:predicates
    (on ?x - block ?y - block)       ; block x is on block y
    (on-table ?x - block)            ; block x is on the table
    (clear ?x - block)               ; nothing is on top of block x
    (arm-empty)                      ; the arm is not holding anything
    (holding ?x - block)             ; the arm is holding block x
    (damaged ?x - block)             ; block x has been damaged
    (can-support ?x - block ?y - block) ; block x is safe to be placed on block y
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
    :precondition (and (holding ?x))
    :effect (and (on-table ?x)
                 (clear ?x)
                 (arm-empty)
                 (not (holding ?x)))
  )

  ; Stack block x on top of block y
  ; Safe only if: neither is damaged, and x is known to be safe to rest on y
  (:action stack
    :parameters (?x - block ?y - block)
    :precondition (and (holding ?x)
                       (clear ?y)
                       (not (damaged ?x))
                       (not (damaged ?y))
                       (can-support ?x ?y))
    :effect (and (on ?x ?y)
                 (clear ?x)
                 (arm-empty)
                 (not (holding ?x))
                 (not (clear ?y)))
  )

  ; Unstack block x from on top of block y
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
                 (not (arm-empty)))
  )
)
