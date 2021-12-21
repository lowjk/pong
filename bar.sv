// Name: Justin Low (jkl37)
//
// Pong Game - bar module
//
// Uriel Martinez-Hernandez
// Univesity of Bath
// November 2019
//
// This module controls movement of the bar in the Pong game.
// The bar moves up and down depending on the key press on the FPGA,
// but stops when it hits the top and bottom wall.


module bar
#(									// default values
	oLeft = 10,					// x position of the bar
	oTop = 10,					// y position of the bar
	oHeight = 50,				// height of the bar
	oWidth = 20,				// width of the bar
	sWidth = 800,				// width of the screen
	sHeight = 600				// height of the screen
)
(
	input Clock,				// Clock of 50MHz
	input PixelClock,			// slow clock to display pixels
	input Reset,				// reset position of the bar
	input [1:0] Button,
	input  logic [11:0] xPos,	// x position of hCounter
	input  logic [11:0] yPos,	// y position of vCounter
	output logic drawBar,		// activates/deactivates drawing
	output logic [10:0] barEdges[4] // 4-bit array of 10 bit variables outputting
	                                // the coordinates of the bar
										     // barEdges[0:3] = left, right, top, bottom
);

	logic [10:0] left;
	logic [10:0] right;
	logic [10:0] top;
	logic [10:0] bottom;

	logic [10:0] rectX = oLeft;
	logic [10:0] rectY = oTop;


	// coordinates of the bar
	assign left = rectX;
	assign right = rectX + oWidth - 1;
	assign top = rectY;
	assign bottom = rectY + oHeight - 1;


	always_ff @(posedge Clock)
	begin
		if( Reset == 1 )			// This is compared at 50MHz
			begin
				rectX <= oLeft;	// if Reset is 1 then
				rectY <= oTop;		// x and y positions of the bar
			end						// are set to the original values

		if( PixelClock == 1 )	// Slow clock that allows the
			begin						// user to see the bar movements
										// when the push buttons are pressed

				if (Button[0] ~^ Button[1])    // Bar doesn't move
					rectY <= rectY;
				else if (Button[0]) // Bar moves up unless it's reached the top of the screen
					rectY <= (top <= 1) ? rectY : rectY - 1;
				else                // Bar moves down unless it's reached the bottom of the screen
					rectY <= (bottom >= sHeight-1) ? rectY : rectY + 1;

			end
	end

	// drawBar is 1 if the screen counters (hCount and vCount) are in the area of the bar
	// otherwise, drawBar is 0 and the bar is not drawn.
	// drawBar is used by the top module PongGame
	assign drawBar = ((xPos >= left) & (yPos >= top) & (xPos <= right) & (yPos <= bottom)) ? 1 : 0;
	assign barEdges[0] = left;
	assign barEdges[1] = right;
	assign barEdges[2] = top;
	assign barEdges[3] = bottom;

endmodule
