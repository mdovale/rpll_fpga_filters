# CIC Sandbox Test Specification

This document defines required verification for filter designs.

## Verification goals

- Preserve interface compatibility of `CIC_N2_GEN_TRUNC`.
- Preserve decimation/update semantics (`Qout` updates only on slow strobe).
- Preserve signed arithmetic behavior under realistic and corner-case stimuli.
- Ensure reset behavior is deterministic.

## Test matrix

1. Reset behavior
- Drive non-zero `Data`.
- Assert `Reset='1'`, then release.
- Expect internal/output state returns to zero after reset assertion.

2. Slow-strobe gating
- Run with periodic `Clock_Slow` pulses.
- Verify `Qout` is stable on cycles where `Clock_Slow='0'`.

3. DC input
- Apply constant positive and negative DC values.
- Verify expected monotonic settling and sign preservation after decimation.

4. Impulse response
- Single-sample impulse followed by zeros.
- Capture output sequence at `Clock_Slow` pulses for regression comparison.

5. Sinusoidal / narrowband input
- Apply sinusoid below decimated Nyquist.
- Verify no obvious instability and expected amplitude/frequency preservation trend.

6. Full-scale stress
- Alternate near full-scale positive/negative values.
- Check for deterministic wrap behavior (no unknown/invalid states).

7. Configuration sweep
- At least these parameter sets:
  - `in_bit=12, out_bit=56, out_rate=23`
  - `in_bit=26, out_bit=32, out_rate=23`
  - One reduced-rate sim-friendly set (e.g. `in_bit=12, out_bit=16, out_rate=4`)

## Acceptance criteria

- No interface changes without explicit approval.
- No `U/X/Z` at `Qout` after reset deassertion.
- Gating rule holds for all tests: `Clock_Slow='0' => Qout stable`.
- Baseline regression vectors remain within agreed tolerance (prefer bit-exact for deterministic tests).

## Deliverables per change

- Updated VHDL source.
- Test evidence (logs/wave snapshots).
- Short note documenting numerical impact and any changed assumptions.
