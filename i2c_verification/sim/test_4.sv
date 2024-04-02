//apb master write/read out-of-range registers
program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.driv.apb_reset();
        #30
        env.driv.apb_write(0, 8'h11);
        env.driv.apb_write(3, 8'h22);
        env.driv.apb_write(4, 8'h33);
        env.driv.apb_write(5, 8'h44);
	env.driv.apb_write(6, 8'hee);
        env.driv.apb_write(7, 8'hcc);
 	#30
        env.driv.apb_read(0);
        env.driv.apb_read(3);
        env.driv.apb_read(4);
        env.driv.apb_read(5);
        env.driv.apb_read(6);
        env.driv.apb_read(7);
        #1000
        env.driv.apb_reset();   
    end
endprogram
