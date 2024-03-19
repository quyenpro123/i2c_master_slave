class monitor;
    
    virtual intf vif;

    mailbox mon2scb;
    

    function new(virtual intf vif, mailbox mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction //new()
endclass //monitor