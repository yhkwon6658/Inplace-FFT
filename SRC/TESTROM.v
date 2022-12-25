module TESTROM #(
    parameter length = 32,
    parameter DATA_LENGTH = 256,
    parameter ROMFILE = "TESTDATA.txt"
)(
    input i_clk,
    input [9:0] i_addr,
    output reg [2*length-1:0] o_data
);
reg [2*length-1:0] mem [0:DATA_LENGTH-1];
initial begin
    $readmemh(ROMFILE,mem);
end
always @(posedge i_clk) begin
    o_data <= mem[i_addr];
end
endmodule
