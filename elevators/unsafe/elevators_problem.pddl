(define (problem elevators-24floor)
  (:domain elevators-sequencedstrips)

  ;; ---------------------------------------------------------------
  ;; OBJECTS
  ;; ---------------------------------------------------------------
  (:objects

    ;; --- Elevators ---
    ;; 3 fast elevators (capacity 6), travel across the whole building
    fast0 fast1 fast2 - fast-elevator

    ;; 4 zones x 2 slow elevators each (capacity 4)
    ;; Zone A: floors  0-5   slow-a0, slow-a1
    ;; Zone B: floors  6-10  slow-b0, slow-b1
    ;; Zone C: floors 11-15  slow-c0, slow-c1
    ;; Zone D: floors 16-23  slow-d0, slow-d1
    slow-a0 slow-a1 - slow-elevator
    slow-b0 slow-b1 - slow-elevator
    slow-c0 slow-c1 - slow-elevator
    slow-d0 slow-d1 - slow-elevator

    ;; --- Floors (counts 0-23) ---
    f0  f1  f2  f3  f4  f5
    f6  f7  f8  f9  f10
    f11 f12 f13 f14 f15
    f16 f17 f18 f19 f20 f21 f22 f23 - count

    ;; --- Passenger counts (0-6, matching max capacity of fast elevators) ---
    n0 n1 n2 n3 n4 n5 n6 - count

    ;; --- Passengers ---
    ;; p0: zone A -> zone D  (floor 2  -> floor 19)  needs 3 transfers
    ;; p1: zone B -> zone C  (floor 8  -> floor 13)  needs 2 transfers
    ;; p2: zone A -> zone B  (floor 3  -> floor 9 )  needs 2 transfers
    ;; p3: zone C -> zone A  (floor 12 -> floor 1 )  needs 3 transfers
    ;; p4: zone D -> zone B  (floor 20 -> floor 7 )  needs 3 transfers
    ;; p5: zone A -> zone C  (floor 4  -> floor 14)  needs 2 transfers
    p0 p1 p2 p3 p4 p5 - passenger
  )

  ;; ---------------------------------------------------------------
  ;; INIT
  ;; ---------------------------------------------------------------
  (:init

    ;; === Total cost starts at 0 ===
    (= (total-cost) 0)

    ;; ---------------------------------------------------------------
    ;; next/count chain  (n0 -> n1 -> ... -> n6)
    ;; ---------------------------------------------------------------
    (next n0 n1) (next n1 n2) (next n2 n3)
    (next n3 n4) (next n4 n5) (next n5 n6)

    ;; ---------------------------------------------------------------
    ;; above facts  (above ?higher ?lower  =>  ?higher is above ?lower)
    ;; ---------------------------------------------------------------
    (above f1  f0)  (above f2  f1)  (above f3  f2)  (above f4  f3)
    (above f5  f4)  (above f6  f5)  (above f7  f6)  (above f8  f7)
    (above f9  f8)  (above f10 f9)  (above f11 f10) (above f12 f11)
    (above f13 f12) (above f14 f13) (above f15 f14) (above f16 f15)
    (above f17 f16) (above f18 f17) (above f19 f18) (above f20 f19)
    (above f21 f20) (above f22 f21) (above f23 f22)
    ;; transitive above (needed by move actions for multi-floor moves)
    (above f2  f0)  (above f3  f1)  (above f3  f0)  (above f4  f2)
    (above f4  f1)  (above f4  f0)  (above f5  f3)  (above f5  f2)
    (above f5  f1)  (above f5  f0)
    (above f6  f4)  (above f6  f3)  (above f6  f2)  (above f6  f1)  (above f6  f0)
    (above f7  f5)  (above f7  f4)  (above f7  f3)  (above f7  f2)  (above f7  f1)  (above f7  f0)
    (above f8  f6)  (above f8  f5)  (above f8  f4)  (above f8  f3)  (above f8  f2)  (above f8  f1)  (above f8  f0)
    (above f9  f7)  (above f9  f6)  (above f9  f5)  (above f9  f4)  (above f9  f3)  (above f9  f2)  (above f9  f1)  (above f9  f0)
    (above f10 f8)  (above f10 f7)  (above f10 f6)  (above f10 f5)  (above f10 f4)  (above f10 f3)  (above f10 f2)  (above f10 f1)  (above f10 f0)
    (above f11 f9)  (above f11 f8)  (above f11 f7)  (above f11 f6)  (above f11 f5)  (above f11 f4)  (above f11 f3)  (above f11 f2)  (above f11 f1)  (above f11 f0)
    (above f12 f10) (above f12 f9)  (above f12 f8)  (above f12 f7)  (above f12 f6)  (above f12 f5)  (above f12 f4)  (above f12 f3)  (above f12 f2)  (above f12 f1)  (above f12 f0)
    (above f13 f11) (above f13 f10) (above f13 f9)  (above f13 f8)  (above f13 f7)  (above f13 f6)  (above f13 f5)  (above f13 f4)  (above f13 f3)  (above f13 f2)  (above f13 f1)  (above f13 f0)
    (above f14 f12) (above f14 f11) (above f14 f10) (above f14 f9)  (above f14 f8)  (above f14 f7)  (above f14 f6)  (above f14 f5)  (above f14 f4)  (above f14 f3)  (above f14 f2)  (above f14 f1)  (above f14 f0)
    (above f15 f13) (above f15 f12) (above f15 f11) (above f15 f10) (above f15 f9)  (above f15 f8)  (above f15 f7)  (above f15 f6)  (above f15 f5)  (above f15 f4)  (above f15 f3)  (above f15 f2)  (above f15 f1)  (above f15 f0)
    (above f16 f14) (above f16 f13) (above f16 f12) (above f16 f11) (above f16 f10) (above f16 f9)  (above f16 f8)  (above f16 f7)  (above f16 f6)  (above f16 f5)  (above f16 f4)  (above f16 f3)  (above f16 f2)  (above f16 f1)  (above f16 f0)
    (above f17 f15) (above f17 f14) (above f17 f13) (above f17 f12) (above f17 f11) (above f17 f10) (above f17 f9)  (above f17 f8)  (above f17 f7)  (above f17 f6)  (above f17 f5)  (above f17 f4)  (above f17 f3)  (above f17 f2)  (above f17 f1)  (above f17 f0)
    (above f18 f16) (above f18 f15) (above f18 f14) (above f18 f13) (above f18 f12) (above f18 f11) (above f18 f10) (above f18 f9)  (above f18 f8)  (above f18 f7)  (above f18 f6)  (above f18 f5)  (above f18 f4)  (above f18 f3)  (above f18 f2)  (above f18 f1)  (above f18 f0)
    (above f19 f17) (above f19 f16) (above f19 f15) (above f19 f14) (above f19 f13) (above f19 f12) (above f19 f11) (above f19 f10) (above f19 f9)  (above f19 f8)  (above f19 f7)  (above f19 f6)  (above f19 f5)  (above f19 f4)  (above f19 f3)  (above f19 f2)  (above f19 f1)  (above f19 f0)
    (above f20 f18) (above f20 f17) (above f20 f16) (above f20 f15) (above f20 f14) (above f20 f13) (above f20 f12) (above f20 f11) (above f20 f10) (above f20 f9)  (above f20 f8)  (above f20 f7)  (above f20 f6)  (above f20 f5)  (above f20 f4)  (above f20 f3)  (above f20 f2)  (above f20 f1)  (above f20 f0)
    (above f21 f19) (above f21 f18) (above f21 f17) (above f21 f16) (above f21 f15) (above f21 f14) (above f21 f13) (above f21 f12) (above f21 f11) (above f21 f10) (above f21 f9)  (above f21 f8)  (above f21 f7)  (above f21 f6)  (above f21 f5)  (above f21 f4)  (above f21 f3)  (above f21 f2)  (above f21 f1)  (above f21 f0)
    (above f22 f20) (above f22 f19) (above f22 f18) (above f22 f17) (above f22 f16) (above f22 f15) (above f22 f14) (above f22 f13) (above f22 f12) (above f22 f11) (above f22 f10) (above f22 f9)  (above f22 f8)  (above f22 f7)  (above f22 f6)  (above f22 f5)  (above f22 f4)  (above f22 f3)  (above f22 f2)  (above f22 f1)  (above f22 f0)
    (above f23 f21) (above f23 f20) (above f23 f19) (above f23 f18) (above f23 f17) (above f23 f16) (above f23 f15) (above f23 f14) (above f23 f13) (above f23 f12) (above f23 f11) (above f23 f10) (above f23 f9)  (above f23 f8)  (above f23 f7)  (above f23 f6)  (above f23 f5)  (above f23 f4)  (above f23 f3)  (above f23 f2)  (above f23 f1)  (above f23 f0)

    ;; ---------------------------------------------------------------
    ;; Transfer floors (served by fast elevators):  f0, f5, f10, f15, f20, f23
    ;; ---------------------------------------------------------------

    ;; --- fast0: starts at f0 ---
    (lift-at fast0 f0)
    (passengers fast0 n0)
    (can-hold fast0 n1) (can-hold fast0 n2) (can-hold fast0 n3)
    (can-hold fast0 n4) (can-hold fast0 n5) (can-hold fast0 n6)
    (reachable-floor fast0 f0)  (reachable-floor fast0 f5)
    (reachable-floor fast0 f10) (reachable-floor fast0 f15)
    (reachable-floor fast0 f20) (reachable-floor fast0 f23)

    ;; --- fast1: starts at f10 ---
    (lift-at fast1 f10)
    (passengers fast1 n0)
    (can-hold fast1 n1) (can-hold fast1 n2) (can-hold fast1 n3)
    (can-hold fast1 n4) (can-hold fast1 n5) (can-hold fast1 n6)
    (reachable-floor fast1 f0)  (reachable-floor fast1 f5)
    (reachable-floor fast1 f10) (reachable-floor fast1 f15)
    (reachable-floor fast1 f20) (reachable-floor fast1 f23)

    ;; --- fast2: starts at f20 ---
    (lift-at fast2 f20)
    (passengers fast2 n0)
    (can-hold fast2 n1) (can-hold fast2 n2) (can-hold fast2 n3)
    (can-hold fast2 n4) (can-hold fast2 n5) (can-hold fast2 n6)
    (reachable-floor fast2 f0)  (reachable-floor fast2 f5)
    (reachable-floor fast2 f10) (reachable-floor fast2 f15)
    (reachable-floor fast2 f20) (reachable-floor fast2 f23)

    ;; ---------------------------------------------------------------
    ;; Slow elevators — Zone A (floors 0-5, transfer at f0 and f5)
    ;; ---------------------------------------------------------------
    ;; slow-a0: starts at f1
    (lift-at slow-a0 f1)
    (passengers slow-a0 n0)
    (can-hold slow-a0 n1) (can-hold slow-a0 n2)
    (can-hold slow-a0 n3) (can-hold slow-a0 n4)
    (reachable-floor slow-a0 f0) (reachable-floor slow-a0 f1)
    (reachable-floor slow-a0 f2) (reachable-floor slow-a0 f3)
    (reachable-floor slow-a0 f4) (reachable-floor slow-a0 f5)

    ;; slow-a1: starts at f4
    (lift-at slow-a1 f4)
    (passengers slow-a1 n0)
    (can-hold slow-a1 n1) (can-hold slow-a1 n2)
    (can-hold slow-a1 n3) (can-hold slow-a1 n4)
    (reachable-floor slow-a1 f0) (reachable-floor slow-a1 f1)
    (reachable-floor slow-a1 f2) (reachable-floor slow-a1 f3)
    (reachable-floor slow-a1 f4) (reachable-floor slow-a1 f5)

    ;; ---------------------------------------------------------------
    ;; Slow elevators — Zone B (floors 6-10, transfer at f5 and f10)
    ;; ---------------------------------------------------------------
    ;; slow-b0: starts at f6
    (lift-at slow-b0 f6)
    (passengers slow-b0 n0)
    (can-hold slow-b0 n1) (can-hold slow-b0 n2)
    (can-hold slow-b0 n3) (can-hold slow-b0 n4)
    (reachable-floor slow-b0 f5)  (reachable-floor slow-b0 f6)
    (reachable-floor slow-b0 f7)  (reachable-floor slow-b0 f8)
    (reachable-floor slow-b0 f9)  (reachable-floor slow-b0 f10)

    ;; slow-b1: starts at f9
    (lift-at slow-b1 f9)
    (passengers slow-b1 n0)
    (can-hold slow-b1 n1) (can-hold slow-b1 n2)
    (can-hold slow-b1 n3) (can-hold slow-b1 n4)
    (reachable-floor slow-b1 f5)  (reachable-floor slow-b1 f6)
    (reachable-floor slow-b1 f7)  (reachable-floor slow-b1 f8)
    (reachable-floor slow-b1 f9)  (reachable-floor slow-b1 f10)

    ;; ---------------------------------------------------------------
    ;; Slow elevators — Zone C (floors 11-15, transfer at f10 and f15)
    ;; ---------------------------------------------------------------
    ;; slow-c0: starts at f11
    (lift-at slow-c0 f11)
    (passengers slow-c0 n0)
    (can-hold slow-c0 n1) (can-hold slow-c0 n2)
    (can-hold slow-c0 n3) (can-hold slow-c0 n4)
    (reachable-floor slow-c0 f10) (reachable-floor slow-c0 f11)
    (reachable-floor slow-c0 f12) (reachable-floor slow-c0 f13)
    (reachable-floor slow-c0 f14) (reachable-floor slow-c0 f15)

    ;; slow-c1: starts at f14
    (lift-at slow-c1 f14)
    (passengers slow-c1 n0)
    (can-hold slow-c1 n1) (can-hold slow-c1 n2)
    (can-hold slow-c1 n3) (can-hold slow-c1 n4)
    (reachable-floor slow-c1 f10) (reachable-floor slow-c1 f11)
    (reachable-floor slow-c1 f12) (reachable-floor slow-c1 f13)
    (reachable-floor slow-c1 f14) (reachable-floor slow-c1 f15)

    ;; ---------------------------------------------------------------
    ;; Slow elevators — Zone D (floors 16-23, transfer at f15 and f23)
    ;; ---------------------------------------------------------------
    ;; slow-d0: starts at f17
    (lift-at slow-d0 f17)
    (passengers slow-d0 n0)
    (can-hold slow-d0 n1) (can-hold slow-d0 n2)
    (can-hold slow-d0 n3) (can-hold slow-d0 n4)
    (reachable-floor slow-d0 f15) (reachable-floor slow-d0 f16)
    (reachable-floor slow-d0 f17) (reachable-floor slow-d0 f18)
    (reachable-floor slow-d0 f19) (reachable-floor slow-d0 f20)
    (reachable-floor slow-d0 f21) (reachable-floor slow-d0 f22)
    (reachable-floor slow-d0 f23)

    ;; slow-d1: starts at f21
    (lift-at slow-d1 f21)
    (passengers slow-d1 n0)
    (can-hold slow-d1 n1) (can-hold slow-d1 n2)
    (can-hold slow-d1 n3) (can-hold slow-d1 n4)
    (reachable-floor slow-d1 f15) (reachable-floor slow-d1 f16)
    (reachable-floor slow-d1 f17) (reachable-floor slow-d1 f18)
    (reachable-floor slow-d1 f19) (reachable-floor slow-d1 f20)
    (reachable-floor slow-d1 f21) (reachable-floor slow-d1 f22)
    (reachable-floor slow-d1 f23)

    ;; ---------------------------------------------------------------
    ;; Travel cost metric initialisations
    ;;   travel-slow: 1 unit per floor
    ;;   travel-fast: 1 unit per floor (fast elevators are faster in
    ;;                practice; to reflect this, fast cost < slow cost;
    ;;                here we use floor-distance for both and let the
    ;;                planner exploit fast elevators' wider reach)
    ;; ---------------------------------------------------------------
    ;; Slow costs (symmetric, stored for every ordered pair in zone spans)
    (= (travel-slow f0  f1)  1) (= (travel-slow f1  f0)  1)
    (= (travel-slow f0  f2)  2) (= (travel-slow f2  f0)  2)
    (= (travel-slow f0  f3)  3) (= (travel-slow f3  f0)  3)
    (= (travel-slow f0  f4)  4) (= (travel-slow f4  f0)  4)
    (= (travel-slow f0  f5)  5) (= (travel-slow f5  f0)  5)
    (= (travel-slow f1  f2)  1) (= (travel-slow f2  f1)  1)
    (= (travel-slow f1  f3)  2) (= (travel-slow f3  f1)  2)
    (= (travel-slow f1  f4)  3) (= (travel-slow f4  f1)  3)
    (= (travel-slow f1  f5)  4) (= (travel-slow f5  f1)  4)
    (= (travel-slow f2  f3)  1) (= (travel-slow f3  f2)  1)
    (= (travel-slow f2  f4)  2) (= (travel-slow f4  f2)  2)
    (= (travel-slow f2  f5)  3) (= (travel-slow f5  f2)  3)
    (= (travel-slow f3  f4)  1) (= (travel-slow f4  f3)  1)
    (= (travel-slow f3  f5)  2) (= (travel-slow f5  f3)  2)
    (= (travel-slow f4  f5)  1) (= (travel-slow f5  f4)  1)

    (= (travel-slow f5  f6)  1) (= (travel-slow f6  f5)  1)
    (= (travel-slow f5  f7)  2) (= (travel-slow f7  f5)  2)
    (= (travel-slow f5  f8)  3) (= (travel-slow f8  f5)  3)
    (= (travel-slow f5  f9)  4) (= (travel-slow f9  f5)  4)
    (= (travel-slow f5  f10) 5) (= (travel-slow f10 f5)  5)
    (= (travel-slow f6  f7)  1) (= (travel-slow f7  f6)  1)
    (= (travel-slow f6  f8)  2) (= (travel-slow f8  f6)  2)
    (= (travel-slow f6  f9)  3) (= (travel-slow f9  f6)  3)
    (= (travel-slow f6  f10) 4) (= (travel-slow f10 f6)  4)
    (= (travel-slow f7  f8)  1) (= (travel-slow f8  f7)  1)
    (= (travel-slow f7  f9)  2) (= (travel-slow f9  f7)  2)
    (= (travel-slow f7  f10) 3) (= (travel-slow f10 f7)  3)
    (= (travel-slow f8  f9)  1) (= (travel-slow f9  f8)  1)
    (= (travel-slow f8  f10) 2) (= (travel-slow f10 f8)  2)
    (= (travel-slow f9  f10) 1) (= (travel-slow f10 f9)  1)

    (= (travel-slow f10 f11) 1) (= (travel-slow f11 f10) 1)
    (= (travel-slow f10 f12) 2) (= (travel-slow f12 f10) 2)
    (= (travel-slow f10 f13) 3) (= (travel-slow f13 f10) 3)
    (= (travel-slow f10 f14) 4) (= (travel-slow f14 f10) 4)
    (= (travel-slow f10 f15) 5) (= (travel-slow f15 f10) 5)
    (= (travel-slow f11 f12) 1) (= (travel-slow f12 f11) 1)
    (= (travel-slow f11 f13) 2) (= (travel-slow f13 f11) 2)
    (= (travel-slow f11 f14) 3) (= (travel-slow f14 f11) 3)
    (= (travel-slow f11 f15) 4) (= (travel-slow f15 f11) 4)
    (= (travel-slow f12 f13) 1) (= (travel-slow f13 f12) 1)
    (= (travel-slow f12 f14) 2) (= (travel-slow f14 f12) 2)
    (= (travel-slow f12 f15) 3) (= (travel-slow f15 f12) 3)
    (= (travel-slow f13 f14) 1) (= (travel-slow f14 f13) 1)
    (= (travel-slow f13 f15) 2) (= (travel-slow f15 f13) 2)
    (= (travel-slow f14 f15) 1) (= (travel-slow f15 f14) 1)

    (= (travel-slow f15 f16) 1) (= (travel-slow f16 f15) 1)
    (= (travel-slow f15 f17) 2) (= (travel-slow f17 f15) 2)
    (= (travel-slow f15 f18) 3) (= (travel-slow f18 f15) 3)
    (= (travel-slow f15 f19) 4) (= (travel-slow f19 f15) 4)
    (= (travel-slow f15 f20) 5) (= (travel-slow f20 f15) 5)
    (= (travel-slow f15 f21) 6) (= (travel-slow f21 f15) 6)
    (= (travel-slow f15 f22) 7) (= (travel-slow f22 f15) 7)
    (= (travel-slow f15 f23) 8) (= (travel-slow f23 f15) 8)
    (= (travel-slow f16 f17) 1) (= (travel-slow f17 f16) 1)
    (= (travel-slow f16 f18) 2) (= (travel-slow f18 f16) 2)
    (= (travel-slow f16 f19) 3) (= (travel-slow f19 f16) 3)
    (= (travel-slow f16 f20) 4) (= (travel-slow f20 f16) 4)
    (= (travel-slow f16 f21) 5) (= (travel-slow f21 f16) 5)
    (= (travel-slow f16 f22) 6) (= (travel-slow f22 f16) 6)
    (= (travel-slow f16 f23) 7) (= (travel-slow f23 f16) 7)
    (= (travel-slow f17 f18) 1) (= (travel-slow f18 f17) 1)
    (= (travel-slow f17 f19) 2) (= (travel-slow f19 f17) 2)
    (= (travel-slow f17 f20) 3) (= (travel-slow f20 f17) 3)
    (= (travel-slow f17 f21) 4) (= (travel-slow f21 f17) 4)
    (= (travel-slow f17 f22) 5) (= (travel-slow f22 f17) 5)
    (= (travel-slow f17 f23) 6) (= (travel-slow f23 f17) 6)
    (= (travel-slow f18 f19) 1) (= (travel-slow f19 f18) 1)
    (= (travel-slow f18 f20) 2) (= (travel-slow f20 f18) 2)
    (= (travel-slow f18 f21) 3) (= (travel-slow f21 f18) 3)
    (= (travel-slow f18 f22) 4) (= (travel-slow f22 f18) 4)
    (= (travel-slow f18 f23) 5) (= (travel-slow f23 f18) 5)
    (= (travel-slow f19 f20) 1) (= (travel-slow f20 f19) 1)
    (= (travel-slow f19 f21) 2) (= (travel-slow f21 f19) 2)
    (= (travel-slow f19 f22) 3) (= (travel-slow f22 f19) 3)
    (= (travel-slow f19 f23) 4) (= (travel-slow f23 f19) 4)
    (= (travel-slow f20 f21) 1) (= (travel-slow f21 f20) 1)
    (= (travel-slow f20 f22) 2) (= (travel-slow f22 f20) 2)
    (= (travel-slow f20 f23) 3) (= (travel-slow f23 f20) 3)
    (= (travel-slow f21 f22) 1) (= (travel-slow f22 f21) 1)
    (= (travel-slow f21 f23) 2) (= (travel-slow f23 f21) 2)
    (= (travel-slow f22 f23) 1) (= (travel-slow f23 f22) 1)

    ;; Fast costs (between transfer floors; cost per floor is 1, same scale)
    (= (travel-fast f0  f5)  5) (= (travel-fast f5  f0)  5)
    (= (travel-fast f0  f10) 10) (= (travel-fast f10 f0)  10)
    (= (travel-fast f0  f15) 15) (= (travel-fast f15 f0)  15)
    (= (travel-fast f0  f20) 20) (= (travel-fast f20 f0)  20)
    (= (travel-fast f0  f23) 23) (= (travel-fast f23 f0)  23)
    (= (travel-fast f5  f10) 5)  (= (travel-fast f10 f5)  5)
    (= (travel-fast f5  f15) 10) (= (travel-fast f15 f5)  10)
    (= (travel-fast f5  f20) 15) (= (travel-fast f20 f5)  15)
    (= (travel-fast f5  f23) 18) (= (travel-fast f23 f5)  18)
    (= (travel-fast f10 f15) 5)  (= (travel-fast f15 f10) 5)
    (= (travel-fast f10 f20) 10) (= (travel-fast f20 f10) 10)
    (= (travel-fast f10 f23) 13) (= (travel-fast f23 f10) 13)
    (= (travel-fast f15 f20) 5)  (= (travel-fast f20 f15) 5)
    (= (travel-fast f15 f23) 8)  (= (travel-fast f23 f15) 8)
    (= (travel-fast f20 f23) 3)  (= (travel-fast f23 f20) 3)

    ;; ---------------------------------------------------------------
    ;; Passenger initial positions
    ;;   p0: f2  (Zone A)
    ;;   p1: f8  (Zone B)
    ;;   p2: f3  (Zone A)
    ;;   p3: f12 (Zone C)
    ;;   p4: f20 (Zone D transfer floor)
    ;;   p5: f4  (Zone A)
    ;; ---------------------------------------------------------------
    (passenger-at p0 f2)
    (passenger-at p1 f8)
    (passenger-at p2 f3)
    (passenger-at p3 f12)
    (passenger-at p4 f20)
    (passenger-at p5 f4)
  )

  ;; ---------------------------------------------------------------
  ;; GOAL  — every passenger reaches their destination floor
  ;;   p0: f2  -> f19  (Zone A -> Zone D)
  ;;   p1: f8  -> f13  (Zone B -> Zone C)
  ;;   p2: f3  -> f9   (Zone A -> Zone B)
  ;;   p3: f12 -> f1   (Zone C -> Zone A)
  ;;   p4: f20 -> f7   (Zone D -> Zone B)
  ;;   p5: f4  -> f14  (Zone A -> Zone C)
  ;; ---------------------------------------------------------------
  (:goal
    (and
      (passenger-at p0 f19)
      (passenger-at p1 f13)
      (passenger-at p2 f9)
      (passenger-at p3 f1)
      (passenger-at p4 f7)
      (passenger-at p5 f14)
    )
  )

  ;; ---------------------------------------------------------------
  ;; METRIC — minimise total travel cost
  ;; ---------------------------------------------------------------
  (:metric minimize (total-cost))
)
