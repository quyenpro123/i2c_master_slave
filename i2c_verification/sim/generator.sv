`ifndef GEN
`define GEN
`include "transactor.sv"
class generator;
    rand transactor trans;
    mailbox gen2driv;
    event ended;
    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    task main(int repeat_random);
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