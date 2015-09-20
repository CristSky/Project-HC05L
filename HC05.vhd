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
use IEEE.STD_LOGIC_unsigned.ALL;
use work.func.ALL;


entity HC05 is
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
end HC05;

architecture Behavioral of HC05 is
-- constants das instruções estão no pacote func

-- maquina de estados finita ------------------------------------------------------
signal state : STD_LOGIC_VECTOR (2 downto 0) := "000";

--estados -------------------------------------------------------------------------
constant RESET1 : STD_LOGIC_VECTOR (2 downto 0):="000";
constant RESET2 : STD_LOGIC_VECTOR (2 downto 0):="001";
constant BUSCA : STD_LOGIC_VECTOR (2 downto 0):="010";
constant DECODE : STD_LOGIC_VECTOR (2 downto 0):="011";
constant EXECUTA : STD_LOGIC_VECTOR (2 downto 0):="100";

--Registradores--------------------------------------------------------------------
signal A: STD_LOGIC_VECTOR (7 downto 0);
signal X: STD_LOGIC_VECTOR (7 downto 0);
signal PC: STD_LOGIC_VECTOR (7 downto 0);

signal opcode : STD_LOGIC_VECTOR (7 downto 0);
signal fase : STD_LOGIC_VECTOR (1 downto 0); -- Fase de operaçao decode
signal regaux : STD_LOGIC_VECTOR (7 downto 0); -- Auxiliar do PC



signal fstr : STD_LOGIC_VECTOR (2 downto 0); -- Auxiliar do PC
--Display---------------------------------------------------------------------------
signal l1p1,l1p2,l1p3,l1p4,l1p5,l1p6,l1p7,l1p8,l1p9,l1p10,l1p11,l1p12,l1p13,l1p14,l1p15,l1p16,
		 l2p1,l2p2,l2p3,l2p4,l2p5,l2p6,l2p7,l2p8,l2p9,l2p10,l2p11,l2p12,l2p13,l2p14,l2p15,l2p16 : std_logic_vector(7 downto 0) := X"20";

signal display_msg : std_logic_vector(7 downto 0);

------------------------------------------------------------------------------------
signal blink : std_logic := '0';
------------------------------------------------------------------------------------

begin

addr <= PC; -- Barramento de Dados addr para comunicação com a RAM
				-- Sempre que PC for atualizado, o addr também será

led(6 downto 1) <= sw; -- Led para representar os switchs ligados


