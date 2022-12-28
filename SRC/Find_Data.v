module Find_Data #(
    parameter N = 32,
    parameter R = 5
) (
    // SYSTEM I/O
    input i_clk,
    input i_rst,
    // FFT CONTROLLER
    input i_tx_valid,
    input i_FD_en,
    output reg o_m0_r_en,
    output reg o_m1_r_en,
    // memory bank0
    output reg [R-2:0] o_m0_addr,
    // memory bank1
    output reg [R-2:0] o_m1_addr
);
// parameter, reg, wire
localparam ST_IDLE = 3'd0;
localparam ST_MEMORY_ADDR_OUT = 3'd1;
localparam ST_MEMORY_READ = 3'd2;
localparam ST_TX_EN = 3'd3;
localparam ST_WAIT = 3'd4;
localparam ST_DONE = 3'd5;
reg [2:0] r_ps;
reg [R-1:0] r_cnt;
wire [R-1:0] w_cnt;
// Internal Connection
bitReverse #(R) Unit_bitReverse(r_cnt,w_cnt);
// Sequential Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        o_m0_addr <= 0;
        o_m1_addr <= 0;
        o_m0_r_en <= 0;
        o_m1_r_en <= 0;
        r_ps <= ST_IDLE;
        r_cnt <= 0;
    end
    else begin
        case (r_ps)
           ST_IDLE :
           begin
            if(i_FD_en) r_ps <= ST_MEMORY_ADDR_OUT;
           end
           ST_MEMORY_ADDR_OUT :
           begin
            if(^w_cnt) begin
                r_ps <= ST_MEMORY_READ;
                o_m1_addr <= w_cnt[R-2:0];
                o_m1_r_en <= 1'b1;
            end
            else begin
                r_ps <= ST_MEMORY_READ;
                o_m0_addr <= w_cnt[R-2:0];
                o_m0_r_en <= 1'b1;
            end
           end
           ST_MEMORY_READ :
           begin
            r_ps <= ST_TX_EN;
            o_m1_r_en <= 0;
            o_m0_r_en <= 0;
           end
           ST_TX_EN :
           begin
            r_ps <= ST_WAIT;
            if(r_cnt == N-1) r_cnt <= 0;
            else r_cnt <= r_cnt + 1'b1;
           end
           ST_WAIT :
           begin
            if(i_tx_valid) r_ps <= ST_DONE;
            else r_ps <= ST_WAIT;
           end
           ST_DONE :
           begin
            r_ps <= ST_IDLE;
           end 
            default: r_ps <= ST_IDLE; 
        endcase
    end
end
endmodule

module bitReverse #(
    parameter R = 5
) (
    input [R-1:0] i_addr,
    output reg [R-1:0] o_addr
);
reg [R-1:0] r_addr;
integer i;
always @(*)
begin
    for(i=0;i<R;i=i+1)
    begin
        if(i==0)
        begin
            o_addr = 0;
            r_addr = i_addr;       
        end
        o_addr = o_addr << 1;
        if(r_addr[0]) o_addr = o_addr + 1'b1;
        r_addr = r_addr >> 1;
    end
end
    
endmodule