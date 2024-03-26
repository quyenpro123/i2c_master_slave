////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`include "env.sv"
`include "interface.sv"
  program testcase(intf_cnt intf);
         environment env = new(intf);

    initial 
    begin
        env.gen.repeat_random = 5;
        env.main();    
    end 
    endprogram
