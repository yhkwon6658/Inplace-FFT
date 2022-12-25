module BANK_INIT #(
    parameter length = 32,
    parameter R = 5,
    parameter DATA_LENGTH = 256
) (
    // SYSTEM I/O
    input i_clk,
    input i_rst,
    // FFT CONTROLLER
    input i_BI_en,
    // ROM
    input [2*length-1:0] i_rom_data,
    output reg [9:0] o_rom_addr,
    // memory bank0
    output reg [R-2:0] o_m0_addr,
    output reg [2*length-1:0] o_m0_data,
    output reg o_m0_w_en,
    // memory bank1
    output reg [R-2:0] o_m1_addr,
    output reg [2*length-1:0] o_m1_data,
    output reg o_m1_w_en
);
// parameter, reg, wire
localparam ST_IDLE = 0;
localparam ST_ROM_ADDR_OUT = 1;
localparam ST_ROM_DATA_IN = 2;
localparam ST_MEMORY_ADDR_OUT = 3;
localparam ST_MEMORY_WRITE = 4;
localparam ST_DONE = 5;

reg [2:0] r_ps;
reg [R-1:0] r_cnt;

// Sequential Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        o_rom_addr <= 0;
        o_m0_data <= 0;
        o_m0_addr <= 0;
        o_m0_w_en <= 0;
        o_m1_data <= 0;
        o_m1_addr <= 0;
        o_m1_w_en <= 0;
        r_cnt <= 0;
        r_ps <= ST_IDLE;
    end
    else begin
        case (r_ps)
           ST_IDLE :
           begin
            if(i_BI_en) r_ps <= ST_ROM_ADDR_OUT;
           end
           ST_ROM_ADDR_OUT :
           begin
            r_ps <= ST_ROM_DATA_IN;
           end
           ST_ROM_DATA_IN :
           begin
            r_ps <= ST_MEMORY_ADDR_OUT;
           end
           ST_MEMORY_ADDR_OUT :
           begin
            if(^r_cnt) begin
                r_ps <= ST_MEMORY_WRITE;
                o_m1_w_en <= 1;
                o_m1_addr <= r_cnt[R-2:0];
                o_m1_data <= i_rom_data;
            end
            else begin
                r_ps <= ST_MEMORY_WRITE;
                o_m0_w_en <= 1;
                o_m0_addr <= r_cnt[R-2:0];
                o_m0_data <= i_rom_data;
            end
           end
           ST_MEMORY_WRITE :
           begin
            r_ps <= ST_DONE;
            r_cnt <= r_cnt + 1'b1;
            o_m1_w_en <= 0;
            o_m0_w_en <= 0;
           end
           ST_DONE :
           begin
            r_ps <= ST_IDLE;
            if(o_rom_addr == DATA_LENGTH-1) o_rom_addr <= 0;
            else o_rom_addr <= o_rom_addr + 1'b1;
           end 
            default: r_ps <= ST_IDLE; 
        endcase
    end
end

endmodule