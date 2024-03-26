`ifndef INTF
`define ITNF
interface intf(input logic pclk, preset, i2c_core_clock);
    //input dut
    logic [7:0] paddr;
    logic pwrite;
    logic psel;
    logic penable;
    logic [7:0] pwdata;
    logic sda_in;
    logic scl_in;
    //output dut
    logic sda_out;
    logic scl_out;
    logic [7:0] prdata_o;
    logic pready_o;
endinterface
`endif