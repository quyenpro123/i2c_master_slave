`ifndef DRIV
`define DRIV
class driver;
    virtual intf vif;
    int no_transaction;
    mailbox gen2driv;
    function new(virtual intf vif, mailbox gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction //new()

    task apb_reset();
        wait(vif.preset)
        vif.paddr <= 0;
        vif.pwrite <= 0;
        vif.psel <= 0;
        vif.penable <= 0;
        vif.pwdata <= 0;
        wait(~vif.apb_reset);
    endtask

    task apb_write(logic [7:0] paddr, logic [7:0] pwdata);
        @(posedge vif.pclk)
        vif.paddr <= paddr;
        vif.pwrite <= 1;
        vif.psel <= 1;
        vif.penable <= 0;
        vif.pwdata <= pwdata;

        @(posedge vif.pclk)
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif.pclk)
        vif.psel <= 0;
        vif.penable <= 0;
    endtask

    task apb_read(logic [7:0] paddr)
        @(posedge vif.pclk)
        vif.paddr <= paddr;
        vif.pwrite <= 0;
        vif.psel <= 1;
        vif.penable <= 0;

        @(posedge vif.pclk)
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif.pclk)
        vif.psel <= 0;
        vif.penable <= 0;
    endtask

    task main;
        forever
        begin
            transactor trans;
            gen2driv.get(trans);
            @(posedge vif.pclk)
            if (~trans.pwrite)
                apb_read(trans.paddr);
            else
                apb_write(trans.paddr, trans.pwdata);
            no_transaction++;
        end
    endtask
 endclass//driver
 `endif