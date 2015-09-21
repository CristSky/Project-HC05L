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
use IEEE.STD_LOGIC_1164.all;

package func is


function Hexcod(n: STD_LOGIC_VECTOR (3 downto 0)) return STD_LOGIC_VECTOR;


--Instruçoes----------------------------------------------------------------------
constant INC_A	: STD_LOGIC_VECTOR (7 downto 0):="01001100"; -- 4C (INC) -> A
constant DEC_A	: STD_LOGIC_VECTOR (7 downto 0):="01001101"; -- 4D (DEC) -> A
constant ADD_A	: STD_LOGIC_VECTOR (7 downto 0):="10101011"; -- AB (ADD) -> A
constant AND_A	: STD_LOGIC_VECTOR (7 downto 0):="10100100"; -- A4 (AND) -> A
constant OR_A	: STD_LOGIC_VECTOR (7 downto 0):="10101000"; -- A8 (OR) -> A
constant SUB_A	: STD_LOGIC_VECTOR (7 downto 0):="10101100"; -- AC (SUB) -> A
constant LDI_A	: STD_LOGIC_VECTOR (7 downto 0):="10100110"; -- A6 (Load Imediato) -> A
constant LDI_X	: STD_LOGIC_VECTOR (7 downto 0):="10101110"; -- AE (Load Imediato) -> X
constant LDD_A	: STD_LOGIC_VECTOR (7 downto 0):="10110110"; -- B6 (Load Direto) -> B
constant LDD_X	: STD_LOGIC_VECTOR (7 downto 0):="10110000"; -- B0 (Load Direto) -> B
constant STR_A	: STD_LOGIC_VECTOR (7 downto 0):="10110111"; -- B7 (STORE) -> B
constant JMP	: STD_LOGIC_VECTOR (7 downto 0):="10111000"; -- B8 (JUMP) -> B
constant JZ		: STD_LOGIC_VECTOR (7 downto 0):="10111001"; -- B9 (JUMP se 0) -> B
constant JE		: STD_LOGIC_VECTOR (7 downto 0):="10111010"; -- BA (JUMP se igual) -> B
constant SW_A	: STD_LOGIC_VECTOR (7 downto 0):="11000001"; -- C1 (Load Switch) -> A
constant PRINT	: STD_LOGIC_VECTOR (7 downto 0):="11110000"; -- F0 (Imprime String da memória)
constant LIMPA	: STD_LOGIC_VECTOR (7 downto 0):="11110001"; -- F1 (Limpa mensagem)
constant CPASS	: STD_LOGIC_VECTOR (7 downto 0):="11110010"; -- F2 (Compara Senha)


end func;

package body func is

 
function Hexcod(n: STD_LOGIC_VECTOR(3 downto 0))
return STD_LOGIC_VECTOR is
	variable tmp : STD_LOGIC_VECTOR(7 downto 0);
	begin
		case n(3 downto 0) is -- mostra valor do Reg A no seg e display pos 1 linha 1
			when "0000" => tmp := X"30"; -- 0
			when "0001" =>	tmp := X"31"; -- 1
			when "0010" => tmp := X"32"; -- 2
			when "0011" =>	tmp := X"33"; -- 3
			when "0100" =>	tmp := X"34"; -- 4
			when "0101" =>	tmp := X"35"; -- 5
			when "0110" =>	tmp := X"36"; -- 6
			when "0111" =>	tmp := X"37"; -- 7
			when "1000" =>	tmp := X"38"; -- 8
			when "1001" =>	tmp := X"39"; -- 9
			when "1010" =>	tmp := X"41"; -- A
			when "1011" =>	tmp := X"42"; -- B
			when "1100" => tmp := X"43"; -- C
			when "1101" => tmp := X"44"; -- D
			when "1110" =>	tmp := X"45"; -- E
			when "1111" =>	tmp := X"46"; -- F
			when others =>	tmp := X"20"; -- espaço
		end case;
	return tmp;
end Hexcod;
 
 
end func;
