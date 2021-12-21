// Name: Justin Low (jkl37)
// 
// SLOW CLOCK module
//
// Uriel Martinez-Hernandez
// Univesity of Bath
//
//

module slowClock #(parameter N = 20)
(
	input	 logic	Clock,
	input  logic	Reset,
	output logic	Enable
);

	logic [N-1:0] Count;

	always_ff @(posedge Clock, posedge Reset)
	begin
		if( Reset )
			begin
				Count <= 0;
				Enable <= 0;
			end
		else
			begin
				Count <= Count + 1;
				Enable <= ~| Count;
			end
	end

endmodule