process(clk,rst)
	begin
		if rst='1' then -- RESET --
			state <= RESET1;
			A <= (others => '0');
			X <= (others => '0');
			PC <= (others => '0');
			opcode <= (others => '0');
			fase <= "00";
			led(0) <= '1';
			
			-- Display
			l1p1 <= X"20";
			l1p2 <= X"20";
			l1p3 <= X"20";
			l1p4 <= X"20";
			l1p5 <= X"20";
			l1p6 <= X"20";
			l1p7 <= X"20";
			l1p8 <= X"20";
			l1p9 <= X"20";
			l1p10 <= X"20";
			l1p11 <= X"20";
			l1p12 <= X"20";
			l1p13 <= X"20";
			l1p14 <= X"20";
			l1p15 <= X"20";
			l1p16 <= X"20";
			
			l2p1 <= X"3E"; -- >
			l2p2 <= X"20";
			l2p3 <= X"52"; -- R
			l2p4 <= X"45"; -- E
			l2p5 <= X"53"; -- S
			l2p6 <= X"45"; -- E
			l2p7 <= X"54"; -- T
			l2p8 <= X"20";
			l2p9 <= X"20";
			l2p10 <= X"20";
			l2p11 <= X"20";
			l2p12 <= X"20";
			l2p13 <= X"20";
			l2p14 <= X"20";
			l2p15 <= X"20";
			l2p16 <= X"20";
						
			
		elsif rising_edge(clk) then
			-- Maquina de Estados -----------------------------------------------------------
			case state is
				when RESET1 =>	
					PC <= (others=>'0');
					rw <= '0'; --modo leitura
					led(0) <= '0';
					fase <= "00";
					display_msg <= "10000" & RESET1;
					state <= RESET2;
											
				when RESET2 =>
					display_msg <= "10000" & RESET2;
					state <= BUSCA;
				
				when BUSCA =>
					opcode <= dout;
					state <= DECODE;			
				when DECODE =>
				--- Instruções ------------------------------------------------------------------
					display_msg <= opcode;
					case opcode is
						-- 4C (INC) -> A --------------------------------------
						when INC_A =>
							A <= A + 1;
							state <= EXECUTA;
						-- 4D (DEC) -> A --------------------------------------
						when DEC_A =>
							A <= A - 1;
							state <= EXECUTA;
						-- AB (ADD) -> A --------------------------------------
						when ADD_A =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								A <= A + DOUT; 
								state <= EXECUTA;
							end if;
						-- AC (SUB) -> A --------------------------------------
						when SUB_A =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								A <= A - DOUT; 
								state <= EXECUTA;
							end if;
						-- A4 (AND) -> A --------------------------------------
						when AND_A =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								A <= A and DOUT; 
								state <= EXECUTA;
							end if;
						-- A8 (OR) -> A ---------------------------------------
						when OR_A =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								A <= A or DOUT; 
								state <= EXECUTA;
							end if;
						-- A6 (Load Imediato) -> A ----------------------------
						when LDI_A =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								A <= dout;
								state <= EXECUTA;
							end if;
						-- AE (Load Imediato) -> X ----------------------------
						when LDI_X =>
							if fase="00" then --fase 0
								PC <= PC + 1;
								fase <= "01";
							else --fase 1
								fase <= "00";
								X <= dout;
								state <= EXECUTA;
							end if;
							
						-- B6 (Load Direto) -> B ------------------------------
						when LDD_A =>
							case fase is
								-- fase 0 ----------------
								when "00" =>
									PC <= PC + 1;
									regaux <= PC + 1;
									fase <= "01";
								-- fase 1 ----------------
								when "01" =>
									PC <= dout; -- PC recebe posiçao da memória
									fase <= "10";
								-- fase 2 ----------------
								when "10" =>
									fase <= "00";
									A <= dout;
									PC <= regaux;
									regaux <= (others => '0');
									state <= EXECUTA;
								when others => null;
							end case;
							
						-- B0 (Load Direto) -> X ------------------------------
						when LDD_X =>
							case fase is
								-- fase 0 ----------------
								when "00" =>
									PC <= PC + 1;
									regaux <= PC + 1;
									fase <= "01";
								-- fase 1 ----------------
								when "01" =>
									PC <= dout; -- PC recebe posiçao da memória
									fase <= "10";
								-- fase 2 ----------------
								when "10" =>
									fase <= "00";
									X <= dout;
									PC <= regaux;
									regaux <= (others => '0');
									state <= EXECUTA;
								when others => null;
							end case;
							
						-- B7 (STORE) -> B ------------------------------------
						when STR_A =>
							case fase is
								-- fase 0 ----------------
								when "00" =>
									PC <= PC + 1;
									regaux <= PC + 1;
									fase <= "01";
								-- fase 1 ----------------
								when "01" =>
									PC <= dout; -- PC recebe posiçao da memória
									din <= A;
									fase <= "10";
								-- fase 2 ----------------
								when "10" =>
									rw <= '1';
									fase <= "11";
								-- fase 3 ----------------
								when "11" =>
									rw <= '0';
									PC <= regaux;
									regaux <= (others => '0');
									state <= EXECUTA;
									fase <= "00";
								when others => null;
							end case;
						-- B8 (JUMP) -> B -------------------------------------
						when JMP =>
							if(fase = "00") then -- Fase 0
								PC <= PC + 1;
								fase <= "01";
							else -- Fase 1
								PC <= dout - 1;
								fase <= "00";
								state <= EXECUTA;
							end if;
						-- C1 (A = ENTRADA) -----------------------------------
						when SW_A =>
							if(fase = "00") then -- Fase 0
								l2p9 <=  Hexcod("00" & sw(5 downto 4));
								l2p10 <= Hexcod(sw(3 downto 0));
								if(sw_e = '1') then
									fase <= "01";
								end if;
							else -- Fase 1
								if(sw_e = '1') then
									blink <= not(blink);
									led(7) <= blink;
								else
									fase <= "00";
									led(7) <= '0';
									A <= "00" & sw;
									l2p9 <= x"20";
									l2p10 <= x"20";
									state <= EXECUTA;
								end if;
							end if;							
						-- B9 (JUMP se Zero) -> B -----------------------------
						when JZ =>
							if(fase = "00") then -- Fase 0
								PC <= PC + 1;
								fase <= "01";
							else -- Fase 1
								if A = "00000000" then
									PC <= dout - 1;
									fase <= "00";
									state <= EXECUTA;
								else
									fase <= "00";
									state <= EXECUTA;
								end if;
							end if;
							
						-- BA (JUMP se Igual) -> B -----------------------------
						when JE =>
							if(fase = "00") then -- Fase 0
								PC <= PC + 2;
								regaux <= PC + 1;
								fase <= "01";
							else -- Fase 1
								if A = regaux then
									PC <= dout - 1;
									fase <= "00";
									state <= EXECUTA;
								else
									fase <= "00";
									state <= EXECUTA;
								end if;
							end if;
							
						-- F2 (checa a senha) -> ------------------------------
						when CPASS =>
							if(fase = "00") then -- Fase 0
								PC <= PC + 1;
								--regaux <= PC + 1;
								fase <= "01";
							else -- Fase 1
								if A = X then
									X <= (others => '0');
									fase <= "00";
									state <= EXECUTA;
								else
									X <= (others => '0');
									PC <= dout - 1;
									fase <= "00";
									state <= EXECUTA;
								end if;
							end if;
						-- F0 (Imprime string da memória) ---------------------
						when PRINT =>
							case fase is
								-- fase 0 ----------------
								when "00" =>
									PC <= PC + 1;
									regaux <= PC + 1;
									fase <= "01";
								-- fase 1 ----------------
								when "01" =>
									PC <= dout; -- PC recebe posiçao da memória
									fase <= "10";
								-- fase 2 ----------------
								when "10" =>
									PC <= PC + 1;
									if dout = X"1F" then
										PC <= regaux;
										regaux <= (others => '0');
										fase <= "00";
										fstr <= "000";
										state <= EXECUTA;
									else
										case fstr is
											when "000" =>
												l1p9 <= dout;
												fstr <= "001";
											when "001" =>
												l1p10 <= dout;
												fstr <= "010";
											when "010" =>
												l1p11 <= dout;
												fstr <= "011";
											when "011" =>
												l1p12 <= dout;
												fstr <= "100";
											when "100" =>
												l1p13 <= dout;
												fstr <= "101";
											when "101" =>
												l1p14 <= dout;
												fstr <= "110";
											when "110" =>
												l1p15 <= dout;
												fstr <= "111";
											when "111" =>
												l1p16 <= dout;
											when others => fstr <= "000";
										end case;
									end if;
								when others => null;
							end case;
						
						
						when LIMPA =>
							l1p9 <= X"20";
							l1p10 <= X"20";
							l1p11 <= X"20";
							l1p12 <= X"20";
							l1p13 <= X"20";
							l1p14 <= X"20";
							l1p15 <= X"20";
							l1p16 <= X"20";
							state <= EXECUTA;
							
						when others => state <= RESET1;
					end case;
					
					 
				--- FIM Instruções --------------------------------------------------------------
				when EXECUTA =>
					PC <= PC + 1; --aponta para proxima instruçao
					state <= BUSCA;
					
				when others => null;
			end case;
			-- FIM Maquina de Estados -------------------------------------------------------
			
			
			l1p3 <= Hexcod(A(7 downto 4)); -- mostra valor do Reg A
			l1p4 <= Hexcod(A(3 downto 0)); -- mostra valor do Reg A
						
			l1p6 <= Hexcod(PC(7 downto 4)); -- mostra valor do PC
			l1p7 <= Hexcod(PC(3 downto 0)); -- mostra valor do PC
		
			-- Mensagens Display ----------------------------
			case display_msg is
				when "10000000" =>
					l1p1 <= X"20";
					l1p2 <= X"20";
					l1p3 <= X"20";
					l1p4 <= X"20";
					l1p5 <= X"20";
					l1p6 <= X"20";
					l1p7 <= X"20";
					l1p8 <= X"20";
					l1p9 <= X"20";
					l1p10 <= X"20";
					l1p11 <= X"20";
					l1p12 <= X"20";
					l1p13 <= X"20";
					l1p14 <= X"20";
					l1p15 <= X"20";
					l1p16 <= X"20";
					
					l2p1 <= X"52"; -- R
					l2p2 <= X"65"; -- e
					l2p3 <= X"73"; -- s
					l2p4 <= X"74"; -- t
					l2p5 <= X"61"; -- a
					l2p6 <= X"72"; -- r
					l2p7 <= X"74"; -- t
					l2p8 <= X"20"; 
					l2p9 <= X"20";
					l2p10 <= X"20";
					l2p11 <= X"20";
					l2p12 <= X"20";
					l2p13 <= X"20";
					l2p14 <= X"20";
					l2p15 <= X"20";
					l2p16 <= X"20";
					
				when "10000001" =>
					l1p1 <= X"41"; -- A
					l1p2 <= X"3A"; -- :
					
					l2p12 <= X"48"; -- H
					l2p13 <= X"43"; -- C
					l2p14 <= X"30"; -- 0
					l2p15 <= X"35"; -- 5
					l2p16 <= X"4c"; -- L
				
				when INC_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"49"; -- I
					l2p4 <= X"4E"; -- N
					l2p5 <= X"43"; -- C
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
				
				when DEC_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"44"; -- D
					l2p4 <= X"45"; -- E
					l2p5 <= X"43"; -- C
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
					
				when ADD_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"41"; -- A
					l2p4 <= X"44"; -- D
					l2p5 <= X"44"; -- D
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
					
				when AND_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"41"; -- A
					l2p4 <= X"4E"; -- N
					l2p5 <= X"44"; -- D
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
					
				when OR_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4F"; -- O
					l2p4 <= X"52"; -- R
					l2p5 <= X"5F"; -- _
					l2p6 <= X"41"; -- A
					l2p7 <= X"20";
					l2p8 <= X"20";
				
				when SUB_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"53"; -- S
					l2p4 <= X"55"; -- U
					l2p5 <= X"42"; -- B
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
				
				when LDI_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4C"; -- L
					l2p4 <= X"44"; -- D
					l2p5 <= X"49"; -- I
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
					
				when LDI_X =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4C"; -- L
					l2p4 <= X"44"; -- D
					l2p5 <= X"49"; -- I
					l2p6 <= X"5F"; -- _
					l2p7 <= X"58"; -- X
					l2p8 <= X"20";

				when LDD_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4C"; -- L
					l2p4 <= X"44"; -- D
					l2p5 <= X"44"; -- D
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";

				when STR_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"53"; -- S
					l2p4 <= X"54"; -- T
					l2p5 <= X"52"; -- R
					l2p6 <= X"5F"; -- _
					l2p7 <= X"41"; -- A
					l2p8 <= X"20";
					
				when JMP =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4A"; -- J
					l2p4 <= X"4D"; -- M
					l2p5 <= X"50"; -- P
					l2p6 <= X"20"; 
					l2p7 <= X"20"; 
					l2p8 <= X"20";
					
				when JZ =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4A"; -- J
					l2p4 <= X"5A"; -- Z
					l2p5 <= X"20"; 
					l2p6 <= X"20"; 
					l2p7 <= X"20"; 
					l2p8 <= X"20";
					
				when SW_A =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"53"; -- S
					l2p4 <= X"57"; -- W
					l2p5 <= X"5F"; -- _
					l2p6 <= X"41"; -- A
					l2p7 <= X"20"; 
					l2p8 <= X"20";
					
				when LDD_X =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4C"; -- L
					l2p4 <= X"44"; -- D
					l2p5 <= X"44"; -- D
					l2p6 <= X"5F"; -- _
					l2p7 <= X"58"; -- X
					l2p8 <= X"20";
					
				when CPASS =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"43"; -- C
					l2p4 <= X"50"; -- P
					l2p5 <= X"41"; -- A
					l2p6 <= X"53"; -- S
					l2p7 <= X"53"; -- S
					l2p8 <= X"20";
					
				when PRINT =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"50"; -- P
					l2p4 <= X"72"; -- r
					l2p5 <= X"69"; -- i
					l2p6 <= X"6E"; -- n
					l2p7 <= X"74"; -- t
					l2p8 <= X"20";
					
				when LIMPA =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4C"; -- L
					l2p4 <= X"69"; -- i
					l2p5 <= X"6D"; -- m
					l2p6 <= X"70"; -- p
					l2p7 <= X"61"; -- a
					l2p8 <= X"20";
					
				when "11000000" =>
					l2p1 <= X"3E"; -- >
					l2p2 <= X"20";
					l2p3 <= X"4F"; -- O
					l2p4 <= X"50"; -- P
					l2p5 <= X"20";
					l2p6 <= X"20";
					l2p7 <= X"20";
					l2p8 <= X"20";
					
				when others => display_msg <= "11000000";
			end case;
			
		end if;
