LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( SIGNAL sw0, pb2, leftButton, rightButton, clk, vert_sync	: IN std_logic;
         SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		 	-- for score increment NEW 
		  SIGNAL score_ones_out, score_tens_out : OUT std_logic_vector(5 downto 0) := "110000";
		 
		  SIGNAL textOutput 			: IN std_logic;
		  SIGNAL red, green, blue	: OUT std_logic;
		  SIGNAL mouseReset 			: OUT std_logic := '0';
		  SIGNAL gameOver      		: OUT std_logic_vector(1 downto 0);
		  SIGNAL gameStart			: OUT std_logic_vector(1 downto 0));	
		  
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on					: std_logic;
SIGNAL background          : std_logic;
SIGNAL gameOverBackground  : std_logic;
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

SIGNAL pipeTop1				: std_logic;
SIGNAL pipeBot1				: std_logic;
SIGNAL pipeTop2				: std_logic;
SIGNAL pipeBot2				: std_logic;
SIGNAL pipeTop3				: std_logic;
SIGNAL pipeBot3				: std_logic;
SIGNAL pipeSpacing 			: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeWidth 				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeTopGap 			: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipeBotGap 			: std_logic_vector(9 DOWNTO 0); 
SiGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0) := "00000000000";
SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);
signal pipeXLeft 				: std_logic_vector(10 downto 0) := pipe_x_pos - pipeWidth - ball_x_pos - size - size;
signal pipeXRight 			: std_logic_vector(10 downto 0) := pipe_x_pos + pipeWidth - ball_x_pos;


SIGNAL ones_score,tens_score : std_logic_vector(5 downto 0) := "110000";


SIGNAL collision : std_logic := '0';
signal pipes : std_logic;

signal ballPadding : std_logic_vector(9 downto 0);
signal resetScore : std_logic_vector(5 downto 0) := "110000";

signal gameState : std_logic_vector(1 downto 0) := "00";


BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
ball_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);

pipeSpacing <= CONV_STD_LOGIC_VECTOR(200,10);
pipeWidth <= CONV_STD_LOGIC_VECTOR(20,10);
pipeTopGap <= CONV_STD_LOGIC_VECTOR(170,10);
pipeBotGap <= CONV_STD_LOGIC_VECTOR(250,10);

ballPadding <= CONV_STD_LOGIC_VECTOR(3,10);

ball_on <= '1' when ( ('0' & pixel_column + size >= '0' & ball_x_pos) 
					and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (pixel_row + size >= '0' & ball_y_pos) 
					and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
background <= '1' when (pixel_row >= 0 and pixel_row <= 479) or (pixel_column >= 0 and pixel_column <= 639) else
				  '0';

gameOverBackground <= '1' when (pixel_row >= 0 and pixel_row <= 479) or (pixel_column >= 0 and pixel_column <= 639) else
				  '0';
			  
		
pipeBot1 <= '1' when ( pixel_row >= pipeTopGap and pixel_row <= pipeBotGap) 
				else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
			  
pipeTop1 <= '0' when (( '1' & pixel_column + pipeWidth >= '1' & pipe_x_pos) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeWidth))
							else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';	
							
pipeBot2 <= '1' when ( pixel_row >= pipeTopGap + 80 and pixel_row <= pipeBotGap + 80) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';	
			  
pipeTop2 <= '0' when (( '1' & pixel_column + pipeWidth >= '1' & pipe_x_pos + pipeSpacing) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeSpacing + pipeWidth)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';
					
pipeBot3 <= '1' when ( pixel_row >= pipeTopGap - 50 and pixel_row <= pipeBotGap - 50) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
pipeTop3 <= '0' when (( '1' & pixel_column + pipeWidth >= '1' & pipe_x_pos + pipeSpacing + pipeSpacing) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeSpacing + pipeSpacing + pipeWidth)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';
			  
pipes <= (not pipeBot1 and not pipeTop1) or (not pipeBot2 and not pipeTop2) or (not pipeBot3 and not pipeTop3);



Move_Ball: process (vert_sync)
variable tick : std_logic := '0';
begin

