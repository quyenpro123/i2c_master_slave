module fifo_tb ();
    reg read_clock_i                                                ; //clock in read domain 
    reg read_reset_n_i                                              ; //reset active low signal in read domain
    reg read_inc_i                                                  ; //variable increases read address value
    
    reg write_clock_i                                               ; //clock in write domain
    reg write_reset_n_i                                             ; //reset active low signal from write domain
    reg write_inc_i                                                 ; //variable increases write address value
    reg [7:0] data_i                                                ; //input data write to mem

    wire [7:0]data_o                                                ; //output data read from mem
    wire read_empty_o                                               ; //signal that mem is empty
    wire read_almost_empty_o                                        ; //signal that mem is almost empty
    
    wire write_full_o                                               ; //signal that fifo is full
    wire write_almost_full_o                                          //signal that fifo is almost full

    fifo_block_top tb(
        .read_clock_i(read_clock_i)                                 ,
        .read_reset_n_i(read_reset_n_i)                             ,
        .read_inc_i(read_inc_i)                                     ,

        .write_clock_i(write_clock_i)                               ,
        .write_reset_n_i(write_reset_n_i)                           ,
        .write_inc_i(write_inc_i)                                   ,
        .data_i(data_i)                                             ,

        .data_o(data_o)                                             ,
        .read_empty_o(read_empty_o)                                 ,
        .read_almost_empty_o(read_almost_empty_o)                   ,

        .write_full_o(write_full_o)                                 ,
        .write_almost_full_o(write_almost_full_o)                   
    );

    initial 
    begin
        read_clock_i = 0                                            ;
        read_reset_n_i = 0                                          ;
        read_inc_i = 0                                              ;

        write_clock_i = 0                                           ;
        write_reset_n_i = 0                                         ;
        write_inc_i = 0                                             ;
        data_i = 0                                                  ;

        #50
        read_reset_n_i = 1                                          ;
        write_reset_n_i = 1                                         ;
        #70
        write_inc_i = 1                                             ;
        #100
        read_inc_i = 1                                              ;
    end

    always #5 write_clock_i = ~write_clock_i                        ;
    always #10 read_clock_i = ~read_clock_i                         ;
    always #10 data_i = data_i + 1                                  ;
endmodule