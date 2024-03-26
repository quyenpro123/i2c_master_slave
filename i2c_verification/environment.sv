`ifndef ENV
`define ENV
`include "driver.sv"
`include "generator.sv"
class environment;
    generator gen;
    driver driv;

    mailbox gen2driv;

    virtual intf vif;

    function new(virtual intf vif);
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
        wait(gen.repeat_random == driv.no_transaction);
    endtask

    task main();
        apb_reset();
        test();
        post();
    endtask
endclass
`endif