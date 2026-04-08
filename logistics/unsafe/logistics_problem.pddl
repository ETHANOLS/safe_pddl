(define (problem logistics-problem)
  (:domain logistics)

  (:objects
    ;; Cities
    city1 city2 city3 city4 city5 city6 - city

    ;; Regular locations (one per city)
    city1-1 city2-1 city3-1 city4-1 city5-1 city6-1 - location

    ;; Airports (one per city)
    city1-2 city2-2 city3-2 city4-2 city5-2 city6-2 - airport

    ;; Airplanes
    plane1 plane2 - airplane

    ;; Trucks (one per city)
    truck1 truck2 truck3 truck4 truck5 truck6 - truck

    ;; Packages
    package1 package2 package3 package4 package5 package6 - package
  )

  (:init
    ;; --- City memberships: regular locations ---
    (in-city city1-1 city1)
    (in-city city2-1 city2)
    (in-city city3-1 city3)
    (in-city city4-1 city4)
    (in-city city5-1 city5)
    (in-city city6-1 city6)

    ;; --- City memberships: airports ---
    (in-city city1-2 city1)
    (in-city city2-2 city2)
    (in-city city3-2 city3)
    (in-city city4-2 city4)
    (in-city city5-2 city5)
    (in-city city6-2 city6)

    ;; --- Airplane initial positions ---
    (at plane1 city4-2)
    (at plane2 city4-2)

    ;; --- Truck initial positions ---
    (at truck1 city1-1)
    (at truck2 city2-1)
    (at truck3 city3-1)
    (at truck4 city4-1)
    (at truck5 city5-1)
    (at truck6 city6-1)

    ;; --- Package initial positions ---
    (at package1 city2-1)
    (at package2 city1-2)
    (at package3 city1-1)
    (at package4 city1-1)
    (at package5 city4-2)
    (at package6 city3-1)
  )

  (:goal
    (and
      ;; package1 stays at city2-1 (already there, but stated for completeness)
      (at package1 city2-1)

      ;; package2 must reach city6-2
      (at package2 city6-2)

      ;; package3 must reach city6-1
      (at package3 city6-1)

      ;; package4 must reach city3-2
      (at package4 city3-2)

      ;; package5 must reach city6-2
      (at package5 city6-2)

      ;; package6 must reach city1-2
      (at package6 city1-2)
    )
  )
)
