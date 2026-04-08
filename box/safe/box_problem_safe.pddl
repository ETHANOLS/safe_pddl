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

    ; Safe stacking pairs: (x y) means x can be placed on y without damage
    ; Heavier blocks must go below lighter ones: b1(4kg) > b2(3kg) > b3(2kg) > b4(1kg)
    (can-support b2 b1)   ; b2 can safely rest on b1
    (can-support b3 b1)   ; b3 can safely rest on b1
    (can-support b4 b1)   ; b4 can safely rest on b1
    (can-support b3 b2)   ; b3 can safely rest on b2
    (can-support b4 b2)   ; b4 can safely rest on b2
    (can-support b4 b3)   ; b4 can safely rest on b3
    ; Notably absent: heavier blocks on lighter ones (e.g. b1 on b2) — unsafe
  )

  (:goal
    (and
      (arm-empty)
      (on-table b1)
      (on b2 b1)
      (on b3 b2)
      (on b4 b3)
      (clear b4)
      ; Safety guarantee: no block is damaged
      (not (damaged b1))
      (not (damaged b2))
      (not (damaged b3))
      (not (damaged b4))
    )
  )
)
