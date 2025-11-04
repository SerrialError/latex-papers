#align(center)[
  #figure(
  image("asterisk-mecanum-diagram.png", width: 60%),
)
]

Given

Note: These are the correct formulas for velocity. Incorrectly throughout the proof I used velocity instead of force. Everything in the proof should be replaced with velocity. However as in this case force and velocity are proportional it doesn't change anything

$ v_(x) = 1 / 4 (v_(m 1) + v_(m 4) - v_(m 2) - v_(m 3)) $

$ v_(y) = 1 / 6 (v_(m 1) + v_(m 2) + v_(m 3) + v_(m 4) + v_(o 1) + v_(o 2)) $

$ tan(theta) = v_(y) / v_(x) $

$ omega = (L+W) / 24 (v_(m 2) + v_(m 4) - v_(m 1) - v_(m 3)) + W / 12 (v_(o 2)-v_(o 1)) $

$ (L+W) / 24 (v_(m 2) + v_(m 4) - v_(m 1) - v_(m 3)) = W / 12 (v_(o 2)-v_(o 1)) $

The incorrect velocities

$v_(x m) = v_(m 1) + v_(m 4) - v_(m 2) - v_(m 3)$, $v_(x o) = 0$

$v_(y m) = v_(m 1) + v_(m 2) + v_(m 3) + v_(m 4)$, $v_(y o) = v_(o 1) + v_(o 2)$

$v_(x) = v_(x m)$, $v_(y) = v_(y m) + v_(y o)$, $tan(theta) = v_(y)/v_(x)$

$ v_(x) = v_(m 1) + v_(m 4) - v_(m 2) - v_(m 3) $

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

$v_r = sqrt(v_x^2 + v_y^2)$

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
  I^6 | 0_(6 times 6);
  -I^6 | 0_(6 times 6);
  -1_(12 times 6);
  1_(12 times 6);
  O^(6 times 6) | -1_(6 times 6)

)$

$b = vec(v_y, v_x, omega, -v_y, -v_x, -omega, 0, 0, forall T forall N: T_N_"max", forall T forall N: T_N_"min", forall T forall N: T_N_"nom", forall T forall N: -T_N_"nom", 0)$

$c = vec(0_(6 times 1) | -1_(6 times 1))$

$qed$

$v = A_(1:3) x = vec(v_x, v_y, omega)$

$v_(x y) = A_(1:2) x = vec(v_x, v_y)$

$F = {x in RR^6: x^("min") lt.eq x lt.eq x^("max"), A_3:x=omega_("des")}$

Given $omega_("des")$ and $theta_("des")$ st. $omega_("des")=omega$ and $theta_("des")=theta$

Find $max v_r(x) := ||v_(x y)||_2 = sqrt(v_x^2+v_y^2)$ st. $x in F$

Proof

For any vector $l in RR^2$

$||l||_2 = max_(u in RR^2, ||u||_2 = 1) u^T l$ by Cauchy-Schwarz, for all unit vectors $u$ we have $u^T l lt.eq ||u||_2 ||l||_2=||l||_2$. Equality is achieved by taking $u = l/(||l||_2)$ if ($l eq.not 0$). Hence the max over unit $u$ equals $||l||_2$.

$l = v_(x y) = A_(1:2) x$

$max_(x in F) ||A_(1:2) x||_2 = max_(x in F) max_(||u||=1) u^T (A_(1:2) x)$ by substitution

$max_(||u|| = 1) max_(x in F) u^T (A_(1:2) x) = max_(x in F) max_(||u||=1) u^T (A_(1:2) x)$ because both F and the unit circle $U = {u in RR^2 : ||u|| = 1}$ are compact and the function $f(u,t) := u^T (A_(1:2) x)$ is continuous on the compact set $U times F$ and the extreme value theorem guarantees a maximum of $f$ on the product set and both maximizations are finite and over compact sets

$ u^T (A_(1:2) x) = (A_(1:2)^T u)^T x = c(u)^T x $

where $c(u):= A_(1:2)^T u in RR^6$

$max_(x in F) max_(||u||=1) u^T (A_(1:2) x) = max_(||u||=1) max_(x in F) c(u)^T x$ by substitution

$u = vec(cos(theta_("des")), sin(theta_("des")))$

$c(u):=A^T_(1:2) u = cos(theta_("des")) A_(1:2)^T e_1 + sin(theta_("des")) A_(1:2)^T e_2$

$p:=max_(x in F) c^T x$

$max_(||u||=1) max_(x in F) c(u)^T x = max_(theta_("des") in [0, 2 pi)) p$

$x_("new") = x$

$A_("new") = A_(1:10)$

$b_("new") = b_(1:10)$

$c_("new") = vec(forall x: cos(theta_("des")) A_("new")_x + sin(theta_("des")) A_("new")_y)$

This then outputs the optimized vector $x^*_("new")$ we then plug in that vector into $v_x$ and $v_y$ to get $v_r$
