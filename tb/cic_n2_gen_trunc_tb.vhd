library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cic_n2_gen_trunc_tb is
end cic_n2_gen_trunc_tb;

architecture tb of cic_n2_gen_trunc_tb is
  constant C_IN_BIT   : positive := 12;
  constant C_OUT_BIT  : positive := 16;
  constant C_OUT_RATE : positive := 4;
  constant C_CLK_PER  : time := 10 ns;
  constant C_DECIM    : natural := 2**C_OUT_RATE;

  signal reset      : std_logic := '1';
  signal clk        : std_logic := '0';
  signal clk_slow   : std_logic := '0';
  signal clock_out  : std_logic;
  signal data_in    : std_logic_vector(C_IN_BIT-1 downto 0) := (others => '0');
  signal qout       : std_logic_vector(C_OUT_BIT-1 downto 0);
begin
  uut : entity work.CIC_N2_GEN_TRUNC
    generic map (
      in_bit   => C_IN_BIT,
      out_bit  => C_OUT_BIT,
      out_rate => C_OUT_RATE
    )
    port map (
      Reset      => reset,
      Data       => data_in,
      Clock      => clk,
      Clock_Slow => clk_slow,
      Clock_out  => clock_out,
      Qout       => qout
    );

  clk <= not clk after C_CLK_PER/2;

  stim : process
    variable i      : integer := 0;
    variable sample : signed(C_IN_BIT-1 downto 0);
  begin
    wait for 8*C_CLK_PER;
    reset <= '0';

    -- Run deterministic stimulus for quick smoke/regression testing.
    while i < 4096 loop
      wait until rising_edge(clk);

      if (i mod C_DECIM) = (C_DECIM - 1) then
        clk_slow <= '1';
      else
        clk_slow <= '0';
      end if;

      -- Triangle-like bounded input sequence.
      sample := to_signed((i mod 256) - 128, C_IN_BIT);
      data_in <= std_logic_vector(sample);
      i := i + 1;
    end loop;

    wait for 8*C_CLK_PER;
    assert false report "TB completed" severity failure;
  end process;

  -- Contract check: pass-through behavior of Clock_out.
  check_clock_out : process(clk)
  begin
    if rising_edge(clk) then
      assert clock_out = clk_slow
        report "Clock_out must match Clock_Slow"
        severity error;
    end if;
  end process;

  -- Contract check: output only updates on slow strobe.
  check_qout_gating : process(clk)
    variable last_qout : std_logic_vector(C_OUT_BIT-1 downto 0) := (others => '0');
    variable prev_enable : std_logic := '0';
  begin
    if rising_edge(clk) then
      if reset = '0' then
        if prev_enable = '0' then
          assert qout = last_qout
            report "Qout changed without Clock_Slow pulse"
            severity error;
        end if;
      end if;
      prev_enable := clk_slow;
      last_qout := qout;
    end if;
  end process;
end tb;
