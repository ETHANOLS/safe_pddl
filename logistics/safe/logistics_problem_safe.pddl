(define (problem logistics-safe-problem)
  (:domain logistics-safe)

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
    ;; --- Airport flags ---
    (is-airport city1-2)
    (is-airport city2-2)
    (is-airport city3-2)
    (is-airport city4-2)
    (is-airport city5-2)
    (is-airport city6-2)

    ;; --- Refuel available at all airports ---
    (refuel-available city1-2)
    (refuel-available city2-2)
    (refuel-available city3-2)
    (refuel-available city4-2)
    (refuel-available city5-2)
    (refuel-available city6-2)

    ;; --- City memberships ---
    (in-city city1-1 city1) (in-city city1-2 city1)
    (in-city city2-1 city2) (in-city city2-2 city2)
    (in-city city3-1 city3) (in-city city3-2 city3)
    (in-city city4-1 city4) (in-city city4-2 city4)
    (in-city city5-1 city5) (in-city city5-2 city5)
    (in-city city6-1 city6) (in-city city6-2 city6)

    ;; --- Airplane positions & fuel ---
    (at plane1 city4-2)
    (at plane2 city4-2)
    (fuel-full plane1)
    (fuel-full plane2)

    ;; --- All vehicles are operational ---
    (operational plane1)
    (operational plane2)
    (operational truck1)
    (operational truck2)
    (operational truck3)
    (operational truck4)
    (operational truck5)
    (operational truck6)

    ;; --- All vehicles start with both slots free ---
    (slot-free-1 plane1) (slot-free-2 plane1)
    (slot-free-1 plane2) (slot-free-2 plane2)
    (slot-free-1 truck1) (slot-free-2 truck1)
    (slot-free-1 truck2) (slot-free-2 truck2)
    (slot-free-1 truck3) (slot-free-2 truck3)
    (slot-free-1 truck4) (slot-free-2 truck4)
    (slot-free-1 truck5) (slot-free-2 truck5)
    (slot-free-1 truck6) (slot-free-2 truck6)

    ;; --- Truck positions ---
    (at truck1 city1-1)
    (at truck2 city2-1)
    (at truck3 city3-1)
    (at truck4 city4-1)
    (at truck5 city5-1)
    (at truck6 city6-1)

    ;; --- Package positions ---
    (at package1 city2-1)
    (at package2 city1-2)
    (at package3 city1-1)
    (at package4 city1-1)
    (at package5 city4-2)
    (at package6 city3-1)

    ;; --- Fragile packages ---
    ;; package2 and package5 are marked fragile:
    ;; they can only be loaded into an empty vehicle
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
