// Name: Justin Low (jkl37)
//
// Tutorial session 10
// VGA controller
// 
// 03 December 2019

module VgaController
(
	input  logic        Clock,
	input  logic        Reset,
	output logic        blank_n,
	output logic        sync_n,
	output logic        hSync_n,
	output logic        vSync_n,
	output logic [11:0] nextX,
	output logic [11:0] nextY
);

	// use this signal as counter for the horizontal axis
	logic [11:0] hCount;

	// use this signal as counter for the vertical axis
	logic [11:0] vCount;

	always_ff @ (posedge Clock)
	begin
		hCount <= (Reset | hCount >= 1040) ? '0 : hCount + 1;

		if (Reset | vCount >= 666)
			vCount <= '0;
		else if (hCount >= 1040)
			vCount <= vCount + 1;
		else
			vCount <= vCount;
	end

	always_comb
	begin
		nextX = (hCount < 800 & vCount < 600) ? hCount : '0;
		nextY = (hCount < 800 & vCount < 600) ? vCount : '0;
		hSync_n = (hCount >= 856 & hCount < 976) ? 0 : 1;
		vSync_n = (vCount >= 637 & vCount < 643) ? 0 : 1;
		blank_n = (hCount >= 800 | vCount >= 600) ? 0 : 1;
		sync_n = (~hSync_n & ~vSync_n) ? 0 : 1;
	end


endmodule
