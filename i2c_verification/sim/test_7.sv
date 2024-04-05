//i2c master write n bytes
//repeat start
//i2c master read n bytes

program testcase(intf_cnt intf);
    environment env = new(intf);
    int i = 0;
    initial 
    begin
        env.driv.apb_reset();
        #30
        env.driv.apb_write(0, 8'h0);
        env.gen_data_random(5);
        repeat(5)
        begin
          env.driv.apb_write(0, intf.data_master[i]);
          i = i + 1;
        end

        env.driv.apb_write(3, 8'h20);
        env.driv.apb_write(5, 8'h08);
        env.driv.apb_write(4, 8'he0);
        // @(posedge intf.start);
        // @(posedge intf.stop);
        // env.driv.apb_write(3, 8'h21);
        // env.driv.apb_write(4, 8'hc0);

        #25000
        env.driv.apb_write(3, 8'h21);
        env.driv.apb_write(4, 8'hc0);
        #1500
        //disable repeat start
        
        #100000
        env.driv.apb_reset();
    end
endprogram
