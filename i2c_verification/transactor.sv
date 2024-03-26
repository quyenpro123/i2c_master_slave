`ifndef STI
`define STI
class transactor;
    rand logic [7:0]    pwdata;
    randc logic [7:0]    paddr;
    rand logic          pwrite;
    constraint protocol {
        if (pwrite == 0)
            paddr inside {[0:5]};
        else
            paddr inside {1, [3:5]};
    };
endclass //transactor
`endif