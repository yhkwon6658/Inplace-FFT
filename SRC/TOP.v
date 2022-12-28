module TOP #(
    parameter CLKS_PER_BIT = 434,
    parameter SIG_RUN = 82,
    parameter SIG_STOP = 83,
    parameter DATA_LENGTH = 256,
    parameter R = 5,
    parameter N = 32,
    parameter radix = 2,
    parameter length = 32,
    parameter ROMFILE = "TESTDATA.txt",
    parameter TWIDDLEFILE = "TWIDDLE.txt"
) (
    output o_tx_init,
    // SYSTEM I/O
    input i_clk,
    input i_rst,
    input i_rxd,
    output o_txd
);
// Parameter, Wire, Reg
wire [9:0] w_rom_addr;
wire [2*length-1:0] w_rom_data;
wire [2*length-1:0] w_fft_data;
wire w_tx_valid;
wire w_tx_ready;
// Internal Connection
TESTROM #(
    .length(length),
    .ROMFILE(ROMFILE),
    .DATA_LENGTH(DATA_LENGTH)
)unit_TESTROM(
    .i_clk(i_clk),
    .i_addr(w_rom_addr),
    .o_data(w_rom_data)
);
UART_CONTROLLER #(
    .length(length),
    .CLKS_PER_BIT(CLKS_PER_BIT), // 50Mhz/115200
    .SIG_RUN(SIG_RUN),
    .SIG_STOP(SIG_STOP),
    .DATA_LENGTH(DATA_LENGTH)
) unit_UART_CONTROLLER(
    // SYSTEM I/O
    .i_clk(i_clk), // CLOCK_50
    .i_rst(i_rst), // SW[0]
    .i_rxd(i_rxd),
    .o_txd(o_txd),
    // FFT Controller
    .i_fft_data(w_fft_data),
    .i_tx_valid(w_tx_valid),
    .o_tx_ready(w_tx_ready) // 1 trig
);
FFT_CONTROLER #(
    .radix(radix),
    .R(R),
    .N(N),
    .length(length),
    .DATA_LENGTH(DATA_LENGTH),
    .TWIDDLEFILE(TWIDDLEFILE)
) unit_FFT_CONTROLLER(
    // SYSTEM I/O
    .i_clk(i_clk),
    .i_rst(i_rst),
    // UART CONTROLLER
    .o_tx_init(o_tx_init),
    .o_fft_data(w_fft_data),
    .o_tx_valid(w_tx_valid),
    .i_tx_ready(w_tx_ready),
    // ROM
    .o_rom_addr(w_rom_addr),
    .i_rom_data(w_rom_data)
);
endmodule