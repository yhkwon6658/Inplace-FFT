module Exponentgen #(	
    parameter R=5,
    parameter N=32
)(
    input i_clk,
	input i_rst,
	input i_en,
    output reg [R-2:0] o_exponent
);
// Parameter, Wire, Reg
localparam s_0=2'b00;
localparam s_1=2'b01;
localparam s_2=2'b10;
reg [R-2:0] i_b;
reg [3:0] i_c;
reg [1:0] r_ps;
wire [R-2:0] w_exponent;
// Internal Connection
left_shift #(
	.R(R)
) left_shifter (
	.in_b(i_b),
	.in_c(i_c),
	.exp_w1(w_exponent)
);
// Sequntial Logic
always @(posedge i_clk) begin
	if(i_rst) begin
		r_ps <= s_0;
		i_c <= 0;
		i_b <= 0;
		o_exponent <= 0;
	end
	else begin
		case(r_ps)
			s_0:
			begin
				if(i_en) r_ps<=s_1;
				else r_ps<=s_0;
			end
			s_1:
			begin
				r_ps<=s_2;
				o_exponent <= w_exponent;
				if(i_b==N/2-1) begin
					if(i_c==R-1) begin
						i_b<=0;
						i_c<=0;
					end
					else begin
						i_b<=0;
						i_c<=i_c+1;
					end
				end
				else i_b<=i_b+1;
		    end
			s_2:
			begin
				r_ps<=s_0;
			end
    	endcase
    end
end
endmodule