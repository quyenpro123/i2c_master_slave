//i2c master write n bytes
//repeat start
//i2c master read n bytes

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
        env.driv.apb_write(5, 8'h08);
        env.driv.apb_write(4, 8'hc0);
        @(posedge intf.start);
	@(posedge intf.stop);
        env.driv.apb_write(3, 8'h21);
        env.driv.apb_write(4, 8'hc0);

        #1500
        //disable repeat start
        
        #100000
        env.driv.apb_reset();   
    end
endprogram
