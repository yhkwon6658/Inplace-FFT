module ADDRgen #(
    parameter R = 5,
    parameter N = 32
) (
    input i_clk,
    input i_rst,
    input i_en,
    output reg o_sel_wing,
    output reg [R-2:0] o_a0,  //m0 bank address
    output reg [R-2:0] o_a1   //m1 bank address
);
// parameter, reg, wire
localparam s_0 = 2'b00; // IDLE
localparam s_1 = 2'b01; // RUN
localparam s_2 = 2'b10;
reg [1:0] r_ps; // present state
reg [R-2:0] r_bcnt;
reg [3:0] r_ccnt;
wire [R-2:0] w_a0;
wire [R-2:0] w_a1;
// Internal Connection
ADDRgen_element #(.i(0), .R(5)) ADDRgen_element_a0(
.i_b1(r_bcnt[0]),
.i_b0(1'b0),
.i_c(r_ccnt),
.i_s(^r_bcnt),
.o_a0(w_a0[0]),
.o_a1(w_a1[0]) 
);
ADDRgen_element #(.i(1), .R(5)) ADDRgen_element_a1(
.i_b1(r_bcnt[1]),
.i_b0(r_bcnt[0]),
.i_c(r_ccnt),
.i_s(^r_bcnt),
.o_a0(w_a0[1]),
.o_a1(w_a1[1]) 
);
ADDRgen_element #(.i(2), .R(5)) ADDRgen_element_a2(
.i_b1(r_bcnt[2]),
.i_b0(r_bcnt[1]),
.i_c(r_ccnt),
.i_s(^r_bcnt),
.o_a0(w_a0[2]),
.o_a1(w_a1[2]) 
);
ADDRgen_element #(.i(3), .R(5)) ADDRgen_element_a3(
.i_b1(r_bcnt[3]),
.i_b0(r_bcnt[2]),
.i_c(r_ccnt),
.i_s(^r_bcnt),
.o_a0(w_a0[3]),
.o_a1(w_a1[3]) 
);
// Sequntial Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        o_a0 <= 0;
        o_a1 <= 0;
        r_ps <= s_0;
        r_bcnt <= 0;
        r_ccnt <= 0;
        o_sel_wing <= 0;
    end
    else begin
        case (r_ps)
            s_0 : 
            begin
                if(i_en) r_ps <= s_1;
                else r_ps <= s_0;
            end
            s_1 :
            begin
                r_ps <= s_2;
                o_a0 <= w_a1;
                o_a1 <= w_a0;
                o_sel_wing <= ^r_bcnt;
                if(r_bcnt == N/2-1) begin
                    if(r_ccnt == R-1) begin
                        r_bcnt <= 0;
                        r_ccnt <= 0;
                    end
                    else begin
                        r_bcnt <= 0;
                        r_ccnt <= r_ccnt + 1;
                    end
                end
                else r_bcnt <= r_bcnt + 1;
            end
            s_2 :
            begin
                r_ps <= s_0;
            end
        endcase
    end
end
endmodule