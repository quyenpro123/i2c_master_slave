`ifndef TEST_1
`define TEST_1
`include "environment.sv"
program testcase(intf intf);
    environment env;

    initial 
    begin
        env = new(intf);
        env.gen.repeat_random(5);
        env.main();    
    end

endprogram
`endif