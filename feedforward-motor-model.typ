Given (for all proofs below)

$V = I R + E_("mf")$ by Ohm's Law with back EMF for a DC motor

$E_("mf") = omega kappa_e$ by the Back EMF equation of a motor

$tau = I kappa_t$ by the Motor torque equation

$tau = J alpha + B omega + tau_("load") "sign"(omega)$ by the Rotational equation of motion

The value of $omega$ and $alpha$ (Only for the proof directly below this)

Find a function $V_"ff"$, voltage, for a feedforward controller

$V_"ff" := V$ for this proof only for notational ease of use

$omega := omega_"ref"$ for this proof only for notational ease of use

$alpha := alpha_"ref"$ for this proof only for notational ease of use

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

$V = K_a alpha + K_v omega + K_s "sign"(omega)$ by substitution

$V_"ff" = K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref")$ by substitution

Define a function $V_"ff"$ by $V_"ff" (omega_"ref", alpha_"ref") = K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref")$

$qed$

Given (Only for the proof directly below this)

The value of $omega$

Find the maximum $alpha$ angular acceleration at some angular velocity $omega$

$V = I R + E_("mf")$, $E_("mf") = omega kappa_e$, $tau = I kappa_t$, $tau = J alpha + B omega + tau_("load") "sign"(omega)$, and the value of $omega$ because they are given

Note: The VEX motor controller has current limits so we must also account for those.

Define $I_("min")$ and $I_("max")$ as the current limits and define $I_("clamp")$ as the clamped value of I

Define $V_("max")$ as the maximum voltage and set it to $V$ when finding the max acceleration

Define $alpha_("max")$ as the maximum acceleration and set it to $alpha$ when finding the max acceleration

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

$alpha_("max") = (I_("clamp") kappa_t - B omega - tau_("load") "sign"(omega))/(J)$ by Substitution

Define a function $alpha$ by $alpha_("max") = (I_("clamp") kappa_t - B omega - tau_("load") "sign"(omega))/(J)$

$qed$

Find $omega(t)$ given that the motor is at a Constant Voltage

$alpha_("max") (omega) = (V_("max") - K_v omega - "sgn"(omega) K_s)/(K_a)$

Let $s = "sgn"(omega) in {1, -1}$

$(d omega) / (d t) = (V_("max") - K_v omega - s K_s)/(K_a)$

$(d omega) / (d t) + K_v/K_a omega = (V_("max") - s K_s)/K_a$

$I (t) = e^(integral K_v/K_a d t)$

$I (t) = e^(K_v/K_a t)$

$omega (t) = 1 / (I(t)) (integral_0^t I(tau) Q d tau + I(0) omega_0)$

$omega (t) = 1 / (e^(K_v/K_a t)) (integral_0^t e^(K_v/K_a tau) (V_("max") - s K_s) / K_a d tau + omega_0)$

$omega (t) = 1 / (e^(K_v/K_a t)) ((V_("max") - s K_s) / K_a K_a / K_v (e^(K_v/K_a t) - 1) + omega_0)$

$omega (t) = (V_("max") - s K_s) / K_v (e^(K_v/K_a t) - 1) / (e^(K_v/K_a t)) + omega_0 (e^(-K_v/K_a t))$

$omega (t) = (V_("max") - s K_s) / K_v + (omega_0 - (V_("max") - s K_s) / K_v) e^(-K_v/K_a t)$

$qed$

Define the plant (solve for the derivative of the state $x$ where $V$ is the desired input for the plant)

$x := omega$

$V := u$

$accent(x, dot) = accent(omega, dot)$ by the derivative

$accent(x, dot) = alpha$ by substitution

$therefore$ Find $accent(x, dot)$

$V_"ff" = K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref")$ because it is given

$V_"ff" := u$ as the voltage is the input

$alpha_"ref" := alpha$

$omega_"ref" := omega$

$u = K_a accent(x, dot) + K_v x + K_s "sign"(x)$ by substitution

$K_a accent(x, dot) = u - K_v x - K_s "sign"(x)$ by subtraction

$accent(x, dot) = (u - K_v x - K_s "sign"(x)) / K_a$ by division 

$qed$

Find a continuous state-space model in the form

$accent(x, dot) = bold(A) x + bold(B) u$

$y = bold(C) x + bold(D) u$

$V_"ff" = K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref")$ because it is given

$u := V_"fb"$

$V := V_"ff" + V_"fb"$

$V = V_"ff" + u$

$accent(x, dot) = (V - K_v x - K_s "sign"(x)) / K_a$ because it is given and $V$ is the desired input for the plant 

$e := x - x_"ref"$ for $x$ in the feedforward

$accent(e, dot) = accent(x, dot) - accent(x, dot)_"ref"$

$accent(e, dot) + accent(x, dot) = (V - K_v x - K_s "sign"(x)) / K_a + accent(e, dot)$ by addition

