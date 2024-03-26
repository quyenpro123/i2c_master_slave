`ifndef TEST_2
`define TEST_2
program testcase(intf intf);
    environment env;

    initial 
    begin
        env = new(intf);
        env.gen.repeat_random(10);
        env.main();    
    end

endprogram
`endif