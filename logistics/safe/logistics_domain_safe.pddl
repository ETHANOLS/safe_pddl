(define (domain logistics-safe)
  (:requirements :strips :typing)

  (:types
    place city - object
    vehicle package - object
    truck airplane - vehicle
  )

  (:predicates
    ;; topology
    (in-city ?p - place ?c - city)
    (is-airport ?p - place)

    ;; positions
    (at ?x - object ?p - place)
    (in ?pkg - package ?v - vehicle)

    ;; capacity tokens: a vehicle "has" a slot when that slot is free
    (slot-free-1 ?v - vehicle)
    (slot-free-2 ?v - vehicle)

    ;; fragility
    (fragile ?pkg - package)
    ;; true when a vehicle is carrying at least one package (used to block fragile mixing)
    (carrying-any ?v - vehicle)

    ;; airplane fuel states
    (fuel-full ?a - airplane)
    (fuel-low  ?a - airplane)
    ;; (neither predicate true => empty => cannot fly)

    ;; maintenance: a vehicle must not be broken
    (operational ?v - vehicle)

    ;; refuel station (only airports have refuelling)
    (refuel-available ?p - place)
  )

  ;; ---------------------------------------------------------------
  ;; LOAD TRUCK  (non-fragile package into truck)
  ;; ---------------------------------------------------------------
  (:action load-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (operational ?t)
      (at ?t ?p)
      (at ?pkg ?p)
      (slot-free-1 ?t)           ;; at least one slot available
      (not (fragile ?pkg))       ;; use load-truck-fragile for fragile packages
    )
    :effect (and
      (in ?pkg ?t)
      (not (at ?pkg ?p))
      (not (slot-free-1 ?t))     ;; consume one slot
      (carrying-any ?t)
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD TRUCK  (fragile package — only allowed when truck is empty)
  ;; ---------------------------------------------------------------
  (:action load-truck-fragile
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (operational ?t)
      (at ?t ?p)
      (at ?pkg ?p)
      (fragile ?pkg)
      (slot-free-1 ?t)
      (slot-free-2 ?t)           ;; truck must be completely empty
    )
    :effect (and
      (in ?pkg ?t)
      (not (at ?pkg ?p))
      (not (slot-free-1 ?t))
      (carrying-any ?t)
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD TRUCK  (second package — only when truck carries no fragile)
  ;; ---------------------------------------------------------------
  (:action load-truck-second
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (operational ?t)
      (at ?t ?p)
      (at ?pkg ?p)
      (not (fragile ?pkg))
      (carrying-any ?t)          ;; already has one package
      (not (slot-free-1 ?t))     ;; slot 1 taken
      (slot-free-2 ?t)           ;; slot 2 still free
    )
    :effect (and
      (in ?pkg ?t)
      (not (at ?pkg ?p))
      (not (slot-free-2 ?t))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD TRUCK (first/only slot)
  ;; ---------------------------------------------------------------
  (:action unload-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (operational ?t)
      (at ?t ?p)
      (in ?pkg ?t)
      (slot-free-2 ?t)           ;; slot 2 is free => this was the only package
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?t))
      (slot-free-1 ?t)
      (not (carrying-any ?t))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD TRUCK (one of two packages)
  ;; ---------------------------------------------------------------
  (:action unload-truck-one-of-two
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (operational ?t)
      (at ?t ?p)
      (in ?pkg ?t)
      (not (slot-free-2 ?t))     ;; slot 2 is occupied => two packages on board
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?t))
      (slot-free-2 ?t)           ;; free up one slot; carrying-any stays true
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD AIRPLANE (non-fragile)
  ;; ---------------------------------------------------------------
  (:action load-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (at ?a ?p)
      (at ?pkg ?p)
      (slot-free-1 ?a)
      (not (fragile ?pkg))
    )
    :effect (and
      (in ?pkg ?a)
      (not (at ?pkg ?p))
      (not (slot-free-1 ?a))
      (carrying-any ?a)
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD AIRPLANE (fragile — plane must be empty)
  ;; ---------------------------------------------------------------
  (:action load-airplane-fragile
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (at ?a ?p)
      (at ?pkg ?p)
      (fragile ?pkg)
      (slot-free-1 ?a)
      (slot-free-2 ?a)
    )
    :effect (and
      (in ?pkg ?a)
      (not (at ?pkg ?p))
      (not (slot-free-1 ?a))
      (carrying-any ?a)
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD AIRPLANE (second package)
  ;; ---------------------------------------------------------------
  (:action load-airplane-second
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (at ?a ?p)
      (at ?pkg ?p)
      (not (fragile ?pkg))
      (carrying-any ?a)
      (not (slot-free-1 ?a))
      (slot-free-2 ?a)
    )
    :effect (and
      (in ?pkg ?a)
      (not (at ?pkg ?p))
      (not (slot-free-2 ?a))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD AIRPLANE (only package)
  ;; ---------------------------------------------------------------
  (:action unload-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (at ?a ?p)
      (in ?pkg ?a)
      (slot-free-2 ?a)
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?a))
      (slot-free-1 ?a)
      (not (carrying-any ?a))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD AIRPLANE (one of two)
  ;; ---------------------------------------------------------------
  (:action unload-airplane-one-of-two
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (at ?a ?p)
      (in ?pkg ?a)
      (not (slot-free-2 ?a))
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?a))
      (slot-free-2 ?a)
    )
  )

  ;; ---------------------------------------------------------------
  ;; DRIVE TRUCK
  ;; ---------------------------------------------------------------
  (:action drive-truck
    :parameters (?t - truck ?from - place ?to - place ?c - city)
    :precondition (and
      (operational ?t)
      (at ?t ?from)
      (in-city ?from ?c)
      (in-city ?to ?c)
    )
    :effect (and
      (at ?t ?to)
      (not (at ?t ?from))
    )
  )

  ;; ---------------------------------------------------------------
  ;; FLY AIRPLANE (full fuel -> becomes low)
  ;; ---------------------------------------------------------------
  (:action fly-airplane-full
    :parameters (?a - airplane ?from - place ?to - place)
    :precondition (and
      (operational ?a)
      (is-airport ?from)
      (is-airport ?to)
      (at ?a ?from)
      (fuel-full ?a)
    )
    :effect (and
      (at ?a ?to)
      (not (at ?a ?from))
      (not (fuel-full ?a))
      (fuel-low ?a)              ;; one flight consumes fuel
    )
  )

  ;; ---------------------------------------------------------------
  ;; FLY AIRPLANE (low fuel -> becomes empty; UNSAFE to fly again)
  ;; ---------------------------------------------------------------
  (:action fly-airplane-low
    :parameters (?a - airplane ?from - place ?to - place)
    :precondition (and
      (operational ?a)
      (is-airport ?from)
      (is-airport ?to)
      (at ?a ?from)
      (fuel-low ?a)
    )
    :effect (and
      (at ?a ?to)
      (not (at ?a ?from))
      (not (fuel-low ?a))        ;; now empty — cannot fly again until refuelled
    )
  )

  ;; ---------------------------------------------------------------
  ;; REFUEL AIRPLANE (only at airports with refuel stations)
  ;; ---------------------------------------------------------------
  (:action refuel-airplane
    :parameters (?a - airplane ?p - place)
    :precondition (and
      (operational ?a)
      (is-airport ?p)
      (refuel-available ?p)
      (at ?a ?p)
      (not (fuel-full ?a))
    )
    :effect (and
      (fuel-full ?a)
      (not (fuel-low ?a))
    )
  )
)