$accent(x, dot) - accent(x, dot)_"ref" + accent(x, dot) = (V"ff" + u - K_v omega - K_s "sign"(omega)) / K_a + accent(x, dot) - accent(x, dot)_"ref"$ by substitution

$accent(x, dot) - accent(x, dot)_"ref" + accent(x, dot) = (K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref") + u - K_v omega - K_s "sign"(omega)) / K_a + accent(x, dot) - accent(x, dot)_"ref"$ by substitution

$accent(x, dot) - accent(x, dot)_"ref" = (K_a alpha_"ref" + K_v omega_"ref" + K_s "sign"(omega_"ref") + u - K_v omega - K_s "sign"(omega)) / K_a - accent(x, dot)_"ref"$ by subtraction

$accent(e, dot) = (u - K_v (omega - omega_"ref") - K_s ("sign"(omega) - "sign"(omega_"ref")) + K_a alpha_"ref") / K_a - accent(omega, dot)_"ref"$ by substitution

$accent(e, dot) = (u - K_v (x - x_"ref") - K_s ("sign"(x) - "sign"(x_"ref")) + K_a alpha_"ref") / K_a - alpha_"ref"$ by substitution

Assume $"sign"(x) = "sign"(x_"ref") therefore "sign"(x) - "sign"(x_"ref") = 0$

$accent(e, dot) = (u - K_v e) / K_a$ by substitution

$accent(e, dot) = -K_v/K_a e + 1/K_a u$ by substitution

$x := e quad bold(A) := -K_v/K_a quad bold(B) := 1/K_a$

$y := e => bold(C) = 1$ and $bold(D) = 0$

$qed$

Given

$bold(A)_d = e^(bold(A)_c T)$

$bold(B)_d = integral^T_0 e^(bold(A_c) tau) d tau bold(B)_c$

$bold(C)_d = bold(C)_c$

$bold(D)_d = bold(D)_c$

$bold(A_c) = -K_v/K_a$

$bold(B_c) = 1/K_a$

$bold(C_c) = 1$

$bold(D_c) = 0$

Find a discrete state-space model in the form

$x_(k + 1) = bold(A) x_k + bold(B) u_k$

$y_k = bold(C) x_k + bold(D) u_k$

$bold(A)_d = e^(-K_v/K_a T)$ by substitution

$bold(B)_d = 1/K_a integral^T_0 e^(-K_v/K_a tau) d tau$

$bold(B)_d = -1/K_a K_a/K_v e^(-K_v/K_a tau)|^T_0$

$bold(B)_d = 1/K_v (1 - e^(-K_v/K_a T))$

$bold(C)_d = 1$ by substitution

$bold(D)_d = 0$ by substitution

$qed$

Given

$u^*_k = limits(arg min)_u_k limits(Sigma)^infinity_(k=0) (x^T_k bold(Q) x_k + bold(u)^T bold(R) bold(u)_k)$

subject to $x_(k+1) = bold(A) x_k + bold(B) bold(bold(u_k))$
Find $bold(K)$ based on $bold(Q)$ and $bold(R)$ in LQR

$bold(A)^T bold(S) bold(A) - bold(S) - bold(A)^T bold(S) bold(B)(bold(R) + bold(B)^T bold(S) bold(B))^(-1) bold(B)^T bold(S) bold(A) + Q = 0$ by the discrete algebraic Riccati equation

$bold(K) = (bold(R)+bold(B)^T bold(S) bold(B))^(-1) bold(B)^T bold(S) bold(A)$ by the discrete LQR result solved by the discrete algebraic Riccati equation

$bold(A) := e^(-K_v/K_a T) := a$

$bold(B) := 1/K_v (1 - e^(-K_v/K_a T)) := b$

$bold(C) = 1$ by substitution

$bold(D) = 0$ by substitution

$a^2 S - S - (a^2 b^2 S^2) / (R + b^2 S) + Q = 0$ by substitution

$a^2 S R + a^2 b^2 S^2 - S R - b^2 S^2 + Q R + Q b^2 S - a^2 b^2 S^2 = 0$ by multiplication

$a^2 S R - S R - b^2 S^2 + Q R + Q b^2 S = 0$ by substitution

$b^2 S^2 + (R(1 - a^2) - Q b^2) S - Q R = 0$ by substitution

$Q, R, b^2 gt 0 therefore 4 b^2 Q R gt 0 therefore sqrt((R(1 - a^2) - Q b^2)^2 + 4 b^2 Q R) gt |R(1 - a^2) - Q b^2| therefore$ the smaller root is negative which is not possible as $S gt 0$ so only the possitive root is valid

$S = (Q b^2 - R(1 - a^2) + sqrt((R(1 - a^2) - Q b^2)^2 + 4 b^2 Q R)) / (2 b^2)$ by the quadratic formula

$K = (a b S) / (R + b^2 S)$ by substitution
