-- CIC_N2_GEN_TRUNC.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity CIC_N2_GEN_TRUNC is
    generic (in_bit: positive :=12;
             out_bit: positive := 32;
             out_rate: positive:=12 );

    port(
            Reset      : in std_logic;
            Data       : in std_logic_vector ((in_bit-1) downto 0);
            Clock      : in std_logic;
            Clock_Slow : in std_logic;
            Clock_out  : out std_logic;
            Qout       : out std_logic_vector ((out_bit-1) downto 0)
        );

end CIC_N2_GEN_TRUNC;

architecture behavioral of CIC_N2_GEN_TRUNC is

    component REG_GEN
        generic (n: positive);
        port(
                Data : in std_logic_vector((n-1) downto 0);
        Aclr, Clock : in std_logic;
        Q : out std_logic_vector((n-1) downto 0)
    );
    end component;

    component REG_GEN_EN
        generic (n: positive);
        port(
                Data : in std_logic_vector((n-1) downto 0);
        Aclr, Clock : in std_logic;
        Enable :   in std_logic;
        Q : out std_logic_vector((n-1) downto 0)
    );
    end component;

    component ACC_GEN
        generic (n: positive);
        port(
                DataA       : in std_logic_vector((n-1) downto 0);
                Aclr        : in std_logic;
                Clock       : in std_logic;
                Sum         : out std_logic_vector((n-1) downto 0)
            );
    end component;

    signal Data_int           : std_logic_vector ((in_bit-1) downto 0);
    signal Data_int_sign      : std_logic_vector ((2*out_rate-1) downto 0);
    signal integrator_0_in    : std_logic_vector ((in_bit+2*out_rate-1) downto 0);

    signal integrator_0_out   : std_logic_vector ((in_bit+2*out_rate-1) downto 0);
    signal integrator_0_out_2 : std_logic_vector ((in_bit+2*out_rate-1) downto 0);
    signal integrator_1_out   : std_logic_vector ((in_bit+2*out_rate-1) downto 0);

    signal reg_diff_0_out     : std_logic_vector ((out_bit-1) downto 0);
    signal reg_diff_1_out     : std_logic_vector ((out_bit-1) downto 0);
    signal reg_diff_2_out     : std_logic_vector ((out_bit-1) downto 0);

    signal comb_0_out         : std_logic_vector ((out_bit-1) downto 0);
    signal comb_1_out         : std_logic_vector ((out_bit-1) downto 0);

    signal reg_cic_out        : std_logic_vector ((out_bit-1) downto 0);


begin

    reg_in : REG_GEN
    generic map (n => in_bit)
    port map (
                 Data  => Data,
                 Aclr  => Reset,
                 Clock => Clock,
                 Q     => Data_int
             );

    Data_int_sign <= (others => Data_int((in_bit-1)));
    integrator_0_in <= Data_int_sign & Data_int;

    integrator_0 : ACC_GEN
    generic map (n => in_bit+2*out_rate)
    port map(
                DataA => integrator_0_in,
                Aclr  => Reset,
                Clock => Clock,
                Sum => integrator_0_out
            );

    reg_int : REG_GEN
    generic map (n => in_bit+2*out_rate)
    port map (
                 Data  => integrator_0_out,
                 Aclr  => Reset,
                 Clock => Clock,
                 Q     => integrator_0_out_2
             );

    integrator_1 : ACC_GEN
    generic map (n => in_bit+2*out_rate)
    port map(
                DataA => integrator_0_out_2,
                Aclr  => Reset,
                Clock => Clock,
                Sum => integrator_1_out
            );



    reg_diff_0 : REG_GEN_EN
    generic map (n => out_bit)
    port map (
                 Data  => integrator_1_out(in_bit+2*out_rate-1 downto in_bit+2*out_rate-out_bit),
                 Aclr  => Reset,
                 Clock => Clock,
                 Enable=> Clock_Slow,
                 Q     => reg_diff_0_out
             );

    reg_diff_1 : REG_GEN_EN
    generic map (n => out_bit)
    port map (
                 Data  => reg_diff_0_out,
                 Aclr  => Reset,
                 Clock => Clock,
                 Enable=> Clock_Slow,
                 Q     => reg_diff_1_out
             );

    comb_0_out <= reg_diff_0_out - reg_diff_1_out;

    reg_diff_2 : REG_GEN_EN
    generic map (n => out_bit)
    port map (
                 Data  => comb_0_out,
                 Aclr  => Reset,
                 Clock => Clock,
                 Enable=> Clock_Slow,
                 Q     => reg_diff_2_out
             );

    comb_1_out <= comb_0_out - reg_diff_2_out;


    reg_out : REG_GEN_EN
    generic map (n => out_bit)
    port map (
                 Data  => comb_1_out,
                 Aclr  => Reset,
                 Clock => Clock,
                 Enable=> Clock_Slow,
                 Q     => reg_cic_out
             );

    Qout <= reg_cic_out;

    Clock_out <= Clock_Slow;

end behavioral;
