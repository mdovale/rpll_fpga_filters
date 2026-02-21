# rpll_fpga_filters

Standalone sandbox for digital decimation/downsampling filter development and evaluation.

This folder is intentionally scoped to filter work only. It is a place to prototype and verify decimation architectures without needing the full PLL design context.

## Scope

- Current baseline implementation: CIC decimator (`CIC_N2_GEN_TRUNC`).
- Exploration space: CIC, FIR, and hybrid/multi-stage decimation pipelines.
- Typical use case: staged decimation such as `f_in -> f1 -> f2 -> f3`, where each stage has different filtering goals and implementation costs.

## Repository layout

- `vhdl/CIC_N2_GEN_TRUNC.vhd`: baseline CIC decimator.
- `vhdl/ACC_GEN.vhd`: accumulator building block (sandbox-generic implementation).
- `vhdl/REG_GEN.vhd`: register helper.
- `vhdl/REG_GEN_EN.vhd`: register helper with enable.
- `vhdl/dsp_package.vhdl`: local package shim for sandbox builds.
- `tb/cic_n2_gen_trunc_tb.vhd`: starter testbench.
- `docs/INTERFACE_CONTRACT.md`: module boundary and required behavior.
- `docs/TEST_SPEC.md`: required verification matrix.
- `docs/HANDOFF_WORKFLOW.md`: integration and review flow.

## Recommended toolchain

- VHDL simulation:
  - `ghdl` for fast compile/sim iteration.
- Modeling and analysis:
  - Python 3.11+ with `numpy`, `scipy`, `matplotlib` (or equivalent) for reference modeling and frequency-response analysis.
- Version control:
  - `git` with small, focused commits and documented design tradeoffs.
- Optional synthesis/PPA checks:
  - Vivado when resource/timing impact must be measured on target FPGA.

## Quick start

From `rpll_fpga_cic/`:

```bash
ghdl -a --std=08 -fsynopsys \
  vhdl/dsp_package.vhdl \
  vhdl/REG_GEN.vhd \
  vhdl/REG_GEN_EN.vhd \
  vhdl/ACC_GEN.vhd \
  vhdl/CIC_N2_GEN_TRUNC.vhd \
  tb/cic_n2_gen_trunc_tb.vhd

ghdl -e --std=08 -fsynopsys cic_n2_gen_trunc_tb
ghdl -r --std=08 -fsynopsys cic_n2_gen_trunc_tb --stop-time=20us
```

## Engineering workflow (recommended)

1. Define requirements
- Input rate, target output rate(s), passband, stopband, ripple, attenuation, latency, and allowable resource usage.

2. Build candidate architecture set
- Single-stage CIC or FIR.
- Cascaded CIC or FIR stages (`f_in -> f1 -> f2 -> f3`).
- CIC + FIR compensation.

3. Model first, then code
- Use floating-point and fixed-point reference models.
- Estimate droop, alias rejection, noise transfer, and quantization sensitivity before RTL changes.

4. Plan fixed-point formats
- Track bit growth per stage.
- Choose truncation/rounding/saturation rules explicitly.
- Document scaling and headroom assumptions.

5. Implement RTL incrementally
- Keep interfaces stable unless change is explicitly approved.
- Prefer composable stages over monolithic blocks for cascaded chains.

6. Verify against spec
- Run required tests in `docs/TEST_SPEC.md`.
- Compare against reference model.
- Include corner-case stimuli (reset, max/min values, sign transitions, startup transients).

7. Compare candidates with evidence
- For each architecture, report: spectral performance, latency, complexity, and synthesis impact.
- Select the best tradeoff for the target operating point.

## Architecture notes

### CIC

- Strengths: multiplier-free, efficient at large integer-rate decimation.
- Weaknesses: passband droop and limited stopband selectivity near band edge.
- Common pattern: CIC for coarse decimation, then compensation FIR for passband flattening and sharper rejection.

### FIR decimator

- Strengths: linear phase option, precise control of ripple/attenuation.
- Weaknesses: higher multiplier/resource cost.
- Common pattern: use polyphase form for efficient multi-rate implementation.

## Downsampling primer: major pitfalls and error sources

- Aliasing due to insufficient pre-filtering:
  - Any energy above the post-decimation Nyquist folds into baseband irreversibly.

- CIC passband droop:
  - Passband attenuation increases with frequency; compensation is often required.

- Fixed-point overflow:
  - Integrator stages can grow quickly; missing headroom causes wraparound distortion.

- Quantization and rounding noise:
  - Truncation points and rounding method change noise floor and spur profile.

- Stage partitioning mistakes:
  - Poor split of decimation ratio across stages can waste resources or degrade rejection.

- Startup/transient behavior:
  - Decimators and cascades need settling time; early samples may be invalid.

## Success criteria for proposed designs

- Meets spectral requirements (ripple, attenuation, alias control).
- Meets throughput/latency constraints.
- Meets fixed-point robustness targets (no unintended overflow/instability).
- Maintains contract compliance (`docs/INTERFACE_CONTRACT.md`).
- Passes verification (`docs/TEST_SPEC.md`) with reproducible evidence.
