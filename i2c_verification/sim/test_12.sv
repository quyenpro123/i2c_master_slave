//APB master write continously data to transfifo, exceed the depth of transfifo
program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.driv.apb_reset();
        #30
        env.gen.trans = new();
        env.driv.apb_write(0, 8'h00);
        env.driv.apb_write(0, 8'hff);
        repeat (17)
        begin
            if (env.gen.trans.randomize())
                env.driv.apb_write(0, env.gen.trans.pwdata);
        end

        env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(5, 8'h4);
        env.driv.apb_write(4, 8'hc0);
	wait(intf.start);
	wait(intf.stop);
	env.driv.apb_write(3, 8'h21);
	env.driv.apb_write(4, 8'hc0);

	wait(intf.start);
	wait(intf.stop);
	repeat (20)
		env.driv.apb_read(1);
        #100000
        env.driv.apb_reset();
    end
endprogram
