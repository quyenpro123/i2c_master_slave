`ifndef TRAN
`define TRAN
class transactor;
    rand logic [7:0]    pwdata;
    rand logic [7:0]    paddr;
    rand logic          pwrite;
    constraint protocol1 {pwrite == 1 -> paddr inside {[1:2], 4};}
    constraint protocol2 {pwrite == 0 -> paddr inside {[0:5]};}
    //constraint value {pwdata == 8'h64;}
endclass //transactor
`endif