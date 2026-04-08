(define (domain logistics)
  (:requirements :strips :typing)

  (:types
    city
    location airport - place
    vehicle - object
    truck airplane - vehicle
    package
  )

  (:predicates
    ;; A location or airport belongs to a city
    (in-city ?loc - place ?city - city)

    ;; Where things are
    (at ?obj - object ?loc - place)
    (in ?pkg - package ?veh - vehicle)
  )

  ;; Load a package into a truck
  (:action load-truck
    :parameters (?pkg - package ?truck - truck ?loc - location)
    :precondition (and
      (at ?truck ?loc)
      (at ?pkg ?loc)
    )
    :effect (and
      (not (at ?pkg ?loc))
      (in ?pkg ?truck)
    )
  )

  ;; Unload a package from a truck
  (:action unload-truck
    :parameters (?pkg - package ?truck - truck ?loc - location)
    :precondition (and
      (at ?truck ?loc)
      (in ?pkg ?truck)
    )
    :effect (and
      (not (in ?pkg ?truck))
      (at ?pkg ?loc)
    )
  )

  ;; Load a package into an airplane
  (:action load-airplane
    :parameters (?pkg - package ?plane - airplane ?apt - airport)
    :precondition (and
      (at ?plane ?apt)
      (at ?pkg ?apt)
    )
    :effect (and
      (not (at ?pkg ?apt))
      (in ?pkg ?plane)
    )
  )

  ;; Unload a package from an airplane
  (:action unload-airplane
    :parameters (?pkg - package ?plane - airplane ?apt - airport)
    :precondition (and
      (at ?plane ?apt)
      (in ?pkg ?plane)
    )
    :effect (and
      (not (in ?pkg ?plane))
      (at ?pkg ?apt)
    )
  )

  ;; Drive a truck between two locations within the same city
  (:action drive-truck
    :parameters (?truck - truck ?from - location ?to - location ?city - city)
    :precondition (and
      (at ?truck ?from)
      (in-city ?from ?city)
      (in-city ?to ?city)
    )
    :effect (and
      (not (at ?truck ?from))
      (at ?truck ?to)
    )
  )

  ;; Drive a truck from a location to the city airport
  (:action drive-truck-to-airport
    :parameters (?truck - truck ?from - location ?to - airport ?city - city)
    :precondition (and
      (at ?truck ?from)
      (in-city ?from ?city)
      (in-city ?to ?city)
    )
    :effect (and
      (not (at ?truck ?from))
      (at ?truck ?to)
    )
  )

  ;; Drive a truck from the airport to a regular location
  (:action drive-truck-from-airport
    :parameters (?truck - truck ?from - airport ?to - location ?city - city)
    :precondition (and
      (at ?truck ?from)
      (in-city ?from ?city)
      (in-city ?to ?city)
    )
    :effect (and
      (not (at ?truck ?from))
      (at ?truck ?to)
    )
  )

  ;; Fly an airplane between two airports
  (:action fly-airplane
    :parameters (?plane - airplane ?from - airport ?to - airport)
    :precondition (and
      (at ?plane ?from)
    )
    :effect (and
      (not (at ?plane ?from))
      (at ?plane ?to)
    )
  )
)
