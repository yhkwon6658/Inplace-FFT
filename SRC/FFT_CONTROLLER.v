module FFT_CONTROLER #(
    parameter radix = 2,
    parameter R = 5,
    parameter N = 32,
    parameter length = 32,
    parameter DATA_LENGTH = 256,
    parameter TWIDDLEFILE = "TWIDDLE.txt"
) (
    // SYSTEM I/O
    input i_clk,
    input i_rst,
    // UART CONTROLLER
    output reg o_tx_init,
    output reg [2*length-1:0] o_fft_data,
    output reg o_tx_valid,
    input i_tx_ready,
    // ROM
    output [9:0] o_rom_addr,
    input [2*length-1:0] i_rom_data
);
// Parameter, Reg, Wire
localparam ST_IDLE = 5'd0;
localparam ST_ROM_READ = 5'd1;
localparam ST_ROM_DATA_SETUP = 5'd2;
localparam ST_BANK_INIT = 5'd3;
localparam ST_MEMORY_WRITE = 5'd4;
localparam ST_BANK_CNT = 5'd5;
localparam ST_FFT_STEP1 = 5'd6;
localparam ST_FFT_STEP2 = 5'd7;
localparam ST_FFT_STEP3 = 5'd8;
localparam ST_FFT_STEP4 = 5'd9;
localparam ST_FFT_STEP5 = 5'd10;
localparam ST_FFT_STEP6 = 5'd11;
localparam ST_FFT_STEP7 = 5'd12;
localparam ST_FFT_STEP8 = 5'd13;
localparam ST_FFT_STEP9 = 5'd14;
localparam ST_FIND = 5'd15;
localparam ST_MEMORY_READ = 5'd16; 
localparam ST_DATA_SETUP = 5'd17;
localparam ST_DATA_SEND = 5'd18;
localparam ST_DONE = 5'd19;
localparam ST_WAIT = 5'd20;
localparam FFTNUM = N*R/radix;
//////// Memory bank0
reg [2*length-1:0] r_m0_data;
reg [R-2:0] r_m0_addr;
reg r_m0_w_en;
wire [2*length-1:0] w_m0_out;
//////// Memory bank1
reg [2*length-1:0] r_m1_data;
reg [R-2:0] r_m1_addr;
reg r_m1_w_en;
wire [2*length-1:0] w_m1_out;
//////// Bank Init module
wire [9:0] w_rom_addr;
reg r_BI_en;
wire w_m0_w_en;
wire w_m1_w_en;
wire [R-2:0] w_bi_m0_addr;
wire [R-2:0] w_bi_m1_addr;
wire [2*length-1:0] w_bi_m0_data;
wire [2*length-1:0] w_bi_m1_data;
//////// Find Data module
reg r_FD_en;
wire w_m0_r_en;
wire w_m1_r_en;
wire [R-2:0] w_fd_m0_addr;
wire [R-2:0] w_fd_m1_addr;
//////// Butterfly
reg [length-1:0] r_cos_w0;
reg [length-1:0] r_sin_w0;
reg [length-1:0] r_cos_w1;
reg [length-1:0] r_sin_w1;
reg [length-1:0] r_cos_twiddle;
reg [length-1:0] r_sin_twiddle;
wire [2*length-1:0] w_wing0;
wire [2*length-1:0] w_wing1;
//////// Twiddle Table
reg [R-2:0] r_exponent_twiddle;
wire [length-1:0] w_cos_twiddle;
wire [length-1:0] w_sin_twiddle;
//////// ADDRgen
reg r_addr_twiddle_en;
wire w_sel_wing;
wire [R-2:0] w_fft_addr_m0;
wire [R-2:0] w_fft_addr_m1;
//////// Exponentgen
wire [R-2:0] w_exponent_twiddle;
//////// Control Flag
reg [4:0] r_ps;
reg [9:0] r_rom_addr_init;
reg [9:0] r_bank_cnt;
reg [9:0] r_tx_cnt;
reg [9:0] r_fft_cnt;
reg [5:0] r_butterfly_cnt;
reg r_sel_mem;
// Internal Connection
MEMORYBANK #(
    .length(length),
    .R(R)
) unit_m0(
    .i_w_en(r_m0_w_en),
    .i_addr(r_m0_addr),
    .i_data(r_m0_data),
    .o_data(w_m0_out),
    .i_clk(i_clk),
    .i_rst(i_rst)
);
MEMORYBANK #(
    .length(length),
    .R(R)
) unit_m1(
    .i_w_en(r_m1_w_en),
    .i_addr(r_m1_addr),
    .i_data(r_m1_data),
    .o_data(w_m1_out),
    .i_clk(i_clk),
    .i_rst(i_rst)
);
BANK_INIT #(
    .length(length),
    .R(R),
    .DATA_LENGTH(DATA_LENGTH)
) unit_BI(
    // SYSTEM I/O
    .i_clk(i_clk),
    .i_rst(i_rst),
    // FFT CONTROLLER
    .i_BI_en(r_BI_en),
    // ROM
    .i_rom_data(i_rom_data),
    .o_rom_addr(w_rom_addr),
    // memory bank0
    .o_m0_data(w_bi_m0_data),
    .o_m0_addr(w_bi_m0_addr),
    .o_m0_w_en(w_m0_w_en),
    // memory bank1
    .o_m1_data(w_bi_m1_data),
    .o_m1_addr(w_bi_m1_addr),
    .o_m1_w_en(w_m1_w_en)
);
butterfly #(
    .length(length)
)unit_butterfly(
    .i_clk(i_clk),
    .i_cos_w0(r_cos_w0), 
    .i_sin_w0(r_sin_w0), 
    .i_cos_w1(r_cos_w1), 
    .i_sin_w1(r_sin_w1),
    .i_cos_twiddle(r_cos_twiddle),
    .i_sin_twiddle(r_sin_twiddle),
    .o_w0(w_wing0), 
    .o_w1(w_wing1) 
);
Twiddlegen #(
    .length(length),
    .R(R),
    .N(N),
    .TWIDDLEFILE(TWIDDLEFILE)
)unit_Twiddlegen(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_twiddle_exponent(r_exponent_twiddle),
    .o_twiddle_cos(w_cos_twiddle),
    .o_twiddle_sin(w_sin_twiddle)
);
ADDRgen #(
    .R(R),
    .N(N)
)unit_ADDRgen(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_en(r_addr_twiddle_en),
    .o_sel_wing(w_sel_wing),
    .o_a0(w_fft_addr_m0),  //m0 bank address
    .o_a1(w_fft_addr_m1)   //m1 bank address
);
Exponentgen #(
    .R(R),
    .N(N)
)unit_Exponentgen(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_en(r_addr_twiddle_en),
    .o_exponent(w_exponent_twiddle)
);
Find_Data #(
    .N(N),
    .R(R)
) unit_FD(
    // SYSTEM I/O
    .i_clk(i_clk),
    .i_rst(i_rst),
    // FFT CONTROLLER
    .i_tx_valid(o_tx_valid),
    .i_FD_en(r_FD_en),
    .o_m0_r_en(w_m0_r_en),
    .o_m1_r_en(w_m1_r_en),
    // memory bank0
    .o_m0_addr(w_fd_m0_addr),
    // memory bank1
    .o_m1_addr(w_fd_m1_addr)
);
// Sequential Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        // STATE
        r_ps <= ST_IDLE;
        // Control flag
        r_rom_addr_init <= 0;
        r_bank_cnt <= 0;
        r_tx_cnt <= 0;
        r_fft_cnt <= 0;
        r_butterfly_cnt <= 0;
        r_sel_mem <= 0;
        // Memory bank
        r_m0_data <= 0;
        r_m0_addr <= 0;
        r_m0_w_en <= 0;
        r_m1_data <= 0;
        r_m1_addr <= 0;
        r_m1_w_en <= 0;
        // Bank Init module
        r_BI_en <= 0;
        // Find Data module
        r_FD_en <= 0;
        // UART CONTROLLER
        o_tx_init <= 0;
        o_fft_data <= 0;
        o_tx_valid <= 0;
        // Butterfly
        r_cos_w0 <= 0;
        r_sin_w0 <= 0;
        r_cos_w1 <= 0;
        r_sin_w1 <= 0;
        r_cos_twiddle <= 0;
        r_sin_twiddle <= 0;
        // Twiddle Table
        r_exponent_twiddle <= 0;
        // ADDRgen\Twiddlegen
        r_addr_twiddle_en <= 0;
    end
    else begin
        case (r_ps)
           ST_IDLE :
           begin
            if(i_tx_ready) begin
                if(o_tx_init) r_ps <= ST_BANK_INIT;
                else r_ps <= ST_ROM_READ;
                end
            else r_ps <= ST_IDLE;
           end
           ST_ROM_READ :
           begin
            r_ps <= ST_ROM_DATA_SETUP;
           end
           ST_ROM_DATA_SETUP :
           begin
                r_ps <= ST_DATA_SEND;
                o_tx_valid <= 1'b1;
                o_fft_data <= i_rom_data;
                r_rom_addr_init <= r_rom_addr_init + 1'b1;
           end
           ST_BANK_INIT :
           begin
            if(w_m0_w_en) begin
                r_ps <= ST_MEMORY_WRITE;
                r_BI_en <= 0;
                r_m0_data <= w_bi_m0_data;
                r_m0_addr <= w_bi_m0_addr;
                r_m0_w_en <= 1'b1;
            end
            else if(w_m1_w_en) begin
                r_ps <= ST_MEMORY_WRITE;
                r_BI_en <= 0;
                r_m1_data <= w_bi_m1_data;
                r_m1_addr <= w_bi_m1_addr;
                r_m1_w_en <= 1'b1;
            end
            else begin
                r_ps <= ST_BANK_INIT;
                r_BI_en <= 1'b1;
            end
           end
           ST_MEMORY_WRITE : 
           begin
            r_ps <= ST_BANK_CNT;
            r_m0_w_en <= 0;
            r_m1_w_en <= 0;
           end
           ST_BANK_CNT :
           begin
            if (r_bank_cnt == N-1) begin
                r_ps <= ST_FFT_STEP1;
                r_bank_cnt <= 0;
            end
            else begin
                r_ps <= ST_BANK_INIT;
                r_bank_cnt <= r_bank_cnt + 1'b1;
            end
           end
           ST_FFT_STEP1 :
           begin
            r_ps <= ST_FFT_STEP2;
            r_addr_twiddle_en <= 1;
           end
           ST_FFT_STEP2 :
           begin
            r_ps <= ST_FFT_STEP3;
            r_addr_twiddle_en <= 0;
           end
           ST_FFT_STEP3 :
           begin
            r_ps <= ST_FFT_STEP4;
           end
           ST_FFT_STEP4 :
           begin
            r_ps <= ST_FFT_STEP5;
            r_m0_addr <= w_fft_addr_m0;
            r_m1_addr <= w_fft_addr_m1;
            r_exponent_twiddle <= w_exponent_twiddle;
           end
           ST_FFT_STEP5 :
           begin
            r_ps <= ST_FFT_STEP6;
           end
           ST_FFT_STEP6 :
           begin
            if(&r_butterfly_cnt) begin
                r_ps <= ST_FFT_STEP7;
                r_butterfly_cnt <= 0;
            end
            else begin
                r_butterfly_cnt <= r_butterfly_cnt + 1;
                r_cos_twiddle <= w_cos_twiddle;
                r_sin_twiddle <= w_sin_twiddle;
                if(!w_sel_wing) begin
                    r_cos_w0 <= w_m0_out[2*length-1:length];
                    r_sin_w0 <= w_m0_out[length-1:0];
                    r_cos_w1 <= w_m1_out[2*length-1:length];
                    r_sin_w1 <= w_m1_out[length-1:0]; 
                end
                else begin
                    r_cos_w0 <= w_m1_out[2*length-1:length];
                    r_sin_w0 <= w_m1_out[length-1:0];
                    r_cos_w1 <= w_m0_out[2*length-1:length];
                    r_sin_w1 <= w_m0_out[length-1:0];
                end
            end
           end
           ST_FFT_STEP7 :
           begin
            r_ps <= ST_FFT_STEP8;
            r_m0_w_en <= 1;
            r_m1_w_en <= 1;
            if(!w_sel_wing) begin
                r_m0_data <= w_wing0;
                r_m1_data <= w_wing1;
            end
            else begin
                r_m0_data <= w_wing1;
                r_m1_data <= w_wing0;
            end
           end
           ST_FFT_STEP8 :
           begin
            r_ps <= ST_FFT_STEP9;
            r_m1_w_en <= 0;
            r_m0_w_en <= 0;
           end
           ST_FFT_STEP9 :
           begin
            if(r_fft_cnt == FFTNUM-1) begin
                r_ps <= ST_FIND;
                r_fft_cnt <= 0;
            end
            else begin
                r_ps <= ST_FFT_STEP1;
                r_fft_cnt <= r_fft_cnt + 1;
            end
           end
           ST_FIND :
           begin
            if (w_m0_r_en) begin
                r_ps <= ST_MEMORY_READ;
                r_FD_en <= 0;
                r_m0_addr <= w_fd_m0_addr;
                r_sel_mem <= 0;
            end
            else if(w_m1_r_en) begin
                r_ps <= ST_MEMORY_READ;
                r_FD_en <= 0;
                r_m1_addr <= w_fd_m1_addr;
                r_sel_mem <= 1'b1;
            end
            else begin
                r_ps <= ST_FIND;
                r_FD_en <= 1'b1;
            end
           end
           ST_MEMORY_READ :
           begin
            r_ps <= ST_DATA_SETUP;
           end
           ST_DATA_SETUP :
           begin
            r_ps <= ST_DATA_SEND;
            o_tx_valid <= 1'b1;
            if(!r_sel_mem) o_fft_data <= w_m0_out;
            else o_fft_data <= w_m1_out;
           end
           ST_DATA_SEND :
           begin
            o_tx_valid <= 0;
            r_ps <= ST_DONE;
           end
           ST_DONE :
           begin
            if(!o_tx_init) begin
                r_ps <= ST_IDLE;
                if(r_rom_addr_init == DATA_LENGTH) o_tx_init <= 1'b1;
            end
            else begin
                if(r_tx_cnt == N-1) begin
                    r_ps <= ST_IDLE;
                    r_tx_cnt <= 0;
                end
                else begin
                    r_ps <= ST_WAIT;
                    r_tx_cnt <= r_tx_cnt + 1'b1;
                end
            end
           end
           ST_WAIT :
           begin
            if(i_tx_ready) r_ps <= ST_FIND;
            else r_ps <= ST_WAIT;
           end
            default: r_ps <= ST_IDLE; 
        endcase
    end
end
// Combinational logic
assign o_rom_addr = (o_tx_init) ? w_rom_addr : r_rom_addr_init;
endmodule