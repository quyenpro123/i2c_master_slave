`ifndef GEN
`define GEN
class generator;
    rand transactor trans;
    mailbox gen2driv;
    int repeat_random;
    event ended;
    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    task main();
        repeat(repeat_random) begin
            trans = new();
            if (!trans.randomize()) 
                $fatal("gen trans randomization fail");
            gen2driv.put(trans);   
        end
        -> ended;
    endtask //
endclass 
`endif 