//combination of 1 write and 1 read
program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.driv.apb_reset();
        #30
        env.gen.trans = new();
        env.driv.apb_write(0, 8'h00);
        env.driv.apb_write(0, 8'h11);

        env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(5, 8'h4);
        env.driv.apb_write(4, 8'he0);

        @(posedge intf.start);
        @(posedge intf.start);

        env.driv.apb_write(3, 8'h21);
        env.driv.apb_write(4, 8'he0);
	
        @(posedge intf.start);
	env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(4, 8'he0);

	@(posedge intf.start);
	env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(4, 8'hc0);
        #100000
        env.driv.apb_reset();
    end
endprogram
