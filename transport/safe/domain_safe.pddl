(define (domain logistics-safe)
  (:requirements :strips :typing :action-costs :negative-preconditions)

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
    ;; Package types
    (standard ?p - package)
    (fragile  ?p - package)
    (heavy    ?p - package)

    ;; Position
    (at ?x - locatable ?l - location)
    (in ?p - package ?t - truck)

    ;; Capacity (2 propositional slots per truck)
    (slot-free-1 ?t - truck)
    (slot-free-2 ?t - truck)

    ;; Fragile isolation: truck must be empty to load fragile
    (truck-empty ?t - truck)

    ;; Pair-action mutex: prevent choosing both actions in a pair
    (picked-up ?p - package)
    (dropped   ?p - package)

    ;; Safety quality flags (set by the safer variant of each pair)
    ;; pickup
    (carefully-picked ?p - package)   ;; pick_up_standard_careful
    (securely-picked  ?p - package)   ;; pick_up_fragile_secure
    (assisted-pick    ?p - package)   ;; pick_up_heavy_assisted
    ;; drop
    (carefully-dropped ?p - package)  ;; drop_standard_careful
    (carefully-dropped-fragile ?p - package) ;; drop_fragile_careful
    (assisted-drop    ?p - package)   ;; drop_heavy_assisted
    ;; drive
    (driven-slow      ?p - package)   ;; drive_slow
    (driven-fragile-safe ?p - package) ;; drive_fragile_safe
    (driven-heavy-safe ?p - package)  ;; drive_heavy_safe
    ;; optional
    (inspected ?p - package)
  )

  ;; -----------------------------------------------------------------
  ;; FUNCTIONS  (only total-cost allowed by FD)
  ;; -----------------------------------------------------------------
  (:functions
    (total-cost) - number
  )

  ;; =================================================================
  ;; DRIVE ACTIONS
  ;; Road length is fixed at 2 (within-city hop).
  ;; Costs: fast=2, slow=2+4=6, fragile_safe=2+6=8, heavy_safe=2+5=7
  ;; =================================================================

  ;; --- drive_fast (standard) ---
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
      (increase (total-cost) 2)
    )
  )

  ;; --- drive_slow (standard) ---
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
      (driven-slow ?p)
      (increase (total-cost) 6)
    )
  )

  ;; --- drive_fast (fragile) ---
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
      (increase (total-cost) 2)
    )
  )

  ;; --- drive_fragile_safe ---
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
      (driven-fragile-safe ?p)
      (increase (total-cost) 8)
    )
  )

  ;; --- drive_fast (heavy) ---
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
      (increase (total-cost) 2)
    )
  )

  ;; --- drive_heavy_safe ---
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
      (driven-heavy-safe ?p)
      (increase (total-cost) 7)
    )
  )

  ;; =================================================================
  ;; PICK-UP ACTIONS
  ;; Capacity: slot-free-1 must be free for first package;
  ;;           slot-free-2 must be free for second package.
  ;; Fragile packages require truck-empty (both slots free).
  ;; picked-up mutex prevents choosing two pickup variants.
  ;; =================================================================

  ;; --- pick_up_standard_normal (first package) ---  cost=1
  (:action pick_up_standard_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 1)
    )
  )

  ;; --- pick_up_standard_normal (second package) ---  cost=1
  (:action pick_up_standard_normal_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (not (slot-free-1 ?t))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (not (slot-free-2 ?t))
      (increase (total-cost) 1)
    )
  )

  ;; --- pick_up_standard_careful (first package) ---  cost=2
  (:action pick_up_standard_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (carefully-picked ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 2)
    )
  )

  ;; --- pick_up_standard_careful (second package) ---  cost=2
  (:action pick_up_standard_careful_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (not (slot-free-1 ?t))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (carefully-picked ?p)
      (not (slot-free-2 ?t))
      (increase (total-cost) 2)
    )
  )

  ;; --- pick_up_fragile_normal ---  cost=3  (truck must be empty)
  (:action pick_up_fragile_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 3)
    )
  )

  ;; --- pick_up_fragile_secure ---  cost=6  (truck must be empty)
  (:action pick_up_fragile_secure
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (securely-picked ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 6)
    )
  )

  ;; --- pick_up_heavy_normal (first package) ---  cost=3
  (:action pick_up_heavy_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 3)
    )
  )

  ;; --- pick_up_heavy_normal (second package) ---  cost=3
  (:action pick_up_heavy_normal_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (not (slot-free-1 ?t))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (not (slot-free-2 ?t))
      (increase (total-cost) 3)
    )
  )

  ;; --- pick_up_heavy_assisted (first package) ---  cost=6
  (:action pick_up_heavy_assisted
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (slot-free-1 ?t)
      (truck-empty ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (assisted-pick ?p)
      (not (slot-free-1 ?t))
      (not (truck-empty ?t))
      (increase (total-cost) 6)
    )
  )

  ;; --- pick_up_heavy_assisted (second package) ---  cost=6
  (:action pick_up_heavy_assisted_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (at ?p ?l) (at ?t ?l)
      (not (picked-up ?p))
      (not (slot-free-1 ?t))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (at ?p ?l))
      (in ?p ?t)
      (picked-up ?p)
      (assisted-pick ?p)
      (not (slot-free-2 ?t))
      (increase (total-cost) 6)
    )
  )

  ;; =================================================================
  ;; DROP ACTIONS
  ;; =================================================================

  ;; --- drop_standard_normal (was the only package) ---  cost=1
  (:action drop_standard_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (slot-free-2 ?t)          ;; slot 2 free => this is the only package
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 1)
    )
  )

  ;; --- drop_standard_normal (one of two) ---  cost=1
  (:action drop_standard_normal_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (not (slot-free-2 ?t))    ;; slot 2 occupied => two packages on board
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (slot-free-2 ?t)
      (increase (total-cost) 1)
    )
  )

  ;; --- drop_standard_careful (only package) ---  cost=2
  (:action drop_standard_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (carefully-dropped ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 2)
    )
  )

  ;; --- drop_standard_careful (one of two) ---  cost=2
  (:action drop_standard_careful_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (standard ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (not (slot-free-2 ?t))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (carefully-dropped ?p)
      (slot-free-2 ?t)
      (increase (total-cost) 2)
    )
  )

  ;; --- drop_fragile_normal ---  cost=3  (fragile always solo → restores truck-empty)
  (:action drop_fragile_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 3)
    )
  )

  ;; --- drop_fragile_careful ---  cost=6
  (:action drop_fragile_careful
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (fragile ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (carefully-dropped-fragile ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 6)
    )
  )

  ;; --- drop_heavy_normal (only package) ---  cost=3
  (:action drop_heavy_normal
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 3)
    )
  )

  ;; --- drop_heavy_normal (one of two) ---  cost=3
  (:action drop_heavy_normal_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (not (slot-free-2 ?t))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (slot-free-2 ?t)
      (increase (total-cost) 3)
    )
  )

  ;; --- drop_heavy_assisted (only package) ---  cost=6
  (:action drop_heavy_assisted
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (slot-free-2 ?t)
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (assisted-drop ?p)
      (slot-free-1 ?t)
      (truck-empty ?t)
      (increase (total-cost) 6)
    )
  )

  ;; --- drop_heavy_assisted (one of two) ---  cost=6
  (:action drop_heavy_assisted_second
    :parameters (?p - package ?t - truck ?l - location)
    :precondition (and
      (heavy ?p)
      (in ?p ?t) (at ?t ?l)
      (not (dropped ?p))
      (not (slot-free-2 ?t))
    )
    :effect (and
      (not (in ?p ?t))
      (at ?p ?l)
      (dropped ?p)
      (assisted-drop ?p)
      (slot-free-2 ?t)
      (increase (total-cost) 6)
    )
  )

  ;; =================================================================
  ;; OPTIONAL ACTION: inspect  cost=2
  ;; Can be applied to any package at any location before pickup.
  ;; =================================================================
  (:action inspect
    :parameters (?p - package ?l - location)
    :precondition (and
      (at ?p ?l)
      (not (inspected ?p))
    )
    :effect (and
      (inspected ?p)
      (increase (total-cost) 2)
    )
  )
)
