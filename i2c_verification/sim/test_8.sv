//i2c master read n times
program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.driv.apb_reset();
        #30
        env.gen.trans = new();
        env.driv.apb_write(0, 8'h00);
        repeat (18)
        begin
            if (env.gen.trans.randomize())
                env.driv.apb_write(0, env.gen.trans.pwdata);
        end

        env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(5, 8'h4);
        env.driv.apb_write(4, 8'hc0);
	
	repeat(5)
	begin 
		wait(intf.start);
		wait(intf.stop);
		env.driv.apb_write(3, 8'h21);
		env.driv.apb_write(4, 8'h40);
	end
        #100000
        env.driv.apb_reset();
    end
endprogram
