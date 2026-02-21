-- Simple register with a asynchronous clear/reset (Aclr)

library ieee;
use ieee.std_logic_1164.all;


entity REG_GEN is
  generic (n : positive);
  port (Data  : in  std_logic_vector((n-1) downto 0);
        Aclr  : in  std_logic;
        Clock : in  std_logic;
        Q     : out std_logic_vector((n-1) downto 0) := (others => '0'));
end REG_GEN;

architecture behavior of REG_GEN is

begin

  process (Clock, Aclr)      
  begin
    if (Aclr = '1') then
      Q <= (others => '0');
    elsif (Aclr = '0') then
      if (Clock'event and Clock = '1') then
        Q <= Data;
      end if;
    end if;
  end process;

end architecture behavior;

