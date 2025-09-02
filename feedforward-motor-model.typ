Given

$V = I R + E_("mf")$ Kirchhoff’s Voltage Law (KVL) for a DC motor

$E_("mf") = omega kappa_e$ Back EMF equation of a motor

$tau = I kappa_t$ Motor torque equation

$tau = J alpha + B omega + tau_("load") "sign"(omega)$ Rotational equation of motion

Define the $w$ subnotation by the wheel and the $r$ subnotation of the robot minus the wheel of that variable.

Find V voltage at some initial angular velocity $omega$ and the wanted angular acceleration $alpha$

Note: I, J, $tau_("load") "sign"(omega)$, R, B, $omega$, $alpha$, $kappa_t$, and $kappa_e$ are given. So therefore we only need to find V as it is the only remaining variable.

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

Find the maximum $alpha$ angular acceleration at some angular velocity

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

Find V voltage of wheel $n$ at some initial linear velocity $v$ and the wanted linear acceleration $a$ 

$qed$

Find the maximum $alpha$ angular acceleration of wheel $n$ at some linear velocity $v$

$qed$
