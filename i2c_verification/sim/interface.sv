`ifndef INTF
`define INTF
interface intf_cnt(input logic pclk, input logic i2c_core_clock);
    //input dut
    logic preset;
    logic [7:0] paddr;
    logic pwrite;
    logic psel;
    logic penable;
    logic [7:0] pwdata;
    //output dut
    wire sda_io;
    wire scl_io;
    logic [7:0] prdata_o;
    logic pready_o;

    //slave output
    logic [7:0] data_slave_read;
    logic data_slave_read_valid;
    logic stop;
    logic start;
    logic [7:0] data_master [15:0];
endinterface
`endif
