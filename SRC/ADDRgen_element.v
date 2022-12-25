module ADDRgen_element #(
    parameter i = 0,
    parameter R = 5
) (
    input i_b1,   //b_i
    input i_b0,   //b_(i-1)
    input [3:0] i_c,
    input i_s,    // barrel shifter s
    output o_a0,  //m0 bank address
    output o_a1   //m1 bank address
);
// wire
wire w_wsel;
wire w_bsel;
wire w_b;
wire w_w1, w_w0;
// Combinational Logic
assign w_wsel = (i_c == R-1-i) ? 1 : 0;     // wMUX sel signal, 1 -> select W, 0 -> select b
assign w_bsel = (i_c < R-1-i) ? 1 : 0;      // bMUX sel signal, 1 -> b_i, 0 -> b_(i-1)
// Internal Connection
barrel_shifter u_barrel_shifter(
    .s(i_s),
    .w1(w_w1),
    .w0(w_w0)
);
bwMUX bMUX(
    .in1(i_b1),
    .in2(i_b0),
    .sel(w_bsel),
    .out(w_b)
);
bwMUX wMUX0(
    .in1(w_w0),
    .in2(w_b),
    .sel(w_wsel),
    .out(o_a0)
);
bwMUX wMUX1(
    .in1(w_w1),
    .in2(w_b),
    .sel(w_wsel),
    .out(o_a1)
);
endmodule