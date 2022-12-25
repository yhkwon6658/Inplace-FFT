module left_shift #(
    parameter R = 5
)
(
    input [R-2:0] in_b,
    input [3:0] in_c,
    output reg[R-2:0] exp_w1
);
always @(*) begin
    exp_w1<= (in_b<<in_c);
end
endmodule