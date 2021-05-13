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
SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0);
SiGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

SIGNAL pipeTop1				: std_logic;
SIGNAL pipeBot1				: std_logic;
SIGNAL pipeSize 				: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeYSize 				: std_logic_vector(9 DOWNTO 0); 
SIGNAL pipeTopYPos			: std_logic_vector(9 DOWNTO 0);
SIGNAL pipeBotYPos			: std_logic_vector(9 DOWNTO 0);
SiGNAL pipe_x_pos				: std_logic_vector(10 DOWNTO 0);
SIGNAL pipe_x_motion			: std_logic_vector(10 DOWNTO 0);

BEGIN           

size <= CONV_STD_LOGIC_VECTOR(8,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(250,11);

pipeSize <= CONV_STD_LOGIC_VECTOR(30,10);
pipeYSize <= CONV_STD_LOGIC_VECTOR(100,10);


pipeTopYPos <= CONV_STD_LOGIC_VECTOR(94,10);
pipeBotYPos <= CONV_STD_LOGIC_VECTOR(400,10);




ball_on <= '1' when ( ('0' & pixel_column + size >= '0' & ball_x_pos) 
					and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (pixel_row + size >= '0' & ball_y_pos) 
					and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';
			  
pipeTop1 <= '1' when ( ('0' & pixel_column + pipeSize >= '0' & pipe_x_pos) 
					and ('0' & pixel_column <= '0' & pipe_x_pos + pipeSize) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (pixel_row + pipeSize + "0001000000" >= '0' & pipeTopYPos) 
					and ('0' & pixel_row <= pipeTopYPos + pipeSize) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';	
			  
pipeBot1 <= '1' when ( ('0' & pixel_column + pipeSize >= '0' & pipe_x_pos) 
					and ('0' & pixel_column <= '0' & pipe_x_pos + pipeSize) 	-- x_pos - size <= pixel_column <= x_pos + size
					and (pixel_row + pipeSize + "0001000000" >= '0' & pipeBotYPos) 
					and ('0' & pixel_row <= pipeBotYPos + "0001000000") )  else	-- y_pos - size <= pixel_row <= y_pos + size
			  '0';		  


-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons


Move_Ball: process (vert_sync)
variable tick : std_logic := '0';
begin
--	Red <= (not ball_on) and (not textOutput);
--	Green <= not sw0;
--	Blue <= (not pipe_on);

	Red <= (not pipeTop1) and (not pipeBot1);
	Green <= (not ball_on) and (not textOutput);
	Blue <= '1';

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
			tick := '0';
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
		
	end if;
end if;
end process Move_Ball;

END behavior;

