`ifndef DRIVER
`define DRIVER
`include "interface.sv"
  class driver;
    virtual intf_cnt vif;
    int no_transaction = 0;
    mailbox gen2driv;
    function new(virtual intf_cnt vif, mailbox gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction //new()

    task apb_reset();
        vif.preset = 0;
        @ (negedge vif.pclk);
        vif.preset = 0;
        @ (negedge vif.pclk);
        vif.preset = 1;
    endtask

    task apb_write(logic [7:0] paddr, logic [7:0] pwdata);
        @(posedge vif.pclk);
        vif.paddr <= paddr;
        vif.pwrite <= 1;
        vif.psel <= 1;
        vif.penable <= 0;
        vif.pwdata <= pwdata;

        @(posedge vif.pclk);
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif.pclk);
        vif.psel <= 0;
        vif.penable <= 0;
    endtask

    task apb_read(logic [7:0] paddr);
        @(posedge vif.pclk);
        vif.paddr <= paddr;
        vif.pwrite <= 0;
        vif.psel <= 1;
        vif.penable <= 0;

        @(posedge vif.pclk);
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif.pclk);
        vif.psel <= 0;
        vif.penable <= 0;
    endtask

    task random_data(int repeat_random);
	int i = 0;
	repeat(repeat_random)
	begin
	    transactor trans;
            gen2driv.get(trans);
	    this.vif.data_master[i] = trans.pwdata;
	    i = i + 1;
	end
    endtask

    task main;
        forever
        begin
            transactor trans;
            gen2driv.get(trans);
            @(posedge vif.pclk);
            if (~trans.pwrite)
                apb_read(trans.paddr);
            else
                apb_write(trans.paddr, trans.pwdata);
            no_transaction++;
        end
    endtask
   endclass
`endif
