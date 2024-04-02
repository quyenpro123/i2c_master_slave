
// slave's address is incorect
program testcase(intf_cnt intf);
  environment env = new(intf);

    initial 
    begin
        env.driv.apb_reset();
        #30
        env.driv.apb_write(0, 8'h00);
        env.driv.apb_write(0, 8'h11);
        env.driv.apb_write(0, 8'h22);
        env.driv.apb_write(0, 8'h33);
        env.driv.apb_write(0, 8'h44);
        env.driv.apb_write(0, 8'h55);

        env.driv.apb_write(3, 8'h22);
        env.driv.apb_write(5, 8'h04);
        env.driv.apb_write(4, 8'he0);
        #100000
        env.driv.apb_reset();   
    end
endprogram
