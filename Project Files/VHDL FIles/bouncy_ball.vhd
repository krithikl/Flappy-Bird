library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( SIGNAL sw0, pb2, leftButton, rightButton, clk, vert_sync	: IN std_logic;
         SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		 	
		  SIGNAL score_ones_out, score_tens_out : OUT std_logic_vector(5 downto 0) := "110000";
		 
		  SIGNAL textOutput 			: IN std_logic; 
		  SIGNAL gameOverText		: IN std_logic; 
		  SIGNAL mainmenuText		: IN std_logic;  
		  signal randNum				: IN std_logic_vector(7 downto 0);
		  signal gameModeText		: IN std_logic;
		  SIGNAL red, green, blue	: OUT std_logic; 
		  SIGNAL mouseReset 			: OUT std_logic := '0'; 
		  
		
		 
		 
		  SIGNAL gameOver      		: OUT std_logic_vector(1 downto 0); 
		  SIGNAL gameStart			: OUT std_logic_vector(1 downto 0); 
		  SIGNAL lives_out 			: OUT std_logic_vector(3 downto 0)); 
		  
END bouncy_ball;

architecture behavior of bouncy_ball is



SIGNAL ball_on					: std_logic;
SIGNAL background          : std_logic;
SIGNAL gameOverBackground  : std_logic;
SIGNAL mainMenuBackground  : std_logic;
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
SiGNAL pipe1_x_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,11);
SiGNAL pipe2_x_pos			: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,11);
SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);
signal pipe1XLeft 				: std_logic_vector(10 downto 0) := pipe1_x_pos - pipeWidth - ball_x_pos - size - size;
signal pipe1XRight 			: std_logic_vector(10 downto 0) := pipe1_x_pos + pipeWidth - ball_x_pos;
signal pipe2XLeft 				: std_logic_vector(10 downto 0) := pipe2_x_pos - pipeWidth - ball_x_pos - size - size;
signal pipe2XRight 			: std_logic_vector(10 downto 0) := pipe2_x_pos + pipeWidth - ball_x_pos;


SIGNAL ones_score,tens_score : std_logic_vector(5 downto 0) := "110000";

-- NEW 
SIGNAL lives : std_logic_vector(3 DOWNTO 0) := "0011"; --3 

SIGNAL collision : std_logic := '0';
signal pipes : std_logic;

signal ballPadding : std_logic_vector(9 downto 0);
signal resetScore : std_logic_vector(5 downto 0) := "110000";

signal gameState : std_logic_vector(1 downto 0) := "00";

SIGNAL rand_num1: STD_LOGIC_VECTOR (7 DOWNTO 0):= "01111111";
SIGNAL rand_num_variable1: STD_LOGIC_VECTOR (6 DOWNTO 0):= "1111111";
signal temp1 : std_logic := '0';

SIGNAL rand_num2: STD_LOGIC_VECTOR (7 DOWNTO 0):= "01111111";
SIGNAL rand_num_variable2: STD_LOGIC_VECTOR (6 DOWNTO 0):= "0101010";
signal temp2 : std_logic := '0';

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
ball_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);

pipeSpacing <= CONV_STD_LOGIC_VECTOR(400,10);
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
			
mainMenuBackground <= '1' when (pixel_row >= 0 and pixel_row <= 479) or (pixel_column >= 0 and pixel_column <= 639) else
				  '0';
			  
		
pipeBot1 <= '1' when ( pixel_row >= pipeTopGap + rand_num1 and pixel_row <= pipeBotGap + rand_num1) 
				else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
			  
pipeTop1 <= '0' when (( '1' & pixel_column + pipeWidth >= '1' & pipe1_x_pos) and 
							('1' & pixel_column <= '1' & pipe1_x_pos + pipeWidth))
							else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';	
							
pipeBot2 <= '1' when ( pixel_row >= pipeTopGap + rand_num2 and pixel_row <= pipeBotGap + rand_num2) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';	
			  
