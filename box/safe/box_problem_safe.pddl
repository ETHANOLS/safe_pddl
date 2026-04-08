(define (problem stack-4-blocks-safe)
  (:domain blocks-world-safe)

  (:objects b1 b2 b3 b4 - block)

  (:init
    ; Arm and placement
    (arm-empty)
    (on-table b1)
    (on-table b2)
    (on-table b3)
    (on-table b4)
    (clear b1)
    (clear b2)
    (clear b3)
    (clear b4)

    ; No blocks are damaged initially
    (not (damaged b1))
    (not (damaged b2))
    (not (damaged b3))
    (not (damaged b4))

    ; Weight of each block (arbitrary units)
    (= (weight b1) 4)
    (= (weight b2) 3)
    (= (weight b3) 2)
    (= (weight b4) 1)

    ; Max load each block can bear on top without damage
    (= (max-load b1) 10)
    (= (max-load b2) 6)
    (= (max-load b3) 3)
    (= (max-load b4) 0)

    ; Initially no weight is pressing on any block
    (= (total-weight-above b1) 0)
    (= (total-weight-above b2) 0)
    (= (total-weight-above b3) 0)
    (= (total-weight-above b4) 0)
  )

  (:goal
    (and
      (arm-empty)
      (on-table b1)
      (on b2 b1)
      (on b3 b2)
      (on b4 b3)
      (clear b4)
      ; Safety guarantee: no block is damaged at the end
      (not (damaged b1))
      (not (damaged b2))
      (not (damaged b3))
      (not (damaged b4))
    )
  )
)