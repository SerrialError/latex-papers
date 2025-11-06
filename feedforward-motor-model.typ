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

Find the maximum $alpha$ angular acceleration of wheel $n$ at some linear velocity $v$

$qed$
