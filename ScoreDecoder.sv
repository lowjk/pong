// Name: Justin Low (jkl37)
//
// Pong Game - ScoreDecoder
//
// 6 Dec 2019
//
// This module decodes the score of a player into tens and ones, so that each
// digit can be displayed using the SevenSegmentDisplay module
module ScoreDecoder
#(
	oLeft = 10,				// x position of the number
	oTop = 10,				// y position of the number
	oHeight = 50,			// height of the number
	oWidth = 70,
	oGap = 10
)
(
	input  logic [6:0] score,
	input  logic [11:0] xPos,		// x position of hCounter
	input  logic [11:0] yPos,     // y position of vCounter
	output logic drawScore
);

	logic [3:0] scoreTens, scoreOnes;
	logic drawTens, drawOnes;

	parameter DigitWidth = oWidth/2 - oGap;
	parameter onesLeft = oLeft + DigitWidth + oGap;

	assign scoreTens = score / 10;
	assign scoreOnes = score % 10;
	assign drawScore = drawTens | drawOnes;

	SevenSegmentDisplay #(.oLeft(oLeft), .oTop(oTop), .oHeight(oHeight), .oWidth(DigitWidth)) TensDisplay
	(
		.scoreDigit(scoreTens),
		.xPos,
		.yPos,
		.drawDisplay(drawTens)
	);

	SevenSegmentDisplay #(.oLeft(onesLeft), .oTop(oTop), .oHeight(oHeight), .oWidth(DigitWidth)) OnesDisplay
	(
		.scoreDigit(scoreOnes),
		.xPos,
		.yPos,
		.drawDisplay(drawOnes)
	);

endmodule


// Displays a number on the screen in seven segments
module SevenSegmentDisplay
#(
	oLeft = 10,				// x position of the number
	oTop = 10,				// y position of the number
	oHeight = 50,			// height of the number
	oWidth = 30
)
(
	input  logic [3:0] scoreDigit,
	input  logic [11:0] xPos,		// x position of hCounter
	input  logic [11:0] yPos,     // y position of vCounter
	output logic drawDisplay
);
	//     a
	//  -------
	//  |     |
	// b|     |f
	//  |  g  |
	//  -------
	//  |     |
	// c|     |e
	//  |  d  |
	//  -------
	//
	logic a, b, c, d, e, f, g;

	logic [11:0] aSides[4];
	logic [11:0] bSides[4];
	logic [11:0] cSides[4];
	logic [11:0] dSides[4];
	logic [11:0] eSides[4];
	logic [11:0] fSides[4];
	logic [11:0] gSides[4];

	assign aSides[0] = oLeft;            // Left
	assign aSides[1] = oLeft + oWidth;   // Right
	assign aSides[2] = oTop;             // Top
	assign aSides[3] = oTop + oHeight/5; // Bottom

	assign bSides[0] = oLeft;
	assign bSides[1] = oLeft + oWidth/3;
	assign bSides[2] = oTop;
	assign bSides[3] = oTop + 3*oHeight/5;

	assign cSides[0] = oLeft;
	assign cSides[1] = oLeft + oWidth/3;
	assign cSides[2] = oTop + 2*oHeight/5;
	assign cSides[3] = oTop + oHeight;

	assign dSides[0] = oLeft;
	assign dSides[1] = oLeft + oWidth;
	assign dSides[2] = oTop + 4*oHeight/5;
	assign dSides[3] = oTop + oHeight;

	assign eSides[0] = oLeft + 2*oWidth/3;
	assign eSides[1] = oLeft + oWidth;
	assign eSides[2] = oTop + 2*oHeight/5;
	assign eSides[3] = oTop + oHeight;

	assign fSides[0] = oLeft + 2*oWidth/3;
	assign fSides[1] = oLeft + oWidth;
	assign fSides[2] = oTop;
	assign fSides[3] = oTop + 3*oHeight/5;

	assign gSides[0] = oLeft;
	assign gSides[1] = oLeft + oWidth;
	assign gSides[2] = oTop + 2*oHeight/5;
	assign gSides[3] = oTop + 3*oHeight/5;

	always_comb
	begin
		case (scoreDigit)
			4'd0: {a,b,c,d,e,f,g} = 7'b1111110;
			4'd1: {a,b,c,d,e,f,g} = 7'b0000110;
			4'd2: {a,b,c,d,e,f,g} = 7'b1011011;
			4'd3: {a,b,c,d,e,f,g} = 7'b1001111;
			4'd4: {a,b,c,d,e,f,g} = 7'b0100111;
			4'd5: {a,b,c,d,e,f,g} = 7'b1101101;
			4'd6: {a,b,c,d,e,f,g} = 7'b1111101;
			4'd7: {a,b,c,d,e,f,g} = 7'b1000110;
			4'd8: {a,b,c,d,e,f,g} = 7'b1111111;
			4'd9: {a,b,c,d,e,f,g} = 7'b1100111;
			default: {a,b,c,d,e,f,g} = 7'b0000000;
		endcase
	end

	assign drawDisplay = (((xPos >= aSides[0]) & (xPos < aSides[1]) & (yPos >= aSides[2]) & (yPos < aSides[3]) & (a == 1))
	                   |  ((xPos >= bSides[0]) & (xPos < bSides[1]) & (yPos >= bSides[2]) & (yPos < bSides[3]) & (b == 1))
				          |  ((xPos >= cSides[0]) & (xPos < cSides[1]) & (yPos >= cSides[2]) & (yPos < cSides[3]) & (c == 1))
				          |  ((xPos >= dSides[0]) & (xPos < dSides[1]) & (yPos >= dSides[2]) & (yPos < dSides[3]) & (d == 1))
				          |  ((xPos >= eSides[0]) & (xPos < eSides[1]) & (yPos >= eSides[2]) & (yPos < eSides[3]) & (e == 1))
				          |  ((xPos >= fSides[0]) & (xPos < fSides[1]) & (yPos >= fSides[2]) & (yPos < fSides[3]) & (f == 1))
				          |  ((xPos >= gSides[0]) & (xPos < gSides[1]) & (yPos >= gSides[2]) & (yPos < gSides[3]) & (g == 1))) ? 1 : 0;

endmodule
