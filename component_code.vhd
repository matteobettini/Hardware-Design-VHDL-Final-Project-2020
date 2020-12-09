----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2019 11:19:39 AM
-- Design Name: 
-- Module Name: progetto_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity project_reti_logiche is
    port(
            i_clk       :in std_logic;
            i_start     :in std_logic;
            i_rst     :in std_logic;
            i_data      :in std_logic_vector(7 downto 0);
            o_address   :out std_logic_vector(15 downto 0);
            o_done      :out std_logic;
            o_en        :out std_logic;
            o_we        :out std_logic;
            o_data      :out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;



architecture Behavioral of project_reti_logiche is

component datapath is
    port(
            i_clk       :in std_logic;
            i_rst       :in std_logic;
            i_data      :in std_logic_vector(7 downto 0);
            o_data      :out std_logic_vector(7 downto 0);
            o_address   :out std_logic_vector(15 downto 0);
            r1_load     :in std_logic;
            r2_load     :in std_logic;
            r3_load     :in std_logic;
            r3_sel      :in std_logic;
            d_sel       :in std_logic;
            addr_sel    :in std_logic_vector(1 downto 0);
            o_end       :out std_logic;
            o_wz_is7    :out std_logic
    
    );

end component;

signal r1_load : std_logic;
signal r2_load : std_logic;
signal r3_load : std_logic;
signal r3_sel : std_logic;
signal d_sel : std_logic;
signal addr_sel : std_logic_vector(1 downto 0);
signal o_end : std_logic;
signal o_wz_is7 : std_logic;

type S is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9);
signal cur_state, next_state : S;

begin

    DATAPATH0: datapath port map(
         i_clk, 
         i_rst, 
         i_data,
         o_data, 
         o_address, 
         r1_load, 
         r2_load,  
         r3_load, 
         r3_sel, 
         d_sel, 
         addr_sel, 
         o_end,
         o_wz_is7
     );
 
    process(i_clk, i_rst)
         begin
             if(i_rst = '1') then
                 cur_state <= S0;
             elsif i_clk'event and i_clk = '1' then
                 cur_state <= next_state;
             end if;
    end process;
     
    process(cur_state, i_start, o_wz_is7, o_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if(i_start = '1') then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                if(o_end = '1') then
                    next_state <= S8;
                elsif(o_end = '0') then
                    next_state <= S6;
                end if;
            when S6 =>
                if(o_wz_is7 = '1') then
                    next_state <= S7;
                elsif(o_wz_is7 = '0') then
                    next_state <= S3;
                end if;
            when S7 =>
                next_state <= S9;
            when S8 =>
                next_state <= S9;
            when S9 =>
                if(i_start = '0') then
                    next_state <= S0;
                end if;
        end case;
    end process;
    
    process(cur_state)
    begin
        r1_load <= '0';
        r2_load <= '0';
        r3_load <= '0';
         
        r3_sel <= '0';
        d_sel <= '0';
        addr_sel <= "00";
               
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        
        case cur_state is
            when S0 =>
            when S1 =>
                o_en <= '1';
                addr_sel <= "01";  
                r3_sel <= '0';
                r3_load <= '1';
            when S2 =>
                r1_load <= '1';
            when S3 =>
                addr_sel <= "00";
                o_en <= '1';
            when S4 =>
                r2_load <= '1';
            when S5 =>
            when S6 =>
                r3_load <= '1';
                r3_sel <= '1';
            when S7 =>
                d_sel <= '0';
                o_en <= '1';
                o_we <= '1';
                addr_sel <= "10";
            when S8 =>
                d_sel <= '1';
                o_en <= '1';
                o_we <= '1';
                addr_sel <= "10";    
            when S9 =>
                o_done <= '1';       
        end case;   
    end process;

        
end Behavioral;




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is

    port(
            i_clk       :in std_logic;
            i_rst       :in std_logic;
            i_data      :in std_logic_vector(7 downto 0);
            o_data      :out std_logic_vector(7 downto 0);
            o_address   :out std_logic_vector(15 downto 0);
            r1_load     :in std_logic;
            r2_load     :in std_logic;
            r3_load     :in std_logic;
            r3_sel      :in std_logic;
            d_sel       :in std_logic;
            addr_sel    :in std_logic_vector(1 downto 0);
            o_end       :out std_logic;
            o_wz_is7    :out std_logic
    
    );

end datapath;

architecture Behavioral of datapath is

-- OUTPUT DEI REGISTRI
signal o_reg1: std_logic_vector(7 downto 0);
signal o_reg2: std_logic_vector(7 downto 0);
signal o_reg3: std_logic_vector(15 downto 0);

-- OUTPUT SOMMATORI E SOTTRATTORI
signal sum: std_logic_vector(15 downto 0);
signal diff: std_logic_vector(7 downto 0);

-- OUTPUT MULTIPLEXER
signal mux_reg3: std_logic_vector(15 downto 0);

-- OUTPUT MULTIPLEXER (NUMERO MIN BIT => ONE HOT)
signal mux_onehot: std_logic_vector(3 downto 0);

begin

-- MULTIPLEXER
                
with r3_sel select
    mux_reg3 <= "0000000000000000" when '0',
                 sum     when '1',
                "XXXXXXXXXXXXXXXX" when others;
                
with addr_sel select
    o_address <= o_reg3            when "00",
                "0000000000001000" when "01",
                "0000000000001001" when "10",
                "XXXXXXXXXXXXXXXX" when others;
with d_sel select
    o_data <= o_reg1                                            when '0',
              ('1' & o_reg3(2 downto 0) & mux_onehot)           when '1',
              "XXXXXXXX"                                        when others;
                  
-- SOMMATORI

diff <= std_logic_vector(signed(o_reg1) - signed(o_reg2));

sum <= (o_reg3 + "0000000000000001");

-- REGISTRI

-- reg1
process(i_clk,i_rst)
begin
    if(i_rst = '1') then 
        o_reg1 <= "00000000";
    elsif i_clk'event and (i_clk = '1') then
        if(r1_load = '1') then
            o_reg1 <= i_data(7 downto 0);
        end if;
    end if;      
end process;

-- reg2
process(i_clk,i_rst)
begin
    if(i_rst = '1') then 
        o_reg2 <= "00000000";
    elsif i_clk'event and (i_clk = '1') then
        if(r2_load = '1') then
            o_reg2 <= i_data(7 downto 0);
        end if;
    end if;      
end process;

-- reg3
process(i_clk,i_rst)
begin
    if(i_rst = '1') then 
        o_reg3 <= "0000000000000000";
    elsif i_clk'event and (i_clk = '1') then
        if(r3_load = '1') then
            o_reg3 <= mux_reg3;
        end if;
    end if;      
end process;

-- MULTIPLEXER NUMERO MIN BIT => ONE HOT

with diff(1 downto 0) select
    mux_onehot <= "0001" when "00",
                  "0010" when "01",
                  "0100" when "10",
                  "1000" when "11",
                  "XXXX" when others;
 
-- SEGNALI VARI
                
o_end <= '1' when (signed(diff) >= "00000000" and signed(diff) <= "00000011") else '0';

o_wz_is7  <= '1' when (o_reg3(2 downto 0) = "111") else '0';


end Behavioral;
