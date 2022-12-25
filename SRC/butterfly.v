module butterfly #(
    parameter length = 32
)(
    input i_clk,
    input [length-1:0] i_cos_w0, 
    input [length-1:0] i_sin_w0, 
    input [length-1:0] i_cos_w1, 
    input [length-1:0] i_sin_w1,
    input [length-1:0] i_cos_twiddle,
    input [length-1:0] i_sin_twiddle,
    output [2*length-1:0] o_w0, 
    output [2*length-1:0] o_w1 
);
// Parameter, Reg, Wire
wire [length-1:0] w0_cos_add;
wire [length-1:0] w0_sin_add;
wire [length-1:0] w1_cos_sub;
wire [length-1:0] w1_sin_sub;
wire [length-1:0] w1_r1;
wire [length-1:0] w1_r2;
wire [length-1:0] w1_r;
wire [length-1:0] w1_i1;
wire [length-1:0] w1_i2;
wire [length-1:0] w1_i;
// Internal Connection
    ////////////////////////////// Wing0 //////////////////////////////
    FPADD2 unit_add1(
        .clock(i_clk),
        .dataa(i_cos_w0),
        .datab(i_cos_w1),
        .result(w0_cos_add)
    ); // Real value of Wing0
    FPADD2 unit_add2(
        .clock(i_clk),
        .dataa(i_sin_w0),
        .datab(i_sin_w1),
        .result(w0_sin_add)
    ); // Imaginary value of Wing0
    ////////////////////////////// Wing1 //////////////////////////////
    FPSUB2 unit_sub1(
        .clock(i_clk),
        .dataa(i_cos_w0),
        .datab(i_cos_w1),
        .result(w1_cos_sub)
    );
    FPSUB2 unit_sub2(
        .clock(i_clk),
        .dataa(i_sin_w0),
        .datab(i_sin_w1),
        .result(w1_sin_sub)
    );
    FPMUL2 unit_mul1(
        .clock(i_clk),
        .dataa(w1_cos_sub),
        .datab(i_cos_twiddle),
        .result(w1_r1)
    );
    FPMUL2 unit_mul2(
        .clock(i_clk),
        .dataa(w1_sin_sub),
        .datab(i_sin_twiddle),
        .result(w1_r2)
    );
    FPSUB2 unit_sub3(
        .clock(i_clk),
        .dataa(w1_r1),
        .datab(w1_r2),
        .result(w1_r)
    ); // Real value of Wing1
    FPMUL2 unit_mul3(
        .clock(i_clk),
        .dataa(w1_cos_sub),
        .datab(i_sin_twiddle),
        .result(w1_i1)
    );
    FPMUL2 unit_mul4(
        .clock(i_clk),
        .dataa(w1_sin_sub),
        .datab(i_cos_twiddle),
        .result(w1_i2)
    );
    FPADD2 unit_add3(
        .clock(i_clk),
        .dataa(w1_i1),
        .datab(w1_i2),
        .result(w1_i)
    ); // Imaginary value of Wing1
// Combinational Logic
    assign o_w0[2*length-1:length] = w0_cos_add;
    assign o_w0[length-1:0] = w0_sin_add;
    assign o_w1[2*length-1:length] = w1_r;
    assign o_w1[length-1:0] = w1_i;
endmodule