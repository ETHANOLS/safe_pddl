(define (problem logistics-safe-problem)
  (:domain logistics-safe)

  ;; -----------------------------------------------------------------
  ;; OBJECTS
  ;; All city locations (regular + airport) are plain "location" objects.
  ;; Airports are distinguished only by name convention (cityX-2).
  ;; -----------------------------------------------------------------
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
    ;; -----------------------------------------------------------------
    ;; ROAD LENGTHS  (symmetric; set representative distances)
    ;; Within-city (regular <-> airport): short hop = 2
    ;; -----------------------------------------------------------------
    (= (road-length city1-1 city1-2) 2)  (= (road-length city1-2 city1-1) 2)
    (= (road-length city2-1 city2-2) 2)  (= (road-length city2-2 city2-1) 2)
    (= (road-length city3-1 city3-2) 2)  (= (road-length city3-2 city3-1) 2)
    (= (road-length city4-1 city4-2) 2)  (= (road-length city4-2 city4-1) 2)
    (= (road-length city5-1 city5-2) 2)  (= (road-length city5-2 city5-1) 2)
    (= (road-length city6-1 city6-2) 2)  (= (road-length city6-2 city6-1) 2)

    ;; -----------------------------------------------------------------
    ;; COST / SCORE counters start at zero
    ;; -----------------------------------------------------------------
    (= (total-cost)    0)
    (= (security-score) 0)

    ;; -----------------------------------------------------------------
    ;; TRUCK CAPACITIES
    ;; weight-limit=4, space-limit=4 for all trucks; start empty
    ;; -----------------------------------------------------------------
    (= (weight-limit truck1) 4)  (= (space-limit truck1) 4)
    (= (weight-used  truck1) 0)  (= (space-used  truck1) 0)

    (= (weight-limit truck2) 4)  (= (space-limit truck2) 4)
    (= (weight-used  truck2) 0)  (= (space-used  truck2) 0)

    (= (weight-limit truck3) 4)  (= (space-limit truck3) 4)
    (= (weight-used  truck3) 0)  (= (space-used  truck3) 0)

    (= (weight-limit truck4) 4)  (= (space-limit truck4) 4)
    (= (weight-used  truck4) 0)  (= (space-used  truck4) 0)

    (= (weight-limit truck5) 4)  (= (space-limit truck5) 4)
    (= (weight-used  truck5) 0)  (= (space-used  truck5) 0)

    (= (weight-limit truck6) 4)  (= (space-limit truck6) 4)
    (= (weight-used  truck6) 0)  (= (space-used  truck6) 0)

    ;; -----------------------------------------------------------------
    ;; TRUCK POSITIONS
    ;; -----------------------------------------------------------------
    (at truck1 city1-1)
    (at truck2 city2-1)
    (at truck3 city3-1)
    (at truck4 city4-1)
    (at truck5 city5-1)
    (at truck6 city6-1)

    ;; -----------------------------------------------------------------
    ;; PACKAGE TYPES, WEIGHTS, AND SPACES
    ;;   standard: weight=1, space=1
    ;;   fragile:  weight=1, space=2
    ;;   heavy:    weight=2, space=1
    ;; -----------------------------------------------------------------

    ;; package1 — standard
    (standard package1)
    (= (pkg-weight package1) 1)
    (= (pkg-space  package1) 1)

    ;; package2 — fragile
    (fragile package2)
    (= (pkg-weight package2) 1)
    (= (pkg-space  package2) 2)

    ;; package3 — standard
    (standard package3)
    (= (pkg-weight package3) 1)
    (= (pkg-space  package3) 1)

    ;; package4 — heavy
    (heavy package4)
    (= (pkg-weight package4) 2)
    (= (pkg-space  package4) 1)

    ;; package5 — fragile
    (fragile package5)
    (= (pkg-weight package5) 1)
    (= (pkg-space  package5) 2)

    ;; package6 — standard
    (standard package6)
    (= (pkg-weight package6) 1)
    (= (pkg-space  package6) 1)

    ;; -----------------------------------------------------------------
    ;; PACKAGE INITIAL POSITIONS  (from original problem)
    ;; -----------------------------------------------------------------
    (at package1 city2-1)
    (at package2 city1-2)
    (at package3 city1-1)
    (at package4 city1-1)
    (at package5 city4-2)
    (at package6 city3-1)
  )

  ;; -----------------------------------------------------------------
  ;; GOAL: same delivery targets as original problem.
  ;; package1 stays at city2-1 (already there).
  ;; The budget constraint (total-cost <= budget) is enforced via
  ;; the metric and planner flags; the goal itself captures delivery.
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

  ;; -----------------------------------------------------------------
  ;; METRIC: maximize security-score
  ;; Use with a planner that supports :numeric-fluents + maximize,
  ;; e.g.:  --search "astar(lmcut())"  with a budget-cap on total-cost,
  ;; or an oversubscription / reward-maximizing planner.
  ;;
  ;; For Fast Downward (cost-minimization only), invert the metric:
  ;;   minimize (- 0 (security-score))   [negate to convert to min]
  ;; -----------------------------------------------------------------
  (:metric maximize (security-score))
)
