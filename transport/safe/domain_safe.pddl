(define (domain logistics-safe)
  (:requirements :strips :typing :numeric-fluents)

  ;; -----------------------------------------------------------------
  ;; TYPES
  ;; -----------------------------------------------------------------
  (:types
    location - object
    locatable - object
    truck package - locatable
  )

  ;; -----------------------------------------------------------------
  ;; PREDICATES
  ;; -----------------------------------------------------------------
  (:predicates
    ;; Package type flags
    (standard ?p - package)
    (fragile  ?p - package)
    (heavy    ?p - package)

    ;; Position
    (at ?x - locatable ?l - location)
    (in ?p - package ?t - truck)

    ;; Safety status flags (set by optional/pair actions)
    (inspected ?p - package)   ;; set by inspect action
    (secured   ?p - package)   ;; set by pick_up_fragile_secure
    (assisted  ?p - package)   ;; set by pick_up_heavy_assisted / drop_heavy_assisted

    ;; Pair-action mutex flags — ensure exactly one of each pair is chosen.
    ;; Set when a package is picked up / dropped; cleared when the other
    ;; action in the pair would have been valid (i.e. after drop).
    (picked-up ?p - package)   ;; prevents double pickup
    (dropped   ?p - package)   ;; prevents double drop
  )

  ;; -----------------------------------------------------------------
  ;; FUNCTIONS
  ;; -----------------------------------------------------------------
  (:functions
    (road-length ?l1 ?l2 - location)   ;; distance between two locations
    (total-cost)                        ;; accumulated plan cost
    (security-score)                    ;; accumulated security score

    ;; Per-truck capacity tracking
    (weight-used  ?t - truck)
    (space-used   ?t - truck)
    (weight-limit ?t - truck)
    (space-limit  ?t - truck)

    ;; Per-package attributes (set in problem init)
    (pkg-weight ?p - package)
    (pkg-space  ?p - package)
  )

  ;; =================================================================
  ;; DRIVE ACTIONS
  ;; Each pair: drive_fast  vs.  the safe alternative.
  ;; For standard cargo:  drive_fast / drive_slow
  ;; For fragile cargo:   drive_fast / drive_fragile_safe
  ;; For heavy cargo:     drive_fast / drive_heavy_safe
  ;; The truck must have the right kind of package loaded.
  ;; =================================================================

  ;; --- drive_fast (standard) ---
  ;; cost = road_length, score = 4
  (:action drive_fast_standard
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (standard ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (road-length ?from ?to))
      (increase (security-score) 4)
    )
  )

  ;; --- drive_slow (standard) ---
  ;; cost = road_length + 4, score = 10
  (:action drive_slow
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (standard ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (+ (road-length ?from ?to) 4))
      (increase (security-score) 10)
    )
  )

  ;; --- drive_fast (fragile) ---
  ;; cost = road_length, score = 4
  (:action drive_fast_fragile
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (fragile ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (road-length ?from ?to))
      (increase (security-score) 4)
    )
  )

  ;; --- drive_fragile_safe ---
  ;; cost = road_length + 6, score = 12
  (:action drive_fragile_safe
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (fragile ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (+ (road-length ?from ?to) 6))
      (increase (security-score) 12)
    )
  )

  ;; --- drive_fast (heavy) ---
  ;; cost = road_length, score = 4
  (:action drive_fast_heavy
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (heavy ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (road-length ?from ?to))
      (increase (security-score) 4)
    )
  )

  ;; --- drive_heavy_safe ---
  ;; cost = road_length + 5, score = 10
  (:action drive_heavy_safe
    :parameters (?t - truck ?from - location ?to - location ?p - package)
    :precondition (and
      (at ?t ?from)
      (in ?p ?t)
      (heavy ?p)
    )
    :effect (and
      (not (at ?t ?from))
      (at ?t ?to)
      (increase (total-cost)    (+ (road-length ?from ?to) 5))
      (increase (security-score) 10)
    )
  )

  ;; =================================================================
  ;; PICK-UP ACTIONS  (pair — exactly one per package)
  ;; Guards: (not (picked-up ?p)) ensures the pair is chosen only once.
  ;; =================================================================

  ;; --- pick_up_standard_normal ---  cost=1, score=9
  (:action pick_up_standard_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    1)
      (increase (security-score) 9)
    )
  )

  ;; --- pick_up_standard_careful ---  cost=2, score=10
  (:action pick_up_standard_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    2)
      (increase (security-score) 10)
    )
  )

  ;; --- pick_up_fragile_normal ---  cost=3, score=7
  (:action pick_up_fragile_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    3)
      (increase (security-score) 7)
    )
  )

  ;; --- pick_up_fragile_secure ---  cost=6, score=12
  (:action pick_up_fragile_secure
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (secured ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    6)
      (increase (security-score) 12)
    )
  )

  ;; --- pick_up_heavy_normal ---  cost=3, score=7
  (:action pick_up_heavy_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    3)
      (increase (security-score) 7)
    )
  )

  ;; --- pick_up_heavy_assisted ---  cost=6, score=10
  (:action pick_up_heavy_assisted
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l)
      (at ?t ?l)
      (not (picked-up ?p))
      (<= (+ (weight-used ?t) (pkg-weight ?p)) (weight-limit ?t))
      (<= (+ (space-used  ?t) (pkg-space  ?p)) (space-limit  ?t))
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (assisted ?p)
      (increase (weight-used ?t) (pkg-weight ?p))
      (increase (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    6)
      (increase (security-score) 10)
    )
  )

  ;; =================================================================
  ;; DROP ACTIONS  (pair — exactly one per package)
  ;; =================================================================

  ;; --- drop_standard_normal ---  cost=1, score=7
  (:action drop_standard_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    1)
      (increase (security-score) 7)
    )
  )

  ;; --- drop_standard_careful ---  cost=2, score=9
  (:action drop_standard_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    2)
      (increase (security-score) 9)
    )
  )

  ;; --- drop_fragile_normal ---  cost=3, score=5
  (:action drop_fragile_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    3)
      (increase (security-score) 5)
    )
  )

  ;; --- drop_fragile_careful ---  cost=6, score=12
  (:action drop_fragile_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    6)
      (increase (security-score) 12)
    )
  )

  ;; --- drop_heavy_normal ---  cost=3, score=6
  (:action drop_heavy_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    3)
      (increase (security-score) 6)
    )
  )

  ;; --- drop_heavy_assisted ---  cost=6, score=10
  (:action drop_heavy_assisted
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t)
      (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (decrease (weight-used ?t) (pkg-weight ?p))
      (decrease (space-used  ?t) (pkg-space  ?p))
      (increase (total-cost)    6)
      (increase (security-score) 10)
    )
  )

  ;; =================================================================
  ;; OPTIONAL ACTION: inspect
  ;; Can be applied to any package at any location; cost=2, score=10
  ;; =================================================================
  (:action inspect
    :parameters (?p - package ?l - location)
    :precondition (and
      (at ?p ?l)
      (not (inspected ?p))
    )
    :effect (and
      (inspected ?p)
      (increase (total-cost)    2)
      (increase (security-score) 10)
    )
  )
)
