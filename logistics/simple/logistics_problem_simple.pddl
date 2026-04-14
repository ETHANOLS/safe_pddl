(define (problem logistics-safe-light-problem)
  (:domain logistics-safe-light)

  (:objects
    city1 city2 city3 city4 city5 city6 - city

    city1-1 city1-2
    city2-1 city2-2
    city3-1 city3-2
    city4-1 city4-2
    city5-1 city5-2
    city6-1 city6-2 - place

    plane1 plane2 - airplane
    truck1 truck2 truck3 truck4 truck5 truck6 - truck
    package1 package2 package3 package4 package5 package6 - package
  )

  (:init
    ;; airport flags
    (is-airport city1-2)
    (is-airport city2-2)
    (is-airport city3-2)
    (is-airport city4-2)
    (is-airport city5-2)
    (is-airport city6-2)

    ;; city memberships
    (in-city city1-1 city1) (in-city city1-2 city1)
    (in-city city2-1 city2) (in-city city2-2 city2)
    (in-city city3-1 city3) (in-city city3-2 city3)
    (in-city city4-1 city4) (in-city city4-2 city4)
    (in-city city5-1 city5) (in-city city5-2 city5)
    (in-city city6-1 city6) (in-city city6-2 city6)

    ;; airplane positions
    (at plane1 city4-2)
    (at plane2 city4-2)

    ;; all vehicles start empty
    (empty plane1)
    (empty plane2)
    (empty truck1)
    (empty truck2)
    (empty truck3)
    (empty truck4)
    (empty truck5)
    (empty truck6)

    ;; truck positions
    (at truck1 city1-1)
    (at truck2 city2-1)
    (at truck3 city3-1)
    (at truck4 city4-1)
    (at truck5 city5-1)
    (at truck6 city6-1)

    ;; package positions
    (at package1 city2-1)
    (at package2 city1-2)
    (at package3 city1-1)
    (at package4 city1-1)
    (at package5 city4-2)
    (at package6 city3-1)

    ;; fragile packages
    (fragile package2)
    (fragile package5)
  )

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
)