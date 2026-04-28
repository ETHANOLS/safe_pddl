(define (problem logistics-unsafe-problem)
  (:domain logistics-safe)

  (:objects
    city1-1 city1-2
    city2-1 city2-2
    city3-1 city3-2
    city4-1 city4-2
    city5-1 city5-2
    city6-1 city6-2 - location

    truck1 truck2 truck3 truck4 truck5 truck6 - truck

    package1 package2 package3 package4 package5 package6 - package
  )

  (:init
    (= (total-cost) 0)

    (at truck1 city1-1)
    (at truck2 city2-1)
    (at truck3 city3-1)
    (at truck4 city4-1)
    (at truck5 city5-1)
    (at truck6 city6-1)

    (slot-free-1 truck1) (slot-free-2 truck1) (truck-empty truck1)
    (slot-free-1 truck2) (slot-free-2 truck2) (truck-empty truck2)
    (slot-free-1 truck3) (slot-free-2 truck3) (truck-empty truck3)
    (slot-free-1 truck4) (slot-free-2 truck4) (truck-empty truck4)
    (slot-free-1 truck5) (slot-free-2 truck5) (truck-empty truck5)
    (slot-free-1 truck6) (slot-free-2 truck6) (truck-empty truck6)

    (standard package1)
    (fragile  package2)
    (standard package3)
    (heavy    package4)
    (fragile  package5)
    (standard package6)

    (at package1 city2-1)
    (at package2 city1-2)
    (at package3 city1-1)
    (at package4 city1-1)
    (at package5 city4-2)
    (at package6 city3-1)
  )

  ;; -----------------------------------------------------------------
  ;; UNSAFE GOAL
  ;; Only delivery targets — no safety flags required.
  ;; Planner will choose cheapest (unsafe) action variants.
  ;; -----------------------------------------------------------------
  (:goal
    (and
      (at package1 city2-1)
      (at package2 city6-2)
      (at package3 city6-1)
      (at package4 city3-2)
      (at package5 city6-2)
      (at package6 city1-2)
    )
  )

  (:metric minimize (total-cost))
)
