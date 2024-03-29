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
        env.driv.apb_reset();
        #30
        env.driv.apb_write(0, 8'h0);
        env.driv.apb_write(0, 8'h11);
        env.driv.apb_write(0, 8'h22);
        env.driv.apb_write(0, 8'h33);
        env.driv.apb_write(0, 8'h44);
        env.driv.apb_write(0, 8'h55);

        env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(5, 8'h4);
        env.driv.apb_write(4, 8'hc0);
        #3250
        env.driv.apb_write(4, 8'h00);
        #50
        env.driv.apb_write(4, 8'h0c0);
        #100000
        env.driv.apb_reset();   
    end
endprogram
