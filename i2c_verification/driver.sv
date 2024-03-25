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

    task apb_write_function();
        vif.paddr = 0; //addr
        vif.pwrite = 1;
        vif.psel = 1;
        vif.penable = 0;
        vif.pwdata = 0;

        @(posedge vif.pclk);
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif);
        vif.psel <= 0;
        vif.penable >= 0;
    endtask

    task apb_read_function();
        vif.paddr = 0; //addr
        vif.pwrite = 0;
        vif.psel = 1;
        vif.penable = 0;

        @(posedge vif.pclk);
        vif.psel <= 1;
        vif.penable <= 1;

        @(posedge vif);
        vif.psel <= 0;
        vif.penable >= 0;
    endtask



    function main;
        
    endfunction
 endclass//driver