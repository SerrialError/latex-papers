#align(center)[
  #figure(
  image("asterisk-mecanum-diagram.png", width: 60%),
)
]

Given

$F_(r x m) = F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4)$, $F_(r x o) = 0$

$F_(r y m) = F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4)$, $F_(r y o) = F_(o 1) + F_(o 2)$

$theta F_(r m) = tan^-1(F_(r y m)/F_(r x m))$, $theta F_(r o) = 0$

$F_(r x) = F_(r x m)$, $F_(r y) = F_(r y m) + F_(r y o)$, $theta F_(r) = tan^(-1)(F_(r y)/F_(r x))$

$ F_(r x) = F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4) $

$ F_(r y) = F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) $

$ theta F_(r) = tan^(-1)((F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2))/(F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4))) $

$F_(r i m) = F_(m 2) + F_(m 4)$

$F_(l m) = F_(m 1) + F_(m 3)$

$tau_(r m) = (L+W)/4(F_(r i m) - F_(l m))$

$tau_(r o) = W/2(F_(o 2)-F_(o 1))$

$tau_r = tau_(r m) + tau_(r o)$

$tau_r = (L+W)/4(F_(r i m) - F_(l m)) + W/2(F_(o 2)-F_(o 1))$

$ tau_r = (L+W)/4(F_(m 2) + F_(m 4) - F_(m 1) - F_(m 3)) + W/2(F_(o 2)-F_(o 1)) $

Let $T = vec(m, o)$, $N_m = vec(1, 2, 3, 4)$ and $N_o = vec(1, 2)$.  
$forall t in T$ and $n in N_t$, we have

$ k^"min"_(t n) lt.eq F_(t n) lt.eq k^"max"_(t n) $

Now we want to make some way to input $theta F_(r)$, $tau_r$, and $forall t in T$ and $n in N_t$: $k^"min"_(t n)$ and $k^"max"_(t n)$ and then somehow get out $forall t in T$ and $n in N_t$: $F_(t n)$ that maximizes $F_(r x) + F_(r y)$

First let's find the "objective function". Substituting we get

$ F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4) + F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) $

Simplifying we then get

$ 2 F_(m 2) + 2 F_(m 3) + F_(o 1) + F_(o 2) $

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

First, let's put down what we know. We know the decision variable vector $x$ would be $vec(F_(m 1),F_(m 2),F_(m 3),F_(m 4),F_(o 1),F_(o 2))$.

Back from what we found before because of that we know the decision variable vector $c$ is $vec(0, 2, 2, 0, 1, 1)$.

So $c^T x = 2 F_(m 2) + 2 F_(m 3) + F_(o 1) + F_(o 2)$ (what we found earlier).

Now we are really close, all we have to worry about is $A$. So first we know a bunch of the inequalities:

$forall t in T$ and $n in N_t$

$k^"min"_(t n) lt.eq F_(t n) lt.eq k^"max"_(t n)$

we need to then put it in the form $A x lt.eq b$ so we get

$forall t in T$ and $n in N_t$

$F_(t n) lt.eq k^"max"_(t n)$, $-F_(t n) lt.eq -k^"min"_(t n)$

Ok but this isn't in the form with $x$, it is each of the forces separately. So since we only do one at a time the other forces would just be multiplied by 0. There would be 1 row for each force. This can be written as an identity matrix with the size of 6: $I_6$. This is done for both the mininum and maximum, with the minimum being negative: $-I_6$. Therefore we get the following inequalities:

$forall t in T$ and $n in N_t$

$ I_6 x lt.eq k^"max"_(t n) $

$ -I_6 x lt.eq -k^"min"_(t n) $

So we know some of the constraints. The next constraint is the angle of force contraint.  
Now we need to linearize $theta F_r$.

First we flip around the trig function to get

$tan(theta F_r)  = (F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2))/(F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4))$

Then simplifying we get

$ F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) - tan(theta F_r) (F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4)) = 0 $

we can then factorize to get

$ F_(m 1) (1 + tan(theta F_r)) + F_(m 2) (1 - tan(theta F_r)) + F_(m 3) (1 - tan(theta F_r)) + F_(m 4) (1 + tan(theta F_r)) + F_(o 1) + F_(o 2) = 0 $

We can then take the factors to the decision variables to get a vector

$ a_"ang" = vec(1 + tan(theta F_r), 1 - tan(theta F_r), 1 - tan(theta F_r), 1 + tan(theta F_r), 1, 1) $

Which we can convert into two inequalities

$ a^T_"ang" x lt.eq 0 $ $ -a^T_"ang" x lt.eq 0 $

Now onto the last and final constraint we have is the torque constraint which we can apply the same steps and factorize getting the new vector

