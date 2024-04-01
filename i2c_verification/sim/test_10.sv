//APB master write continously data to transfifo, exceed the depth of transfifo
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
        #100000
        env.driv.apb_reset();
    end
endprogram
