library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_SIGNED.all; 
use IEEE.NUMERIC_STD.all; 



ENTITY game_over_display is 
	PORT(
		clock_25Mhz : IN STD_LOGIC;
		pixel_row, pixel_column: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		ones_score, tens_score:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		gameState : in std_LOGIC_VECTOR(1 DOWNTO 0);
		over_text_on : OUT STD_LOGIC;
		output_text : OUT STD_LOGIC	
	  );
END ENTITY game_over_display;



ARCHITECTURE BEHAVIOUR of game_over_display is

	COMPONENT char_rom
		PORT 
			(
				character_address	:	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
				font_row, font_col	:	IN STD_LOGIC_VECTOR (2 DOWNTO 0);
				clock				: 	IN STD_LOGIC ;
				rom_mux_output		:OUT STD_LOGIC
			);
			
	end COMPONENT;

	SIGNAL score_display : std_logic_vector(5 downto 0);
	SIGNAL output_score  : STD_LOGIC := '0';
	SIGNAL game_over_display : std_logic_vector(5 downto 0); 
 
	
BEGIN							
	 
		over_text_on <= '1' when (output_score = '1' and pixel_column <= CONV_STD_LOGIC_VECTOR(418,10) and pixel_column >= CONV_STD_LOGIC_VECTOR(255,10) 
		and pixel_row <= CONV_STD_LOGIC_VECTOR(45,10) and pixel_row >= CONV_STD_LOGIC_VECTOR(30,10)) else'0';
							
	game_over_display <= 
		
					CONV_STD_LOGIC_VECTOR(7,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(271,10) else --"G"
					CONV_STD_LOGIC_VECTOR(1,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(287,10) else --"A"
					CONV_STD_LOGIC_VECTOR(13,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(303,10) else --"M"
					CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(319,10) else --"E"
					CONV_STD_LOGIC_VECTOR(32,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(335,10) else --"space"					
					CONV_STD_LOGIC_VECTOR(15,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(351,10) else --"O"
					CONV_STD_LOGIC_VECTOR(22,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(367,10) else --"V"
					CONV_STD_LOGIC_VECTOR(5,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(383,10) else --"E"
					CONV_STD_LOGIC_VECTOR(18,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(399,10) else --"R"
					CONV_STD_LOGIC_VECTOR(33,6) when pixel_column <= CONV_STD_LOGIC_VECTOR(415,10) --"!" 
		
				;
		
		scoretext : char_rom PORT MAP(
							character_address => game_over_display,
							font_row=>pixel_row(3 downto 1),
							font_col=>pixel_column(3 downto 1),
							clock => clock_25Mhz,
							rom_mux_output =>output_score
							);

	output_text <= output_score;

END ARCHITECTURE;