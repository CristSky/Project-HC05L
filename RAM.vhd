----------------------------------------------------------------------------------
-- Laboratório de Arquitetura de Computadores
-- Prof. Dr. Fábio Dacêncio Pereira
--
-- Projeto Final P.O.
--
-- César Torralvo Alves	RA - 533122
-- Cristiano Vicente		RA - 443913
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.Numeric_STD.ALL;
use work.func.ALL;


entity RAM is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           rw : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (7 downto 0);
           addr : in  STD_LOGIC_VECTOR (7 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0));
end RAM;

architecture Behavioral of RAM is
-- constants das instruções estão no pacote func

-- Declaração da matriz da Memória RAM de 8x8 (255 -> 2^8)
type ram_type is array (0 to 255) of STD_LOGIC_VECTOR (7 downto 0);
signal ram : ram_type := (others => "00000000");

begin
	process(clk,rst)
	begin
		if rst='1' then
			ram(0)	<= PRINT;
			ram(1)	<= "11001000";
			ram(2)	<= SW_A;
			ram(3)	<= STR_A;
			ram(4)	<= "11111111"; -- 255
			ram(5)	<= LDI_A;
			ram(6)	<= "00000000";
			ram(7)	<= LIMPA;
			ram(8)	<= SW_A;
			ram(9)	<= STR_A;
			ram(10)	<= "00001110"; --14
			ram(11)	<= INC_A;
			ram(12)	<= SW_A;
			ram(13)	<= ADD_A;
			--ram(14)	<= "00000000";
			ram(15)	<= DEC_A;
			ram(16)	<= JZ;
			ram(17)	<= "00010100"; --20
			ram(18)	<= JMP;
			ram(19)	<= "00001111"; --15
			ram(20)	<= PRINT;
			ram(21)	<= "11001110"; --206
			ram(22)	<= SW_A;
			ram(23)	<= LDD_X; --255
			ram(24)	<= "11111111";
			ram(25)	<= CPASS;
			ram(26)	<= "00010110"; --22
			ram(27)	<= PRINT;
			ram(28)	<= "11010100"; --212
			ram(29)	<= JMP;
			ram(30)	<= "00000000";
			
			ram(200)	<= X"53";--S
			ram(201)	<= X"65";--e 
			ram(202)	<= X"6E";--n
			ram(203)	<= X"68";--h
			ram(204)	<= X"61";--a
			ram(205)	<= X"1F";-- fim str
			ram(206)	<= X"4C";--L
			ram(207)	<= X"6F";--o 
			ram(208)	<= X"67";--g
			ram(209)	<= X"69";--i
			ram(210)	<= X"6E";--n
			ram(211)	<= X"1F";-- fim str
			ram(212)	<= X"4F";--O
			ram(213)	<= X"6B";--k
			ram(214)	<= X"20";--
			ram(215)	<= X"20";--
			ram(216)	<= X"20";--
			ram(217)	<= X"1F";-- fim str
		elsif rising_edge(clk) then
			if rw='1' then --escrita
				ram (to_integer(unsigned(addr))) <= din;
			end if;
		end if;
	end process;

dout <= ram (to_integer(unsigned(addr)));

end Behavioral;

