(define (domain logistics)
  (:requirements :strips :typing)

  (:types
    place city - object
    vehicle package - object
    truck airplane - vehicle
  )

  (:predicates
    (in-city ?p - place ?c - city)
    (at ?x - object ?p - place)
    (in ?pkg - package ?v - vehicle)
    (is-airport ?p - place)
  )

  ;; Load package into truck
  (:action load-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (at ?t ?p)
      (at ?pkg ?p)
    )
    :effect (and
      (in ?pkg ?t)
      (not (at ?pkg ?p))
    )
  )

  ;; Unload package from truck
  (:action unload-truck
    :parameters (?pkg - package ?t - truck ?p - place)
    :precondition (and
      (at ?t ?p)
      (in ?pkg ?t)
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?t))
    )
  )

  ;; Load package into airplane (only at airports)
  (:action load-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (at ?a ?p)
      (at ?pkg ?p)
      (is-airport ?p)
    )
    :effect (and
      (in ?pkg ?a)
      (not (at ?pkg ?p))
    )
  )

  ;; Unload package from airplane (only at airports)
  (:action unload-airplane
    :parameters (?pkg - package ?a - airplane ?p - place)
    :precondition (and
      (at ?a ?p)
      (in ?pkg ?a)
      (is-airport ?p)
    )
    :effect (and
      (at ?pkg ?p)
      (not (in ?pkg ?a))
    )
  )

  ;; Drive truck between two places within the same city
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

  ;; Fly airplane between two airports
  (:action fly-airplane
    :parameters (?a - airplane ?from - place ?to - place)
    :precondition (and
      (at ?a ?from)
      (is-airport ?from)
      (is-airport ?to)
    )
    :effect (and
      (at ?a ?to)
      (not (at ?a ?from))
    )
  )
)