-- Colour signal assignments
Red <= (background or ball_on) and (not pipes);
Green <=  (background or ball_on or pipes) and (not textOutput);
Blue <= background and (not ball_on) and (not pipes);


if (gameState = "01") then
	Red <= not gameOverBackground;
	Green <= not gameOverBackground;
	Blue <= not gameOverBackground;
	gameOver <= gameState;
end if;


	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then
		if (gameState = "00") then
			gameStart <= gameState;
			pipe_x_motion <= CONV_STD_LOGIC_VECTOR(1,11);
			pipe_x_pos <= pipe_x_pos - pipe_x_motion;
		end if;
		
		
			
			
			
		-- Pipe 1 collision
			score_ones_out <= ones_score;
			
			if ((ball_y_pos + size + ballPadding >= pipeBotGap) OR ((ball_y_pos <= pipeTopGap + size))) then
				if ((ball_x_pos + size  <= pipeXLeft) 
				and (ball_x_pos + size >= pipeXRight)) then
					 gameState <= "01";
					 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
					 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
				elsif (collision = '0' and (ball_x_pos + size <= pipeXLeft)) then
					if (ones_score < resetScore + "000001") then
						ones_score <= ones_score + "000001";
					else 
						ones_score <= ones_score;
					end if;
						
				end if;
			end if;
			


		--Pipe 2 collision
		if ((ball_y_pos + size + ballPadding >= pipeBotGap + 80) OR ((ball_y_pos - size + ballPadding <= pipeTopGap + 80))) then 
			if ((ball_x_pos + size <= pipeXLeft + pipeSpacing) 
			and (ball_x_pos + size >= pipeXRight + pipeSpacing)) then
				 gameState <= "01";
				 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
				 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
			elsif (gameState = "00" and (ball_x_pos + size <= pipeXLeft + pipeSpacing)) then
				if (ones_score < resetScore + "000010") then
					ones_score <= ones_score + "000001";
					else 
					ones_score <= ones_score;
				end if;
			end if;
		end if;
		
		
		
		-- Pipe 3 collision
		if ((ball_y_pos + size + ballPadding >= pipeBotGap - 50) OR ((ball_y_pos - size + ballPadding <= pipeTopGap - 50))) then 
			if ((ball_x_pos + size <= pipeXLeft + pipeSpacing + pipeSpacing) 
				and (ball_x_pos + size >= pipeXRight + pipeSpacing + pipeSpacing)) then
				 collision <='1';
				 gameState <= "01";
				 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
				 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
			elsif (gameState = "00" and (ball_x_pos + size <= pipeXLeft + pipeSpacing + pipeSpacing)) then
				if (ones_score < resetScore + "000011") then
					ones_score <= ones_score + "000001";
					else 
					ones_score <= ones_score;
				end if;
				
			end if;
		end if;
		
--		if (pipe_x_pos <= CONV_STD_LOGIC_VECTOR(0,11) + pipeSpacing + pipeSpacing) then
--			pipe_x_pos <= CONV_STD_LOGIC_VECTOR(639,11);
--		end if;

			
			if (leftButton = '1' and gameState = "00") then
				-- Bounce off top or bottom of the screen
				
				if (ball_y_pos <= size) then
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				end if; 
				
				
				ball_y_pos <= ball_y_pos + ball_y_motion - "000011111";
				
				
				mouseReset <= '1';
				
				
				
			elsif (leftButton = '0' and gameState = "00") then
				if (ball_y_pos <= size) then
					ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
				elsif ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479, 10) - size) then
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
				elsif (pb2 = '0') then
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
				elsif (pb2 = '1') then
					ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
				end if;
				-- Compute next ball Y position
				ball_y_pos <= ball_y_pos - ball_y_motion;
				
				mouseReset <= '0';

			 
				 -- hits the bottom or top of screen: This part works
			if (ball_y_pos+size >= CONV_STD_LOGIC_VECTOR(480,10) or ball_y_pos+size <= CONV_STD_LOGIC_VECTOR(0,10))then
					 collision<='1';
					 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
			end if ;
			
			
			
			
			
				

	end if;
end if;
end process Move_Ball;

END behavior;

