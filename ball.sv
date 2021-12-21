// Name: Justin Low (jkl37)
//
// Pong Game - ball module
//
// Uriel Martinez-Hernandez
// Univesity of Bath
// November 2019
//
// This module governs the display for the ball in the Pong game, as well as its
// physics interacting with the bars and walls.
//
// The ball should reflect off the top and bottom wall, and the top and bottom
// of the bars. The ball will bounce off the left and right bar differently
// depending on which part of the bar it hits. For example, hitting the bar near
// the middle would give the ball a low angle of return and average speed.
// Hitting the bar near the edge would give the ball a higher angle of return
// and above average speed.
//
// Whenever the ball hits the left or right wall, the player controlling the bar
// on the opposing side will have 1 point added to their score.
//
// Note: Due to lack of support for real data type variables in Quartus Prime,
// the displacement (ballX64,ballY64) and velocity (xVel,yVel) of the ball have
// been upscaled by 6 bits so that they can have finer precision. The
// displacement of the ball is then downscaled by 6 bits (ballX,ballY) so that
// the ball may be projected onto the display.
// The collision detections for the ball are still graphically based, and use
// the original displacement variables ballX and ballY.

module ball
#(								// default values
	oLeft = 10,				// x position of the ball
	oTop = 10,				// y position of the ball
	oHeight = 20,			// height of the ball
	oWidth = 20,			// width of the ball
	sWidth = 800,			// width of the screen
	sHeight = 600,			// height of the screen
	xDirMove = 48,			// ball movement in x direction
	yDirMove = 48,			// ball movement in y direction
	LBarHeight = 150,		// height of the left bar
	RBarHeight = 150		// height of the right bar
)
(
	input PixelClock,        	// slow clock to display pixels
	input Reset,             	// reset position/movement of the ball
	input  logic [11:0] xPos,        	// x position of hCounter
	input  logic [11:0] yPos,        	// y position of vCounter
	input  logic [10:0] leftBarEdges[4],	// Coordinates of the left and right
	input  logic [10:0] rightBarEdges[4],	// bar, defined by their sides
	output logic drawBall,		       	// activates/deactivates drawing
	output logic [6:0] leftScore = 0,	// Left player's score
	output logic [6:0] rightScore = 0	// Right player's score
);

	logic [10:0] left;
	logic [10:0] right;
	logic [10:0] top;
	logic [10:0] bottom;
	logic [10:0] yCentre;

	logic [10:0] ballX;
	logic [10:0] ballY;
	logic [16:0] ballX64 = oLeft << 6;
	logic [16:0] ballY64 = oTop  << 6;

	logic signed [7:0] nextxVel = xDirMove;
	logic signed [7:0] nextyVel = yDirMove;
	logic signed [7:0] xVel = xDirMove;
	logic signed [7:0] yVel = yDirMove;

	assign ballX = ballX64 >> 6;
	assign ballY = ballY64 >> 6;

	assign left   = ballX;              	// Left (x) position of the ball
	assign right  = ballX + oWidth - 1; 	// Right (x+width+1) position of the ball
	assign top    = ballY;              	// Top (y) position of the ball
	assign bottom = ballY + oHeight - 1;	// Bottom (y+height-1) position of the ball
	assign yCentre = (top + bottom) / 2;	// Vertical centre of the ball

	logic [10:0] LBarLeft, LBarRight, LBarTop, LBarBottom;
	logic [10:0] RBarLeft, RBarRight, RBarTop, RBarBottom;

	// x positions of left & right, and y positions of top & bottom of both bars
	assign {LBarLeft,LBarRight,LBarTop,LBarBottom} = {leftBarEdges[0],leftBarEdges[1],leftBarEdges[2],leftBarEdges[3]};
	assign {RBarLeft,RBarRight,RBarTop,RBarBottom} = {rightBarEdges[0],rightBarEdges[1],rightBarEdges[2],rightBarEdges[3]};



	// Update the displacement and velocity of the ball
	// depending on four states: the game is reset, the
	// right player scores, the left player score, and
	// the game is still in play.
	always_ff @ (posedge PixelClock)
	begin
		if( Reset == 1 )				// all values are initialised
		begin           				// whenever the reset(SW[9]) is 1
			ballX64 <= oLeft << 6;
			ballY64 <= oTop  << 6;
			xVel <= xDirMove;
			yVel <= yDirMove;
			leftScore <= 0;
			rightScore <= 0;
		end
		else if (left <= 1 & xVel < 0) // Right player scores
		begin
			ballX64 <= oLeft << 6;
			ballY64 <= oTop  << 6;
			xVel <= xDirMove;
			yVel <= yDirMove;
			rightScore <= rightScore + 1;
		end
		else if (right >= sWidth & xVel > 0) // Left player scores
		begin
			ballX64 <= oLeft << 6;
			ballY64 <= oTop  << 6;
			xVel <= ~xDirMove;
			yVel <=  yDirMove;
			leftScore <= leftScore + 1;
		end
		else // Update ball displacement and velocity in the next clock cycle
		begin
			xVel <= nextxVel;
			yVel <= nextyVel;
			ballX64 <= $signed(ballX64) + nextxVel;
			ballY64 <= $signed(ballY64) + nextyVel;
		end
	end



	// Divide the left and right bar into eight sections.
	// The ball will return at different speeds and directions depending on
	// which section it hits. Sections further from the middle return the ball
	// at a higher angle.
	logic [10:0] LUpper4,LUpper3,LUpper2,LUpper1,LMiddle,LLower1,LLower2,LLower3,LLower4;
	logic [10:0] RUpper4,RUpper3,RUpper2,RUpper1,RMiddle,RLower1,RLower2,RLower3,RLower4;

	parameter LCollisionHeight = LBarHeight + oHeight;
	parameter RCollisionHeight = RBarHeight + oHeight;

	assign LUpper4 = LBarTop -   oHeight/2;
	assign LUpper3 = LUpper4 +   LCollisionHeight/8;
	assign LUpper2 = LUpper4 + 2*LCollisionHeight/8;
	assign LUpper1 = LUpper4 + 3*LCollisionHeight/8;
	assign LMiddle = LUpper4 + 4*LCollisionHeight/8;
	assign LLower1 = LUpper4 + 5*LCollisionHeight/8;
	assign LLower2 = LUpper4 + 6*LCollisionHeight/8;
	assign LLower3 = LUpper4 + 7*LCollisionHeight/8;
	assign LLower4 = LUpper4 +   LCollisionHeight;

	assign RUpper4 = RBarTop -   oHeight/2;
	assign RUpper3 = RUpper4 +   RCollisionHeight/8;
	assign RUpper2 = RUpper4 + 2*RCollisionHeight/8;
	assign RUpper1 = RUpper4 + 3*RCollisionHeight/8;
	assign RMiddle = RUpper4 + 4*RCollisionHeight/8;
	assign RLower1 = RUpper4 + 5*RCollisionHeight/8;
	assign RLower2 = RUpper4 + 6*RCollisionHeight/8;
	assign RLower3 = RUpper4 + 7*RCollisionHeight/8;
	assign RLower4 = RUpper4 +   RCollisionHeight;



	always_comb
	begin
		// Evaluate collision with top and bottom wall
		if ((top <= 2) & (yVel < 0) | (bottom >= sHeight - 1) & (yVel > 0))
			{nextxVel,nextyVel} = {xVel,-yVel};

		// Evaluate collision with left bar
		else if ((left >= LBarRight) & (left <= LBarRight+2) & (xVel < 0)) // Collision with vertical wall of left bar
		begin
			if (yCentre >= LUpper4 & yCentre < LUpper3)     	// Evaluate collision with each individual
				{nextxVel,nextyVel} = {8'sd59,-8'sd102};      	// section of the right side of the left
			else if (yCentre >= LUpper3 & yCentre < LUpper2)  // bar, and assign the appropriate speed
				{nextxVel,nextyVel} = {8'sd77,-8'sd77};      		// and direction
			else if (yCentre >= LUpper2 & yCentre < LUpper1)
				{nextxVel,nextyVel} = {8'sd86,-8'sd50};
			else if (yCentre >= LUpper1 & yCentre < LMiddle)
				{nextxVel,nextyVel} = {8'sd87,-8'sd23};
			else if (yCentre >= LMiddle & yCentre < LLower1)
				{nextxVel,nextyVel} = {8'sd87, 8'sd23};
			else if (yCentre >= LLower1 & yCentre < LLower2)
				{nextxVel,nextyVel} = {8'sd86, 8'sd50};
			else if (yCentre >= LLower2 & yCentre < LLower3)
				{nextxVel,nextyVel} = {8'sd77, 8'sd77};
			else if (yCentre >= LLower3 & yCentre < LLower4)
				{nextxVel,nextyVel} = {8'sd59, 8'sd102};
			else
				{nextxVel,nextyVel} = {xVel,yVel};
		end
		// Collision with top and bottom of left bar
		else if ((bottom <= LBarTop) & (bottom >= LBarTop-3) & (left <= LBarRight) & (right >= LBarLeft) & (yVel > 0))
			{nextxVel,nextyVel} = {xVel,-yVel};
		else if ((top >= LBarBottom) & (top <= LBarBottom+3) & (left <= LBarRight) & (right >= LBarLeft) & (yVel < 0))
			{nextxVel,nextyVel} = {xVel,-yVel};

		// Evaluate collision with right bar
		else if ((right <= RBarLeft) & (right >= RBarLeft-2) & (xVel > 0)) // Collision with vertical wall of right bar
		begin
			if (yCentre >= RUpper4 & yCentre < RUpper3)     	// Same as the left bar above, except
				{nextxVel,nextyVel} = {-8'sd59,-8'sd102};    		// collision detection is evaluated for
			else if (yCentre >= RUpper3 & yCentre < RUpper2)	// the left side of the right bar
				{nextxVel,nextyVel} = {-8'sd77,-8'sd77};
			else if (yCentre >= RUpper2 & yCentre < RUpper1)
				{nextxVel,nextyVel} = {-8'sd86,-8'sd50};
			else if (yCentre >= RUpper1 & yCentre < RMiddle)
				{nextxVel,nextyVel} = {-8'sd87,-8'sd23};
			else if (yCentre >= RMiddle & yCentre < RLower1)
				{nextxVel,nextyVel} = {-8'sd87, 8'sd23};
			else if (yCentre >= RLower1 & yCentre < RLower2)
				{nextxVel,nextyVel} = {-8'sd86, 8'sd50};
			else if (yCentre >= RLower2 & yCentre < RLower3)
				{nextxVel,nextyVel} = {-8'sd77, 8'sd77};
			else if (yCentre >= RLower3 & yCentre < RLower4)
				{nextxVel,nextyVel} = {-8'sd59, 8'sd102};
			else
				{nextxVel,nextyVel} = {xVel,yVel};
		end
		// Collision with top and bottom of right bar
		else if ((bottom <= RBarTop) & (bottom >= RBarTop-3) & (left <= RBarRight) & (right >= RBarLeft) & (yVel > 0))
			{nextxVel,nextyVel} = {xVel,-yVel};
		else if ((top >= RBarBottom) & (top <= RBarBottom+3) & (left <= RBarRight) & (right >= RBarLeft) & (yVel < 0))
			{nextxVel,nextyVel} = {xVel,-yVel};

		else
			{nextxVel,nextyVel} = {xVel,yVel};
	end

	// drawBall is 1 if the screen counters (hCount and vCount) are in the area of the ball
	// otherwise, drawBall is 0 and the ball is not drawn.
	// drawBall is used by the top module PongGame
	assign drawBall = ((xPos >= left) & (yPos >= top) & (xPos <= right) & (yPos <= bottom)) ? 1 : 0;

endmodule