end process;

-- Display line 1 -----------------------------
	line1(127 downto 120) <= l1p1;	-- 01
	line1(119 downto 112) <= l1p2;	-- 02
	line1(111 downto 104) <= l1p3;	-- 03
	line1(103 downto 96)  <= l1p4;	-- 04
	line1(95 downto 88)   <= l1p5;	-- 05
	line1(87 downto 80)   <= l1p6;	-- 06
	line1(79 downto 72)   <= l1p7;	-- 07
	line1(71 downto 64)   <= l1p8;	-- 08
	line1(63 downto 56)   <= l1p9;	-- 09
	line1(55 downto 48)   <= l1p10;	-- 10
	line1(47 downto 40)   <= l1p11;	-- 11
	line1(39 downto 32)   <= l1p12;	-- 12
	line1(31 downto 24)   <= l1p13;	-- 13
	line1(23 downto 16)   <= l1p14;	-- 14
	line1(15 downto 8)    <= l1p15;	-- 15
	line1(7 downto 0)     <= l1p16;	-- 16
-- Display line 2 -----------------------------
	line2(127 downto 120) <= l2p1; 	-- 01
	line2(119 downto 112) <= l2p2;	-- 02
	line2(111 downto 104) <= l2p3; 	-- 03
	line2(103 downto 96)  <= l2p4;	-- 04
	line2(95 downto 88)   <= l2p5; 	-- 05
	line2(87 downto 80)   <= l2p6;	-- 06
	line2(79 downto 72)   <= l2p7; 	-- 07
	line2(71 downto 64)   <= l2p8;	-- 08
	line2(63 downto 56)   <= l2p9;	-- 09
	line2(55 downto 48)   <= l2p10;	-- 10
	line2(47 downto 40)   <= l2p11;	-- 11
	line2(39 downto 32)   <= l2p12;	-- 12
	line2(31 downto 24)   <= l2p13;	-- 13
	line2(23 downto 16)   <= l2p14;	-- 14
	line2(15 downto 8)    <= l2p15;	-- 15
	line2(7 downto 0)     <= l2p16;	-- 16

end Behavioral;

