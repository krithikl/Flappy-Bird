LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( SIGNAL sw0, pb2, leftButton, rightButton, clk, vert_sync	: IN std_logic;
         SIGNAL pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL textOutput : IN std_logic;
		  SIGNAL red, green, blue 			: OUT std_logic);		
END bouncy_ball;

architecture behavior of bouncy_ball is

SIGNAL ball_on					: std_logic;
SIGNAL background          : std_logic;
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
SIGNAL pipeSpace 				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeSize 				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeTopYSize 			: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipeBotYSize 			: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipeTopYPos			: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeBotYPos			: std_logic_vector(9 DOWNTO 0);
SiGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);


SIGNAL collision : std_logic;
SIGNAL score : std_logic_vector(5 DOWNTO 0) := "110000";
signal pipes : std_logic;


BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);

pipeSpace <= CONV_STD_LOGIC_VECTOR(200,10);
pipeSize <= CONV_STD_LOGIC_VECTOR(20,10);
pipeTopYSize <= CONV_STD_LOGIC_VECTOR(170,10);
pipeBotYSize <= CONV_STD_LOGIC_VECTOR(250,10);


pipeTopYPos <= CONV_STD_LOGIC_VECTOR(100,10);
pipeBotYPos <= CONV_STD_LOGIC_VECTOR(400,10);



ball_on <= '1' when ( ('0' & pixel_column + size >= '0' & ball_x_pos) 
					and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (pixel_row + size >= '0' & ball_y_pos) 
					and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
background <= '1' when (pixel_row >= 0 and pixel_row <= 479) else
				  '0';
			  
		
pipeBot1 <= '1' when ( pixel_row >= pipeTopYSize and pixel_row <= pipeBotYSize) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';	
			  
pipeTop1 <= '0' when (( '1' & pixel_column + pipeSize >= '1' & pipe_x_pos) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeSize) and
							(pixel_row + pipeSize >= '1' & pipeTopYPos) and
							('1' & pixel_row <= pipeTopYPos + pipeSize)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';	
							
pipeBot2 <= '1' when ( pixel_row >= pipeTopYSize + 80 and pixel_row <= pipeBotYSize + 80) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';	
			  
pipeTop2 <= '0' when (( '1' & pixel_column + pipeSize >= '1' & pipe_x_pos + pipeSpace) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeSpace + pipeSize) and
							(pixel_row + pipeSize >= '1' & pipeTopYPos) and
							('1' & pixel_row <= pipeTopYPos + pipeSize)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';
					
pipeBot3 <= '1' when ( pixel_row >= pipeTopYSize - 50 and pixel_row <= pipeBotYSize - 50) else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
pipeTop3 <= '0' when (( '1' & pixel_column + pipeSize >= '1' & pipe_x_pos + pipeSpace + pipeSpace) and 
							('1' & pixel_column <= '1' & pipe_x_pos + pipeSpace + pipeSpace + pipeSize) and
							(pixel_row + pipeSize >= '1' & pipeTopYPos) and
							('1' & pixel_row <= pipeTopYPos + pipeSize)) else	-- y_pos - size <= pixel_row <= y_pos + size
							'1';
			  
pipes <= (not pipeBot1 and not pipeTop1) or (not pipeBot2 and not pipeTop2) or (not pipeBot3 and not pipeTop3);

-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons


Move_Ball: process (vert_sync)
begin
--	Red <= (not ball_on) and (not textOutput);
--	Green <= not sw0;
--	Blue <= (not pipe_on);

--	Red <= not pipes;
--	Green <= (not ball_on) and (not textOutput);
--	Blue <= '0';

	Red <= not background or ball_on or pipes;
	Green <=  not background or ball_on;
	Blue <= not background or (textOutput) ;


	-- Move ball once every vertical sync
	if (rising_edge(vert_sync)) then	
	
		if (pb2 = '1') then
			pipe_x_motion <= CONV_STD_LOGIC_VECTOR(4,11);
			
		end if;
		pipe_x_pos <= pipe_x_pos - pipe_x_motion;
		
		if (leftButton = '1') then
			-- Bounce off top or bottom of the screen
			if (ball_y_pos <= size) then 
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
			end if;
			
			
			-- Compute next ball Y position
			ball_y_pos <= ball_y_pos + ball_y_motion - "000000111";
			
		elsif (leftButton = '0') then
			if (ball_y_pos <= size) then
				ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
			elsif ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479, 10) - size) then
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
			elsif (pb2 = '0') then
				ball_y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
			elsif (pb2 = '1') then
				ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
			end if;
				
				
	 
--	--	 collision code 
--
--	    -- hits the pipe
--			if (ball_x_pos+size >= pipe_x_pos or ball_y_pos+size <= pipeTopYPos or ball_y_pos-size >= pipeBotYPos) then 
--				 collision <='1';
--				 
--				 -- hits the bottom or top of screen
--				 elsif (ball_y_pos+size >= CONV_STD_LOGIC_VECTOR(480,10)or ball_y_pos+size <= CONV_STD_LOGIC_VECTOR(0,10))then
--				  collision<='1';
--			end if ;
--
---- score calculation 
--			if (collision ='0') then 
--				score <= score+1;
--				elsif (collision ='1') then 
--				 score <= score;
--			end if; 	
			
			-- Compute next ball Y position
			ball_y_pos <= ball_y_pos - ball_y_motion;
		
	end if;
end if;
end process Move_Ball;

END behavior;

