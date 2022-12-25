module UART_CONTROLLER #(
    parameter length = 32,
    parameter CLKS_PER_BIT = 434, // 50Mhz/115200
    parameter SIG_RUN = 82,
    parameter SIG_STOP = 83,
    parameter DATA_LENGTH = 256
) (
    // SYSTEM I/O
    input i_clk, // CLOCK_50
    input i_rst, // SW[0]
    input i_rxd,
    output o_txd,
    // FFT Controller
    input [2*length-1:0] i_fft_data,
    input i_tx_valid,
    output reg o_tx_ready // 1 trig
);
// Parameter, Wire, Reg
localparam ST_IDLE = 2'd0;
localparam ST_SEND = 2'd1;
localparam ST_SHIFT = 2'd2;
localparam ST_FFT = 2'd3;
wire w_Rx_DV;
wire [7:0] w_Rx_Byte;
wire w_Tx_Done;
reg r_Tx_DV;
reg [7:0] r_Tx_Byte;
reg [9:0] r_cnt_tx;
reg [2*length-1:0] r_uart_data_tx_shift;
reg [3:0] r_cnt_data;
reg [1:0] r_ps;
// Internal Connection
uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx
  (
   .i_Clock(i_clk),
   .i_Rx_Serial(i_rxd),
   .o_Rx_DV(w_Rx_DV),
   .o_Rx_Byte(w_Rx_Byte)
   );
uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx
   (
    .i_Clock(i_clk),
    .i_Tx_DV(r_Tx_DV),
    .i_Tx_Byte(r_Tx_Byte),
    .o_Tx_Active(),
    .o_Tx_Serial(o_txd),
    .o_Tx_Done(w_Tx_Done)
    );
// Sequential Logic
always @(posedge i_clk) begin
    if(i_rst) begin
        r_ps <= ST_IDLE;
        r_Tx_DV <= 0;
        r_Tx_Byte <= 0;
        r_cnt_tx <= 0;
        r_cnt_data <= 0;
        o_tx_ready <= 0;
    end
    else begin
        case (r_ps)
           ST_IDLE :
           begin
            if(w_Rx_DV) begin
                if(w_Rx_Byte == SIG_STOP) r_ps <= ST_IDLE;
                else if(w_Rx_Byte == SIG_RUN) begin
                    if(r_cnt_tx < DATA_LENGTH) begin
                        r_ps <= ST_FFT;
                        o_tx_ready <= 1;
                    end
                    else begin
                        r_ps <= ST_IDLE;
                        r_cnt_tx <= 0;
                    end
                end
            end
            else r_ps <= ST_IDLE;
           end
           ST_SEND :
           begin
            if(r_cnt_data > 7) begin
                r_ps <= ST_IDLE;
                r_cnt_data <= 0;
                r_Tx_DV <= 0;
                r_cnt_tx <= r_cnt_tx + 1'b1;
            end
            else begin
                r_ps <= ST_SHIFT;
                r_Tx_DV <= 1;
                r_Tx_Byte <= r_uart_data_tx_shift[63:56];
                r_cnt_data <= r_cnt_data + 1'b1;
            end
           end
           ST_SHIFT :
           begin
            if(w_Tx_Done) begin
                r_ps <= ST_SEND;
                r_uart_data_tx_shift <= (r_uart_data_tx_shift<<8);
            end
            else begin
                r_ps <= ST_SHIFT;
                r_Tx_DV <= 0;
            end
           end
           ST_FFT :
           begin
            if(i_tx_valid) begin
                o_tx_ready <= 0;
                r_ps <= ST_SEND;
                r_uart_data_tx_shift <= i_fft_data;
            end
            else r_ps <= ST_FFT; // at Second Run, first time o_ready_tx doesn't make i_tx_valid high at first Loop
           end
            default: r_ps <= ST_IDLE; 
        endcase
    end
end
endmodule