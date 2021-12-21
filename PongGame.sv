// Name: Justin Low (jkl37)
//
// Pong Game - top module
//
// Uriel Martinez-Hernandez
// Univesity of Bath
// November 2019
//


module PongGame
(
	input CLOCK_50,
	input [3:0] KEY,
	input [9:0] SW,
	output logic VGA_CLK,
	output logic VGA_BLANK_N,
	output logic VGA_SYNC_N,
	output logic VGA_HS,
	output logic VGA_VS,
	output logic [7:0] VGA_R,
	output logic [7:0] VGA_G,
	output logic [7:0] VGA_B
);

	assign VGA_CLK = ~CLOCK_50;


	logic [11:0] xPos;			// current x position of hCount from the VGA controller
	logic [11:0] yPos;			// current y position of vCount from tge VGA controller

	logic drawLine;
	logic drawScore;
	logic drawleftScore;
	logic drawRightScore;
	logic drawBall;
	logic drawLeftBar;
	logic drawRightBar;
	logic [10:0] leftBarEdges[4]; 	// Sides of the left bar
	logic [10:0] rightBarEdges[4];	// Sides of the right bar

	logic [6:0] leftScore; 	// Left player's score
	logic [6:0] rightScore;	// Right player's score

	parameter LBarHeight = 70;
	parameter RBarHeight = 70;


	// Instantiation of the VGA controller
	VgaController vgaDisplay
	(
		.Clock(CLOCK_50),
		.Reset(SW[9]),
		.blank_n(VGA_BLANK_N),
		.sync_n(VGA_SYNC_N),
		.hSync_n(VGA_HS),
		.vSync_n(VGA_VS),
		.nextX(xPos),
		.nextY(yPos)
	);


	// Instantiation of the slowClock module
	slowClock #(17) tick(CLOCK_50, SW[9], pix_stb);


	// Instantiation of the ball module
	// oLeft and oTop define the x,y initial position of the object
	ball #(.oLeft(395), .oTop(295), .oHeight(10), .oWidth(10), .LBarHeight(LBarHeight), .RBarHeight(RBarHeight)) BallObj
	(
		.PixelClock(pix_stb),
		.Reset(SW[9]),
		.xPos(xPos),
		.yPos(yPos),
		.leftBarEdges,
		.rightBarEdges,
		.drawBall(drawBall),
		.leftScore,
		.rightScore
	);

	// instantiation of the left bar
	// oLeft and oTop define the x,y initial position of the object
	bar #(.oLeft(30), .oTop(265), .oWidth(10), .oHeight(LBarHeight)) leftBar
	(
		.Clock(CLOCK_50),
		.PixelClock(pix_stb),
		.Reset(SW[9]),
		.Button(~KEY[3:2]),
		.xPos(xPos),
		.yPos(yPos),
		.drawBar(drawLeftBar),
		.barEdges(leftBarEdges)
	);

	// Instantiation of the right bar
	// oLeft and oTop define the x,y initial position of the object
	bar #(.oLeft(760), .oTop(265), .oWidth(10), .oHeight(RBarHeight)) RightBar
	(
		.Clock(CLOCK_50),
		.PixelClock(pix_stb),
		.Reset(SW[9]),
		.Button(~KEY[1:0]),
		.xPos(xPos),
		.yPos(yPos),
		.drawBar(drawRightBar),
		.barEdges(rightBarEdges)
	);

	// Instantiation of the left player's score display
	ScoreDecoder #(.oLeft(320)) LeftScoreDisplay
	(
		.score(leftScore),
		.xPos,
		.yPos,
		.drawScore(drawLeftScore)
	);

	// Instantiation of the left player's score display
	ScoreDecoder #(.oLeft(410)) RightScoreDisplay
	(
		.score(rightScore),
		.xPos,
		.yPos,
		.drawScore(drawRightScore)
	);

	assign drawScore = drawLeftScore | drawRightScore;
	// Draws a dotted line down the middle to denote the left
	// and right half of the screen
	assign drawLine  = ((xPos >= 397) & (xPos < 401) & ~yPos[4]);

	// this block is used to draw all the objects on the screen
	// you can add more objects and their corresponding colour
	always_comb
	begin
		if (drawBall)														// if true from the ball module
			{VGA_R, VGA_G, VGA_B} = {8'hFF, 8'hFF, 8'hFF};
		else if (drawScore | drawLine)
			{VGA_R, VGA_G, VGA_B} = {8'hA0, 8'hA0, 8'hA0};		// then draws the ball using white colour
		else if (drawLeftBar)
			{VGA_R, VGA_G, VGA_B} = {8'hFF, 8'h60, 8'h60};
		else if (drawRightBar)
			{VGA_R, VGA_G, VGA_B} = {8'h60, 8'h60, 8'hFF};
		else
			{VGA_R, VGA_G, VGA_B} = {8'h00, 8'h00, 8'h00};		// else draws the background using black colour
	end

endmodule
