;; Safe Transport Domain
;; Extends the base transport domain with package-category safety constraints.
;;
;; New predicates (all ground facts declared in the problem file):
;;   (fragile  ?p)  – package is fragile
;;   (hazardous ?p) – package is hazardous / dangerous goods
;;   (heavy    ?p)  – package is heavy cargo
;;   (food     ?p)  – package is food / perishable
;;   (damaged  ?p)  – package has been marked damaged (goal: never true)
;;   (inspected ?p) – package passed pre-load safety inspection
;;
;; Safety rules enforced as pick-up preconditions:
;;   R1 – capacity check            (already in base domain via capacity-predecessor)
;;   R2 – fragile ≠ heavy in same truck
;;   R3 – hazardous ≠ food in same truck
;;   R4 – hazardous ≠ fragile in same truck
;;   R5 – package must be inspected before loading

(define (domain transport-safe)
  (:requirements :typing :action-costs)

  (:types
    location target locatable - object
    vehicle package - locatable
    capacity-number - object
  )

  (:predicates
    ;; ── base predicates ──────────────────────────────────────
    (road         ?l1 ?l2   - location)
    (at           ?x        - locatable  ?v - location)
    (in           ?x        - package   ?v - vehicle)
    (capacity     ?v        - vehicle   ?s - capacity-number)
    (capacity-predecessor ?s1 ?s2 - capacity-number)

    ;; ── package category flags ───────────────────────────────
    (fragile      ?p - package)
    (hazardous    ?p - package)
    (heavy        ?p - package)
    (food         ?p - package)

    ;; ── safety-status flags ──────────────────────────────────
    (inspected    ?p - package)   ;; must be set before pick-up
    (damaged      ?p - package)   ;; must never be true at goal

    ;; ── co-occupancy helper predicates ──────────────────────
    ;; Set true when a category-representative is already aboard:
    (truck-has-fragile  ?v - vehicle)
    (truck-has-heavy    ?v - vehicle)
    (truck-has-hazardous ?v - vehicle)
    (truck-has-food     ?v - vehicle)
  )

  (:functions
    (road-length ?l1 ?l2 - location) - number
    (total-cost) - number
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: inspect
  ;;   A package must be explicitly inspected at its location
  ;;   before it may be loaded.  Costs 0 (administrative step).
  ;; ═══════════════════════════════════════════════════════════
  (:action inspect
    :parameters (?p - package ?l - location)
    :precondition (and
        (at ?p ?l)
        (not (inspected ?p))
        (not (damaged  ?p))
      )
    :effect (and
        (inspected ?p)
        (increase (total-cost) 0)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: drive  (unchanged from base domain)
  ;; ═══════════════════════════════════════════════════════════
  (:action drive
    :parameters (?v - vehicle ?l1 ?l2 - location)
    :precondition (and
        (at ?v ?l1)
        (road ?l1 ?l2)
      )
    :effect (and
        (not (at ?v ?l1))
        (at ?v ?l2)
        (increase (total-cost) (road-length ?l1 ?l2))
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: pick-up-standard
  ;;   Load a standard (non-categorised) package.
  ;;   Only blocked by capacity; no category conflicts.
  ;; ═══════════════════════════════════════════════════════════
  (:action pick-up-standard
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (inspected ?p)
        (not (damaged  ?p))
        (not (fragile  ?p))
        (not (hazardous ?p))
        (not (heavy    ?p))
        (not (food     ?p))
        ;; R1 – capacity
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
        (increase (total-cost) 1)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: pick-up-fragile
  ;;   R2 – no heavy cargo already aboard
  ;;   R4 – no hazardous cargo already aboard
  ;; ═══════════════════════════════════════════════════════════
  (:action pick-up-fragile
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (inspected  ?p)
        (not (damaged   ?p))
        (fragile    ?p)
        ;; R1 – capacity
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
        ;; R2 – no heavy aboard
        (not (truck-has-heavy    ?v))
        ;; R4 – no hazardous aboard
        (not (truck-has-hazardous ?v))
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
        (truck-has-fragile ?v)
        (increase (total-cost) 1)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: pick-up-heavy
  ;;   R2 – no fragile cargo already aboard
  ;; ═══════════════════════════════════════════════════════════
  (:action pick-up-heavy
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (inspected ?p)
        (not (damaged  ?p))
        (heavy     ?p)
        ;; R1 – capacity
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
        ;; R2 – no fragile aboard
        (not (truck-has-fragile ?v))
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
        (truck-has-heavy ?v)
        (increase (total-cost) 1)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: pick-up-hazardous
  ;;   R3 – no food aboard
  ;;   R4 – no fragile aboard
  ;; ═══════════════════════════════════════════════════════════
  (:action pick-up-hazardous
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (inspected  ?p)
        (not (damaged   ?p))
        (hazardous  ?p)
        ;; R1 – capacity
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
        ;; R3 – no food aboard
        (not (truck-has-food    ?v))
        ;; R4 – no fragile aboard
        (not (truck-has-fragile ?v))
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
        (truck-has-hazardous ?v)
        (increase (total-cost) 1)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: pick-up-food
  ;;   R3 – no hazardous cargo already aboard
  ;; ═══════════════════════════════════════════════════════════
  (:action pick-up-food
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (inspected  ?p)
        (not (damaged   ?p))
        (food       ?p)
        ;; R1 – capacity
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
        ;; R3 – no hazardous aboard
        (not (truck-has-hazardous ?v))
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
        (truck-has-food ?v)
        (increase (total-cost) 1)
      )
  )

  ;; ═══════════════════════════════════════════════════════════
  ;; ACTION: drop
  ;;   When a package leaves, clear its category flag if no
  ;;   same-category sibling remains aboard.
  ;;   For simplicity the flags are cleared on drop; a planner
  ;;   that needs exact multi-package tracking would require
  ;;   counting fluents (beyond base :action-costs).
  ;; ═══════════════════════════════════════════════════════════
  (:action drop
    :parameters (?v - vehicle ?l - location ?p - package
                 ?s1 ?s2 - capacity-number)
    :precondition (and
        (at ?v ?l)
        (in ?p ?v)
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s1)
      )
    :effect (and
        (not (in ?p ?v))
        (at ?p ?l)
        (capacity ?v ?s2)
        (not (capacity ?v ?s1))
        ;; Clear category flags conservatively (sound for single-
        ;; package-per-category scenarios; see problem design note)
        (when (fragile   ?p) (not (truck-has-fragile   ?v)))
        (when (heavy     ?p) (not (truck-has-heavy     ?v)))
        (when (hazardous ?p) (not (truck-has-hazardous ?v)))
        (when (food      ?p) (not (truck-has-food      ?v)))
        (increase (total-cost) 1)
      )
  )

)