$ a_tau = vec(-(L+W)/4, (L+W)/4, -(L+W)/4, (L+W)/4, -W/2, W/2) $

giving the following two inequalities

$ a^T_tau x lt.eq tau_r $ $ -a^T_tau x lt.eq tau_r $

This gives us the total matrix $ A = 
vec(
  I_6,
  -I_6,
  a^T_"ang",
  -a^T_"ang",
  a^T_tau,
  -a^T_tau
) $

and the vector

$ b = vec(k_max, -k_min, 0, 0, tau_r, tau_r) $

We can then put this into a simplex (or other algorithm) solver and it should output the correct answer!


= Mecanum force maximization

Let the decision vector be

$$
x := (F_m1, F_m2, F_m3, F_m4, F_o1, F_o2) \in R^6.
$$

Define the following row vectors (linear forms) acting on x:

$$
a_rx := (-1, 1, 1, -1, 0, 0),
\qquad
a_ry := (1, 1, 1, 1, 1, 1).
$$

$$
a_ang := (1 + tan(theta_F), 1 - tan(theta_F), 1 - tan(theta_F),
           1 + tan(theta_F), 1, 1)
$$

$$
a_tau := (-(L + W)/4, (L + W)/4, -(L + W)/4, (L + W)/4, -W/2, W/2)
$$

Using these linear forms we may write the following equalities:

$$
F_rx = a_rx  x,  F_ry = a_ry  x,
$$

$$
a_ang  x = F_ry - tan(theta_F)  F_rx,  tau = a_tau  x.
$$

Let k_min, k_max in R^6 denote elementwise box bounds:
$$
k_min <= x <= k_max.
$$

== Theorem

Maximizing the Euclidean resultant force

$$
norm((F_rx, F_ry)) = sqrt(F_rx^2 + F_ry^2)
$$

subject to the angle equality a_ang  x = 0, a torque condition, and box bounds
is equivalent to the convex second-order-cone program below.

=== SOCP formulation (exact-angle, exact-torque)

Maximize s over x in R^6 and s in R subject to the constraints

$$
sqrt( (a_rx  x)^2 + (a_ry  x)^2 ) <= s
$$

$$
a_ang  x = 0
$$

$$
a_tau  x = tau_r
$$

$$
k_min <= x <= k_max
$$

If the torque is intended as a bound rather than an equality, replace the equality by

$$
abs(a_tau  x) <= tau_r
$$

i.e. the two linear inequalities

$$
a_tau  x <= tau_r  and  -a_tau  x <= tau_r.
$$

== Proof

Step 1 (auxiliary scalar).
Introduce s in R. Since the square-root is monotone increasing on [0, +infty),
maximizing sqrt(F_rx^2 + F_ry^2) is equivalent to maximizing s subject to

$$
sqrt(F_rx^2 + F_ry^2) <= s.
$$

Step 2 (SOC cast).
The inequality above is the second-order-cone constraint

$$
sqrt( (F_rx)^2 + (F_ry)^2 ) <= s,
$$

or, using the linear maps,

$$
sqrt( (a_rx  x)^2 + (a_ry  x)^2 ) <= s.
$$

Step 3 (linear constraints).
The angle condition tan(theta_F) = F_ry / F_rx (when F_rx != 0) is algebraically equivalent to

$$
F_ry - tan(theta_F)  F_rx = 0,
$$

which is the linear equality a_ang  x = 0. The torque and box constraints are linear equalities/inequalities in x.

Step 4 (convexity and equivalence).
The objective s is linear. The SOC constraint and the linear equalities/inequalities are convex. The feasible set is convex, and the introduced scalar s enforces exact equivalence with maximizing the Euclidean norm. Hence the SOCP above is a correct exact convex reformulation.

End of proof.

== Remark (why the previous LP objective was incorrect)

If one sets the LP objective vector c = (0, 2, 2, 0, 1, 1)^T then

$$
c^T x = 2 F_m2 + 2 F_m3 + F_o1 + F_o2.
$$

One checks

$$
F_rx + F_ry
= (F_m2 + F_m3 - F_m1 - F_m4)
  + (F_m1 + F_m2 + F_m3 + F_m4 + F_o1 + F_o2)
= 2 F_m2 + 2 F_m3 + F_o1 + F_o2 = c^T x.
$$

However F_rx + F_ry is a linear functional and in general is not equal to sqrt(F_rx^2 + F_ry^2).
Thus maximizing c^T x (an LP) optimizes the sum F_rx + F_ry, not the Euclidean magnitude.
Use the SOCP above for the exact solution, or if you must remain with LPs use a polyhedral approximation.
