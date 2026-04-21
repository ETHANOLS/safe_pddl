;; Safe Transport Problem
;; Uses domain: transport-safe
;;
;; Network layout (bidirectional, cost on each edge):
;;
;;   city-a ---10--- city-b ---8---- city-c
;;     |                               |
;;    15                              12
;;     |                               |
;;   city-d ----------20------------ city-e
;;
;; Trucks:
;;   truck-1  starts city-a  capacity 2
;;   truck-2  starts city-c  capacity 2
;;
;; Packages & categories:
;;   pkg-std1   standard    city-a  → city-c
;;   pkg-frag1  fragile     city-b  → city-e
;;   pkg-haz1   hazardous   city-d  → city-b
;;   pkg-heavy1 heavy       city-a  → city-d
;;   pkg-food1  food        city-c  → city-a
;;
;; Key safety tensions in this scenario:
;;   • truck-1 starts with pkg-std1 (standard) AND pkg-heavy1 (heavy)
;;     → it cannot also pick up pkg-frag1 (fragile/heavy conflict R2)
;;   • pkg-haz1 must travel alone or with other non-food, non-fragile cargo (R3/R4)
;;   • pkg-food1 cannot share a truck with pkg-haz1 (R3)
;;   • All packages must be inspected before loading (R5)

(define (problem safe-transport-1)
  (:domain transport-safe)

  (:objects
    city-a city-b city-c city-d city-e - location

    truck-1 truck-2 - vehicle

    pkg-std1   - package   ;; standard
    pkg-frag1  - package   ;; fragile
    pkg-haz1   - package   ;; hazardous
    pkg-heavy1 - package   ;; heavy
    pkg-food1  - package   ;; food

    cap-0 cap-1 cap-2 - capacity-number
  )

  (:init
    ;; ── capacity predecessor chain ──────────────────────────
    (capacity-predecessor cap-0 cap-1)
    (capacity-predecessor cap-1 cap-2)

    ;; ── road network ────────────────────────────────────────
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

    ;; ── vehicle initial positions & capacities ───────────────
    (at truck-1 city-a)
    (capacity truck-1 cap-2)      ;; truck-1 holds up to 2 packages

    (at truck-2 city-c)
    (capacity truck-2 cap-2)      ;; truck-2 holds up to 2 packages

    ;; ── package initial positions ────────────────────────────
    (at pkg-std1   city-a)
    (at pkg-frag1  city-b)
    (at pkg-haz1   city-d)
    (at pkg-heavy1 city-a)
    (at pkg-food1  city-c)

    ;; ── package category flags ───────────────────────────────
    ;; (standard packages carry no flag – absence = standard)
    (fragile   pkg-frag1)
    (hazardous pkg-haz1)
    (heavy     pkg-heavy1)
    (food      pkg-food1)

    ;; ── safety status: no package starts as inspected ────────
    ;; (inspected ?p) must be derived by the inspect action.
    ;; (damaged ?p) is intentionally absent – no package is damaged at start.

    ;; ── truck category occupancy flags: all clear at start ───
    ;; (truck-has-fragile/heavy/hazardous/food ?v) all absent = clear

    ;; ── cost initialisation ──────────────────────────────────
    (= (total-cost) 0)
  )

  (:goal
    (and
      ;; ── delivery goals ──────────────────────────────────────
      (at pkg-std1   city-c)    ;; standard pkg: city-a → city-c
      (at pkg-frag1  city-e)    ;; fragile pkg:  city-b → city-e
      (at pkg-haz1   city-b)    ;; hazardous pkg: city-d → city-b
      (at pkg-heavy1 city-d)    ;; heavy pkg:    city-a → city-d
      (at pkg-food1  city-a)    ;; food pkg:     city-c → city-a

      ;; ── safety integrity goals ──────────────────────────────
      ;; No package may arrive damaged
      (not (damaged pkg-std1))
      (not (damaged pkg-frag1))
      (not (damaged pkg-haz1))
      (not (damaged pkg-heavy1))
      (not (damaged pkg-food1))
    )
  )

  (:metric minimize (total-cost))
)
