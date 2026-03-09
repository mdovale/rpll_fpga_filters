library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity sinusoid_tb is
end sinusoid_tb;

architecture tb of sinusoid_tb is
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

  file infile : text open read_mode is "tb_in/sinusoid_input.dat";
  file outfile : text open write_mode is "tb/tb_out/sinusoid_output.dat";

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

    reset_proc : process
    begin
        wait for C_CLK_PER;
        reset <= '0';
    end process;

    clk_proc : process
    begin
        loop
            clk <= '0';
            wait for C_CLK_PER/2;
            clk <= '1';
            wait for C_CLK_PER/2;
        end loop;
    end process;

    slow_clk_proc : process
        
        variable i : integer := 0;

    begin
        loop
            wait until rising_edge(clk);

            if (i mod C_DECIM) = (C_DECIM - 1) then
                clk_slow <= '1';
                i := 0;
            else
                clk_slow <= '0';
                i := i + 1;
            end if;
        end loop;
    end process;

    stimulus : process

        variable IN_LINE    : line;  
        variable in_sample  : integer;
        variable i          : integer := 0;

    begin

        wait until reset <= '0';

        while not endfile(infile) loop --adding 8 for module clk cycles
            readline(infile, IN_LINE);
            read(IN_LINE, in_sample);
            
            wait until rising_edge(clk);
            data_in <= std_logic_vector(to_signed(in_sample, data_in'length));

        end loop;

    end process;

    out_capture : process
        
        variable OUT_LINE    : line;
        variable out_sample : std_logic_vector(C_OUT_BIT-1 downto 0);
    
    begin

        wait until reset <= '0';

        loop
            wait until rising_edge(clk_slow);
            write(OUT_LINE, qout, right, C_OUT_BIT);
            writeline(outfile, OUT_LINE);
        end loop;
    end process;

  end tb;