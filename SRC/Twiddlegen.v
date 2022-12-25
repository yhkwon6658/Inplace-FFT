module Twiddlegen #(
    parameter length = 32,
    parameter R = 5,
    parameter N = 32,
    parameter TWIDDLEFILE = "TWIDDLE.txt"
)(
    input i_clk,
    input i_rst,
    input [R-2:0] i_twiddle_exponent,
    output reg [length-1:0] o_twiddle_cos,
    output reg [length-1:0] o_twiddle_sin
);
reg [2*length-1:0] TWROM [0:N/2-1];
initial $readmemh(TWIDDLEFILE,TWROM);
always @(posedge i_clk) begin
    if(i_rst) begin
        o_twiddle_cos <= 0;
        o_twiddle_sin <= 0;
    end
    else begin
        o_twiddle_cos <= TWROM[i_twiddle_exponent][2*length-1:length];
        o_twiddle_sin <= TWROM[i_twiddle_exponent][length-1:0];
    end
end    
endmodule