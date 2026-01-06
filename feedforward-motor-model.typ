Given (for all proofs below)

$V = I R + E_("mf")$ by Ohm's Law with back EMF for a DC motor

$E_("mf") = omega kappa_e$ by the Back EMF equation of a motor

$tau = I kappa_t$ by the Motor torque equation

$tau = J alpha + B omega + tau_("load") "sign"(omega)$ by the Rotational equation of motion

The value of $omega$ and $alpha$ (Only for the proof directly below this)

Find $V$ voltage

$V = I R + E_("mf")$, $E_("mf") = omega kappa_e$, $tau = I kappa_t$, $tau = J alpha + B omega + tau_("load") "sign"(omega)$, and the value of $omega$ and $alpha$ because they are given

$I kappa_t = J alpha + B omega + tau_("load") "sign"(omega)$ By substitution

$I = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t)$ By Division

$- I R = E_("mf") - V$ By Subtraction

$I = (E_("mf") - V)/(-R)$ By Division

$(E_("mf") - V)/(-R) = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t)$ By substitution

$(omega kappa_e - V)/(-R) = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t)$ By substitution

$omega kappa_e - V = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t) (-R)$ By multiplication

$- V = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t) (-R) - omega kappa_e$ By subtraction

$V = - ((J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t) (-R) - omega kappa_e)$ By division

$V = (J alpha + B omega + tau_("load") "sign"(omega))/(kappa_t) (R) + omega kappa_e$ By substitution

$V = (J alpha R) / kappa_t + (B omega R) / kappa_t + (tau_("load") "sign"(omega) R) / kappa_t + (omega kappa_e kappa_t) / kappa_t$ By substitution

$V = (J alpha R) / kappa_t + (B omega R + omega kappa_e kappa_t) / kappa_t + (tau_("load") "sign"(omega) R) / kappa_t$ By substitution

$V = (J alpha R) / kappa_t + (omega (B R + kappa_e kappa_t)) / kappa_t + (tau_("load") "sign"(omega) R) / kappa_t$ By substitution

Define $K_v$ by $K_v = (B R + kappa_e kappa_t) / kappa_t$

Define $K_a$ by $K_a = (J R) / kappa_t$

Define $K_s$ by $K_s = (tau_("load") R) / kappa_t$

$V = K_a alpha + K_v omega + K_s "sign"(omega)$

Define a function $V$ by $V(omega, alpha) = K_a alpha + K_v omega + K_s "sign"(omega)$

$qed$

Given (Only for the proof directly below this)

The value of $omega$

Find the maximum $alpha$ angular acceleration at some angular velocity $omega$

$V = I R + E_("mf")$, $E_("mf") = omega kappa_e$, $tau = I kappa_t$, $tau = J alpha + B omega + tau_("load") "sign"(omega)$, and the value of $omega$ because they are given

Note: The VEX motor controller has current limits so we must also account for those.

Define $I_("min")$ and $I_("max")$ as the current limits and define $I_("clamp")$ as the clamped value of I

Define $V_("max")$ as the maximum voltage and set it to $V$ when finding the max acceleration

Define $alpha_("max")$ as the maximum voltage and set it to $alpha$ when finding the max acceleration

$I_("clamp") = min(max(I, I_("min")), I_("max"))$ by the definition of clamping

$I_("clamp") = min(max(((E_("mf") - V_("max"))/(-R)), I_("min")), I_("max"))$ by substitution

$I_("clamp") = min(max(((omega kappa_e - V_("max"))/(-R)), I_("min")), I_("max"))$ by substitution

Define $V_("max") = V$ as the max voltage

$I_("clamp") = min(max(((omega kappa_e - V_("max"))/(-R)), I_("min")), I_("max"))$ by substitution

Restrict I by $I_("clamp") = I$ by the note

$- J alpha_("max") = B omega + tau_("load") "sign"(omega) - tau$ by Subtraction

$alpha_("max") = (B omega + tau_("load") "sign"(omega) - tau)/(-J)$ by Division

$alpha_("max") = (B omega + tau_("load") "sign"(omega) - I kappa_t)/(-J)$ by Substitution

$alpha_("max") = (B omega + tau_("load") "sign"(omega) - I_("clamp") kappa_t)/(-J)$ by Substitution

Define a function $alpha$ by $alpha_("max") (omega) = (B omega + tau_("load") "sign"(omega) - I_("clamp") kappa_t)/(-J)$

$qed$

Find $omega(t)$ given that the motor is constantly accelerating

$alpha_("max") (omega) = (V_("max") - K_v omega - "sgn"(omega) K_s)/(K_a)$

Let $s = "sgn"(omega) in {1, -1}$

$(d omega) / (d t) = (V_("max") - K_v omega - s K_s)/(K_a)$

$(d omega) / (d t) + K_v/K_a omega = (V_("max") - s K_s)/K_a$

$I (t) = e^(integral K_v/K_a d t)$

$I (t) = e^(K_v/K_a t)$

$omega (t) = 1 / (I(t)) (integral_0^t I(tau) Q d tau + I(0) omega_0)$

