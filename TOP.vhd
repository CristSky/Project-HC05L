----------------------------------------------------------------------------------
-- Laboratório de Arquitetura de Computadores
-- Prof. Dr. Fábio Dacêncio Pereira
--
-- Projeto Final P.O.
--
-- César Torralvo Alves
-- Cristiano Vicente
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity TOP is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  an : out STD_LOGIC_VECTOR (3 downto 0);
			  lcd_e : out std_logic;
			  lcd_rs : out std_logic;
			  lcd_rw : out std_logic;
			  lcd_db : out std_logic_vector(7 downto 4);
           led : out  STD_LOGIC_VECTOR (7 downto 0);
			  sw_e : in STD_LOGIC;
			  sw : in  STD_LOGIC_VECTOR (5 downto 0));
			 
end TOP;

architecture Behavioral of TOP is

-- processador HC05 LITE
component HC05 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           din : out  STD_LOGIC_VECTOR (7 downto 0);
           rw : out  STD_LOGIC;
           addr : out  STD_LOGIC_VECTOR (7 downto 0);
           dout : in  STD_LOGIC_VECTOR (7 downto 0);
			  led : out  STD_LOGIC_VECTOR (7 downto 0);
			  line1 : out  STD_LOGIC_VECTOR (127 downto 0);  -- 16x8bit
			  line2 : out  STD_LOGIC_VECTOR (127 downto 0);
			  sw_e : in STD_LOGIC;
			  sw : in  STD_LOGIC_VECTOR (5 downto 0));
end component;

-- RAM 8x8 ------------------------------------------
component RAM is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           rw : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (7 downto 0);
           addr : in  STD_LOGIC_VECTOR (7 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

-- Display 16x2 -------------------------------------
component LCD16x2_ctrl is
    port (
    clk          : in  std_logic;
    --rst          : in  std_logic; Desativado, display sempre ativo.
    lcd_e        : out std_logic;
    lcd_rs       : out std_logic;
    lcd_rw       : out std_logic;
    lcd_db       : out std_logic_vector(7 downto 4);
    line1_buffer : in  std_logic_vector(127 downto 0);  -- 16x8bit
    line2_buffer : in  std_logic_vector(127 downto 0)); 
end component;
-----------------------------------------------------
signal srw : STD_LOGIC;
signal sdin : STD_LOGIC_VECTOR (7 downto 0);
signal saddr : STD_LOGIC_VECTOR (7 downto 0);
signal sdout : STD_LOGIC_VECTOR (7 downto 0);
signal sdisplay_buffer : STD_LOGIC_VECTOR (41 downto 0);
signal sline1 : STD_LOGIC_VECTOR (127 downto 0); -- liga HC05 ao Display
signal sline2 : STD_LOGIC_VECTOR (127 downto 0);
-----------------------------------------------------
signal cont : integer range 0 to 100000001;
signal sclk : STD_LOGIC;


begin
-- instância do HC05 LITE ---------------------------
proc_hc05 : HC05 port map (sclk,rst,sdin,srw,saddr,sdout,led,sline1,sline2,sw_e,sw);

-- instância da RAM ---------------------------------
mem_ram : RAM port map (clk,rst,srw,sdin,saddr,sdout);

-- instância do Display 16x2 ------------------------
Display_Out : LCD16x2_ctrl port map (clk,lcd_e,lcd_rs,lcd_rw,lcd_db,sline1,sline2);


-- divisor de clock ---------------------------------
process(clk,rst)
begin
	if rst='1' then
		cont <= 0;
	elsif rising_edge(clk) then
		cont <= cont + 1;
		if cont < 20000000 then
			sclk <= '0';
		else
			sclk <= '1';
		end if;
	end if;
	
	if cont = 50000000 then
		cont <= 0;
	end if;	
end process;
end Behavioral;

