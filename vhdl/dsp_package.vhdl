library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

package dsp_package is
  -- Keep DSP48 disabled in this sandbox to avoid vendor-IP dependencies.
  constant use_dsp48_accumulator : boolean := false;
end dsp_package;

package body dsp_package is
end dsp_package;
