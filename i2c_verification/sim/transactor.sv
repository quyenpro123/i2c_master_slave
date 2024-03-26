`ifndef TRAN
`define TRAN
class transactor;
    rand logic [7:0]    pwdata;
    rand logic [7:0]    paddr;
    rand logic          pwrite;
    constraint protocol {paddr inside {[1:2], 4};}
    constraint value {pwdata == 8'h64;}
endclass //transactor
`endif