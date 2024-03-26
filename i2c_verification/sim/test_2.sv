////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////

program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.gen.repeat_random = 100;
        env.driv.apb_reset();
        #30
        env.driv.apb_write(4, 8'h64);
        env.driv.apb_write(2, 8'h00);
        env.driv.apb_write(2, 8'h22);
        env.driv.apb_write(2, 8'h33);
        env.driv.apb_write(2, 8'h44);
        env.driv.apb_write(2, 8'h55);
        env.driv.apb_write(2, 8'h66);
        env.driv.apb_write(1, 8'h64); 
        env.gen.main();
        env.post();
    end
endprogram
