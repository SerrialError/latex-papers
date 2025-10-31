#align(center)[
  #figure(
  image("asterisk-mecanum-diagram.png", width: 60%),
)
]

Given

$v_(x m) = v_(m 2) + v_(m 3) - v_(m 1) - v_(m 4)$, $v_(x o) = 0$

$v_(y m) = v_(m 1) + v_(m 2) + v_(m 3) + v_(m 4)$, $v_(y o) = v_(o 1) + v_(o 2)$

$v_(x) = v_(x m)$, $v_(y) = v_(y m) + v_(y o)$, $tan(theta) = v_(y)/v_(x)$

$ v_(x) = v_(m 2) + v_(m 3) - v_(m 1) - v_(m 4) $

$ v_(y) = v_(m 1) + v_(m 2) + v_(m 3) + v_(m 4) + v_(o 1) + v_(o 2) $

$ tan(theta) = v_(y) / v_(x) $

$v_(i m) = v_(m 2) + v_(m 4)$

$v_(l m) = v_(m 1) + v_(m 3)$

$omega_(m) = (L+W)/4(v_(i m) - v_(l m))$

$omega_(o) = W/2(v_(o 2)-v_(o 1))$

$omega = omega_(m) + omega_(o)$

$omega = (L+W)/4(v_(i m) - v_(l m)) + W/2(v_(o 2)-v_(o 1))$

$ omega = (L+W)/4(v_(m 2) + v_(m 4) - v_(m 1) - v_(m 3)) + W/2(v_(o 2)-v_(o 1)) $

$ (L+W)/4(v_(m 2) + v_(m 4) - v_(m 1) - v_(m 3)) = W/2(v_(o 2)-v_(o 1)) $

$T = (m, o)$, $N^m = (1, 2, 3, 4)$ and $N^o = (1, 2)$, 

$forall T forall N: T_n in [T_N_"min", T_N_"max"]$

$forall T forall N: T_n in [T_N_"min", T_N_"max"]$ and $T_N_"nom" = (T_N_"min" + T_N_"max") / 2$

Find $"motor"_("opt") = vec((t_n: n in N, t in T))$ st. $union.big^k_(i = 1) "motor"_("poss" i) = "motor"_("total" "poss")$ st. $k in NN$ st. $"motor"_("opt") in "motor"_("total" "poss")$ $forall N forall T: T_n in "motor"_"opt" in min_(t,n)(sum_(t in T) sum_(n in N)|t_n - t_(n "nom")|) = S_("abs diff")$

Proof

let $a subset.eq RR$ and $y subset.eq RR$ if $min(a) lt.not min(y)$ and $max(a) gt.eq max(y)$ and $min(y) in a$ then $min(a) = min(y)$

Therefore if $forall N forall T: d^T_n=|T_n-T_(n "nom")|$ and $min_(t,n)(sum_(t in T) sum_(n in N)d^t_n) = S_("abs diff")$ then if $u^T_n gt.eq |T_n-T_(n "nom")|$ then $min_(t,n)(sum_(t in T) sum_(n in N)u^t_n) = S_("abs diff")$

Let $forall N forall T: d^T_n gt.eq |T_n - T_(n "nom")|$

therefore $forall N forall T: d^T_n gt.eq T_n-T_(n "nom"); d^T_n gt.eq -(T_n-T_(n "nom")); d^T_n gt.eq 0$

therefore $min_(t,n)(sum_(t in T) sum_(n in N)d^t_n) = S_("abs diff")$

We can then use the simplex algorithm to solve this. To input into the simplex algorithm it says to maximize $c^T$ x subject to $A x lt.eq b$ and $x gt.eq k$ where

- $A$ is an $m times n$ matrix
- $b in RR^m$
- $c in RR^n$
- $x in RR^n$ are the decision variables
- $x$ is the decision variable vector
- $c$ is the objective-coefficient vector
- $c^T x$ is the objective function
- $A$ is the constraint matrix
- $b$ is the right-hand side vector
- $k in RR$

$x = vec(((t_n: n in N, t in T); (d^t_n: n in N, t in T)))$

$A = mat(
  1,         1,      1,        1,       1,    1  , 0, 0, 0, 0, 0, 0;
  1,         -1,     -1,       1,       0,    0  , 0, 0, 0, 0, 0, 0;
  -(L+W)/4, (L+W)/4, -(L+W)/4, (L+W)/4, -W/2, W/2, 0, 0, 0, 0, 0, 0;
  -1,        -1,      -1,      -1,      -1,   -1 , 0, 0, 0, 0, 0, 0;
  -1,        1,       1,       -1,      0,    0  , 0, 0, 0, 0, 0, 0;
  (L+W)/4, -(L+W)/4, (L+W)/4, -(L+W)/4, W/2, -W/2, 0, 0, 0, 0, 0, 0;
  -(L+W)/4, (L+W)/4, -(L+W)/4, (L+W)/4, -W/2, W/2, 0, 0, 0, 0, 0, 0;
  (L+W)/4, -(L+W)/4, (L+W)/4, -(L+W)/4, W/2, -W/2, 0, 0, 0, 0, 0, 0;
  I^6 | 0_(6 x 6);
  -I^6 | 0_(6 x 6);
  -1_(12 x 6);
  1_(12 x 6);
  -1_(12 x 1)

)$

$b = vec(v_y, v_x, omega, -v_y, -v_x, -omega, 0, 0, forall T forall N: T_N_"max", forall T forall N: T_N_"min", forall T forall N: T_N_"nom", forall T forall N: -T_N_"nom", 0)$

