module MEMORYBANK #(
    parameter length = 32,
    parameter R = 5
) (
    output reg [2*length-1:0] o_data,
    input [2*length-1:0] i_data,
    input [R-2:0] i_addr,
    input i_w_en,
    input i_clk,
    input i_rst
);
integer I;
localparam ADDR_LENGTH = 2**(R-1);
reg [2*length-1:0] RAM [0:ADDR_LENGTH-1];
always @(posedge i_clk) begin
    if(i_rst) begin
        for(I=0;I<ADDR_LENGTH;I=I+1) begin
            RAM[I] <= 0;
        end
    end
    else begin
        if(i_w_en) RAM[i_addr] <= i_data;
        else o_data <= RAM[i_addr];
    end
end
endmodule