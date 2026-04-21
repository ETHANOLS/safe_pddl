;; Transport Problem
;; A transportation company delivers packages across a road network using trucks.

(define (problem transport-problem-1)
  (:domain transport)

  (:objects
    ;; Locations (cities in the network)
    city-a city-b city-c city-d city-e - location

    ;; Vehicles (trucks)
    truck-1 truck-2 - vehicle

    ;; Packages to be delivered
    pkg-1 pkg-2 pkg-3 pkg-4 - package

    ;; Capacity levels: cap-0 = empty slot count 0, cap-1 = 1, cap-2 = 2
    cap-0 cap-1 cap-2 - capacity-number
  )

  (:init
    ;; -------------------------------------------------------
    ;; Capacity predecessor chain: cap-0 < cap-1 < cap-2
    ;; capacity-predecessor ?s1 ?s2 means s2 = s1 + 1 free slot
    ;; -------------------------------------------------------
    (capacity-predecessor cap-0 cap-1)
    (capacity-predecessor cap-1 cap-2)

    ;; -------------------------------------------------------
    ;; Road network (bidirectional roads with travel costs)
    ;;
    ;;   city-a ---10--- city-b ---8--- city-c
    ;;     |                              |
    ;;    15                            12
    ;;     |                              |
    ;;   city-d ----------20---------- city-e
    ;;
    ;; -------------------------------------------------------
    (road city-a city-b) (= (road-length city-a city-b) 10)
    (road city-b city-a) (= (road-length city-b city-a) 10)

    (road city-b city-c) (= (road-length city-b city-c) 8)
    (road city-c city-b) (= (road-length city-c city-b) 8)

    (road city-a city-d) (= (road-length city-a city-d) 15)
    (road city-d city-a) (= (road-length city-d city-a) 15)

    (road city-c city-e) (= (road-length city-c city-e) 12)
    (road city-e city-c) (= (road-length city-e city-c) 12)

    (road city-d city-e) (= (road-length city-d city-e) 20)
    (road city-e city-d) (= (road-length city-e city-d) 20)

    ;; -------------------------------------------------------
    ;; Truck starting locations
    ;; -------------------------------------------------------
    (at truck-1 city-a)
    (at truck-2 city-c)

    ;; -------------------------------------------------------
    ;; Truck capacities
    ;; truck-1 can carry 2 packages; truck-2 can carry 1 package
    ;; -------------------------------------------------------
    (capacity truck-1 cap-2)
    (capacity truck-2 cap-1)

    ;; -------------------------------------------------------
    ;; Package initial locations
    ;; -------------------------------------------------------
    (at pkg-1 city-a)
    (at pkg-2 city-b)
    (at pkg-3 city-c)
    (at pkg-4 city-d)

    ;; -------------------------------------------------------
    ;; Total cost starts at zero
    ;; -------------------------------------------------------
    (= (total-cost) 0)
  )

  (:goal
    (and
      ;; pkg-1: city-a  -->  city-e
      (at pkg-1 city-e)
      ;; pkg-2: city-b  -->  city-d
      (at pkg-2 city-d)
      ;; pkg-3: city-c  -->  city-a
      (at pkg-3 city-a)
      ;; pkg-4: city-d  -->  city-b
      (at pkg-4 city-b)
    )
  )

  ;; Minimise total travel + load/unload cost
  (:metric minimize (total-cost))
)