$omega (t) = 1 / (e^(K_v/K_a t)) (integral_0^t e^(K_v/K_a tau) (V_("max") - s K_s) / K_a d tau + omega_0)$

$omega (t) = 1 / (e^(K_v/K_a t)) ((V_("max") - s K_s) / K_a K_a / K_v (e^(K_v/K_a tau) - 1) + omega_0)$

$omega (t) = (V_("max") - s K_s) / K_v (e^(K_v/K_a tau) - 1) / (e^(K_v/K_a t)) + omega_0 (e^(-K_v/K_a t))$

$omega (t) = (V_("max") - s K_s) / K_v + (omega_0 - (V_("max") - s K_s) / K_v) e^(-K_v/K_a t)$

$qed$

Find a continuous state-space model in the form

$accent(x, dot) = bold(A) x + bold(B) u$

$y = bold(C) x + bold(D) u$

$v = K_a alpha + K_v omega + K_s "sign"(omega)$ because it is given

let $u = v$ and $x = vec(omega, "sign"(omega))$

$alpha = accent(omega, dot)$ by the definition of acceleration

$accent(x, dot) mat(1, 0) = accent(omega, dot)$ by the derivative

$alpha = accent(x, dot) mat(1, 0)$ by substitution

$"sign"(omega) = x mat(0, 1)$

$u = K_a alpha + K_v omega + K_s "sign"(omega)$ by substitution

$K_a accent(x, dot) mat(1, 0) = u - K_v x mat(1, 0) - K_s x mat(0, 1)$ by subtraction

$K_a accent(x, dot) mat(1, 0) = mat(-K_v, -K_s) x + u$ by substitution

$accent(x, dot) mat(1, 0) = mat(-K_v/K_a, -K_s/K_a) x + 1/K_a u$ by division

$accent(x, dot) = vec(1, 0) mat(-K_v/K_a, -K_s/K_a) x + vec(1,0) 1/K_a u$ by multiplication

$accent(x, dot) = mat(-K_v/K_a, -K_s/K_a; 0, 0) x + vec(1/K_a,0) u$ by substitution

Let $bold(A) = mat(-K_v/K_a, -K_s/K_a; 0, 0)$ and $bold(B) = vec(1/K_a,0)$

Let $y = vec(omega)$

$y = x mat(1, 0)$ by substitution

Let $bold(C) = mat(1, 0)$ and $bold(D) = 0$

$qed$

Given

$bold(A)_d = e^(bold(A)_c T)$

$bold(B)_d = integral_0^T e^(bold(A_c) tau) d tau bold(B)_c$

$bold(C)_d = bold(C)_c$

$bold(D)_d = bold(D)_c$

$bold(A_c) = mat(-K_v/K_a, -K_s/K_a; 0, 0)$

$bold(B_c) = vec(1/K_a,0)$

$bold(C_c) = mat(1, 0)$

$bold(D_c) = 0$

Find a discrete state-space model in the form

$x_(k + 1) = bold(A) x_k + bold(B) u_k$

$y_k = bold(C) x_k + bold(D) u_k$

$bold(A)_d = e^(mat(-K_v/K_a, -K_s/K_a; 0, 0) T)$ by substitution

$bold(A)_d = e^mat(-T K_v/K_a, -T K_s/K_a; 0, 0)$ by substitution

Let $a = -T K_v/K_a$ and $b = -T K_s/K_a$

$bold(A)_d = e^mat(a, b; 0, 0)$ by substitution

$bold(A)_d = mat(e^a, b (e^a-e^0)/(a-0); 0, e^0)$ by the exponential of an upper-triangular matrix formula

$bold(A)_d = mat(e^(-T K_v/K_a), -T K_s/K_a (e^(-T K_v/K_a)-1)/(-T K_v/K_a); 0, 1)$ by substitution

$bold(A)_d = mat(e^(-T K_v/K_a), K_s (e^(-T K_v/K_a)-1)/K_v; 0, 1)$ by substitution

$bold(B)_d = integral_0^T mat(e^(-tau K_v/K_a), K_s (e^(-tau K_v/K_a)-1)/K_v; 0, 1) vec(1/K_a,0) d tau$ by substitution

$bold(B)_d = integral_0^T vec(e^(-tau K_v/K_a)/K_v,0) d tau$ by substitution

$bold(B)_d =  vec(1/K_a integral_0^T e^(-tau K_v/K_a) d tau,0)$ by substitution

Let $I_d = integral_0^T e^(-tau K_v/K_a) d tau$

$bold(B)_d =  vec(I_d/K_v, 0)$ by substitution

$I_d = e^(-0 K_v/K_a) - e^(-T K_v/K_a)$ by FTC

$I_d = 1 - e^(-T K_v/K_a)$ by substitution

$bold(B)_d =  vec((1 - e^(-T K_v/K_a))/K_v, 0)$ by substitution

$bold(C)_d = mat(1, 0)$ by substitution

$bold(D)_d = 0$ by substitution
