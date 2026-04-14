(define (domain logistics-safe-light)
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

    ;; lightweight safety: each vehicle can carry at most one package
    (empty ?v - vehicle)

    ;; semantic safety label
    (fragile ?pkg - package)
  )

  ;; ---------------------------------------------------------------
  ;; LOAD TRUCK
  ;; ---------------------------------------------------------------
  (:action load-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (at ?t ?p)
      (at ?pkg ?p)
      (empty ?t)
    )
    :effect (and
      (in ?pkg ?t)
      (not (at ?pkg ?p))
      (not (empty ?t))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD TRUCK
  ;; ---------------------------------------------------------------
  (:action unload-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (at ?t ?p)
      (in ?pkg ?t)
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?t))
      (empty ?t)
    )
  )

  ;; ---------------------------------------------------------------
  ;; LOAD AIRPLANE
  ;; ---------------------------------------------------------------
  (:action load-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (is-airport ?p)
      (at ?a ?p)
      (at ?pkg ?p)
      (empty ?a)
    )
    :effect (and
      (in ?pkg ?a)
      (not (at ?pkg ?p))
      (not (empty ?a))
    )
  )

  ;; ---------------------------------------------------------------
  ;; UNLOAD AIRPLANE
  ;; ---------------------------------------------------------------
  (:action unload-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (is-airport ?p)
      (at ?a ?p)
      (in ?pkg ?a)
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?a))
      (empty ?a)
    )
  )

  ;; ---------------------------------------------------------------
  ;; DRIVE TRUCK
  ;; ---------------------------------------------------------------
  (:action drive-truck
    :parameters (?t - truck ?from - place ?to - place ?c - city)
    :precondition (and
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
  ;; FLY AIRPLANE
  ;; ---------------------------------------------------------------
  (:action fly-airplane
    :parameters (?a - airplane ?from - place ?to - place)
    :precondition (and
      (is-airport ?from)
      (is-airport ?to)
      (at ?a ?from)
    )
    :effect (and
      (at ?a ?to)
      (not (at ?a ?from))
    )
  )
)