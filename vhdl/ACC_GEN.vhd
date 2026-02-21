-- Accumulates values in 1 clock cycle.
-- Sandbox version: generic implementation without vendor IP.

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ACC_GEN is

    generic (n: positive:=48);

    port(
            DataA       : in std_logic_vector((n-1) downto 0);
            Aclr        : in std_logic;
            Clock       : in std_logic;
            Sum         : out std_logic_vector((n-1) downto 0)
        );

end ACC_GEN;

architecture behavioral of ACC_GEN is

    component REG_GEN
        generic (n: positive);
        port(
                Data        : in std_logic_vector((n-1) downto 0);
                Aclr        : in std_logic;
                Clock       : in std_logic;
                Q           : out std_logic_vector((n-1) downto 0)) ;
    end component;

    signal acc_out     : std_logic_vector ((n-1) downto 0);
    signal acc_in      : std_logic_vector ((n-1) downto 0);

begin

    acc_in <= std_logic_vector(signed(acc_out) + signed(DataA));
    reg_out : REG_GEN
    generic map (n => n)
    port map (
                 Data  => acc_in,
                 Aclr  => Aclr,
                 Clock => Clock,
                 Q     => acc_out
             );
    Sum <= acc_out;

end behavioral;
