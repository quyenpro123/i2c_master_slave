////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`ifndef ENV
`define ENV
    `include "driver.sv"
`include "generator.sv"
    class environment;
           generator gen;
    driver driv;

    mailbox gen2driv;

    virtual intf_cnt vif;

    function new(virtual intf_cnt vif);
        this.vif = vif;
        gen2driv = new();
        gen = new(gen2driv);
        driv = new(vif, gen2driv);
    endfunction
    
    task apb_reset;
        driv.apb_reset();
    endtask

    task test();
        fork
            gen.main();
            driv.main();
        join_any
    endtask

    task post();
        wait(gen.ended.triggered);
        wait(gen.repeat_random == 100);
    endtask

    task main();
        apb_reset();
        test();
        post();
    endtask
     endclass
`endif