pipeTop2 <= '0' when (( '1' & pixel_column + pipeWidth >= '1' & pipe2_x_pos + pipeSpacing) and 
							('1' & pixel_column <= '1' & pipe2_x_pos + pipeSpacing + pipeWidth)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';

pipes <= ((not pipeBot1 and not pipeTop1) or (not pipeBot2 and not pipeTop2));

--pipes <= ((not pipeBot1 and not pipeTop1));

Move_Ball: process (vert_sync)
variable tick : std_logic := '0';
variable incrementScore : std_logic := '0';
variable incrementScore2 : std_logic := '0';

begin
	
		-- Main menu selection of training mode
		if (gameState = "00" and sw0 = '1') then
			Red <= not mainMenuBackground or not mainMenuText;
			Green <= not mainMenuBackground;
			Blue <= not mainMenuBackground;
		end if;
		
		-- Main Menu selection of normal mode
		if (gameState = "00" and sw0 = '0') then
			Red <= not mainMenuBackground or not gameModeText;
			Green <= not mainMenuBackground;
			Blue <= not mainMenuBackground;
		end if;
		
		-- Normal mode
		if (gameState = "01") then 
			Red <= (background or ball_on) and ((not pipes) or ( textOutput));
			Green <=  (background or ball_on or pipes) and (not textOutput);
			Blue <= background and (not ball_on) and ((not pipes) or (textOutput));
		end if;
		
		-- Training mode
		if (gameState = "10") then
			Red <= (background or ball_on) and ((not pipes) or ( textOutput));
			Green <=  (background or ball_on or pipes) and (not textOutput);
			Blue <= background and (not ball_on) and ((not pipes) or (textOutput));
		end if;	
		
		-- Game over
		if (gameState = "11") then 
			gameOver <= gameState;
			Red <= not gameOverBackground or not gameOverText;
			Green <= not gameOverBackground;
			Blue <= not gameOverBackground;
		end if;


		-- Move ball once every vertical sync
		if (rising_edge(vert_sync)) then

			-- Initialise to training mode
			if (sw0 = '1' and rightButton = '1') then
				gameState <= "10";
			end if;
			
			-- Initialise to normal game mode
			if (sw0 = '0' and rightButton = '1') then
				gameState <= "01";
			end if;
			
			if (gameState = "01" or gameState = "10") then
				gameStart <= gameState;
				pipe_x_motion <= CONV_STD_LOGIC_VECTOR(4,11);
				pipe1_x_pos <= pipe1_x_pos - pipe_x_motion;
				pipe2_x_pos <= pipe2_x_pos - pipe_x_motion;
				if((pipe1_x_pos + pipeWidth) <=  '1' & CONV_STD_LOGIC_VECTOR(0,10)) then  
					pipe1_x_pos <= '1' & CONV_STD_LOGIC_VECTOR(640,10) + pipeWidth + pipeSpacing;
					temp1 <= rand_num1(6) XOR rand_num1(4) XOR rand_num1(3) XOR rand_num1(2) XOR rand_num1(0);
					rand_num1 <= temp1 & rand_num_variable1;
					incrementScore := '0';	
				end if;
				if((pipe2_x_pos + pipeWidth + pipeSpacing) <=  '1' & CONV_STD_LOGIC_VECTOR(0,10)) then  
					pipe2_x_pos <= '1' & CONV_STD_LOGIC_VECTOR(640,10) + pipeWidth;
					temp2 <= rand_num2(6) XOR rand_num2(4) XOR rand_num2(3) XOR rand_num2(2) XOR rand_num2(0);
					rand_num2 <= temp2 & rand_num_variable2;
					incrementScore2 := '0';	
				end if;
			end if;
			

			
			
				
			-- Pipe 1 collision
				score_ones_out <= ones_score;
				lives_out <= lives; 
				
				-- Game over if lives gone
				if (lives = "0000") then
					gameState <= "11";
				end if;

				if ((ball_y_pos + size + ballPadding >= pipeBotGap + rand_num1) OR ((ball_y_pos <= pipeTopGap + size + rand_num1))) then
					if ((ball_x_pos + size  <= pipe1XLeft) 
					and (ball_x_pos + size >= pipe1XRight)) then
						if (gameState = "10") then
							ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
							pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
							ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
							ones_score <= "110000";

							--decreases lives if collision occurs  
							lives <= lives - "0001"; 
						end if;
						
						if (gameState = "01") then
							 gameState <= "11";
							 ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
							 pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
							 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
							 ones_score <= "110000";
						end if;

						 
					end if;
--				elsif ((ball_y_pos + size + ballPadding <= pipeBotGap) OR ((ball_y_pos >= pipeTopGap + size))) then
					if ((gamestate = "01" or gameState = "10") and (ball_x_pos + size <= pipe1XLeft)) then
						if (incrementScore = '0') then
							incrementScore := '1';
							ones_score <= ones_Score + "000001";
						end if;
							
					end if;
				end if;
						

--			--Pipe 2 collision
			if ((ball_y_pos + size + ballPadding >= pipeBotGap + rand_num2) OR (ball_y_pos - size + ballPadding <= pipeTopGap + rand_num2)) then
				if ((ball_x_pos + size <= pipe2XLeft + pipeSpacing) 
				and (ball_x_pos + size >= pipe2XRight + pipeSpacing)) then
					 if (gameState = "10") then
							 ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
							 pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
							 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
							 ones_score <= "110000";

							--decreases lives if collision occurs  
						 	lives <= lives - "0001"; 
							 
						end if;
						
						if (gameState = "01") then
							 gameState <= "11";
							 ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
							 pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
							 pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
							 ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
							 ones_score <= "110000";

						end if;
				elsif ((gamestate = "01" or gameState = "10") and (ball_x_pos + size <= pipe2XLeft + pipeSpacing)) then
					if (incrementScore2 = '0') then
						incrementScore2 := '1';
						ones_score <= ones_Score + "000001";
					end if;
				end if;
			end if;
--	
				
			if (leftButton = '1' and (gameState = "01" or gameState = "10")) then
				-- Bounce off top or bottom of the screen
				
				if (ball_y_pos <= size) then
					ball_y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				end if; 
				
				
				ball_y_pos <= ball_y_pos + ball_y_motion - "000011111";
				
				
				mouseReset <= '1';
				
				
				
			elsif (leftButton = '0' and (gameState = "01" or gameState = "10")) then
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
					if (gameState = "01") then
						gameState <= "11";
						ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
						pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
						pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);
						ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
						ones_score <= "110000";
					end if;
					
					if (gameState = "10") then
						ball_y_pos <= CONV_STD_LOGIC_VECTOR(50,10);
						pipe1_x_pos <= CONV_STD_LOGIC_VECTOR(0,11);
						pipe2_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);
						ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						pipe_x_motion <= CONV_STD_LOGIC_VECTOR(0,11);
						ones_score <= "110000";

						--decreases lives if collision occurs  
						lives <= lives - "0001"; 
					end if;
				end if ;

	end if;
end if;
end process Move_Ball;

END behavior;

