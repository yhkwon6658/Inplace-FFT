module barrel_shifter (
    input s,
    output w1, w0
);
    assign  w1 = s ? 1'b1 : 1'b0;
    assign  w0 = s ? 1'b0 : 1'b1;
endmodule