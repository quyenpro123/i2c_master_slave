module i2c_tb(

    );
    reg i2c_core_clock_i                                          ;
    reg reset_bit_i                                               ;
    reg enable_bit_i                                              ;
    reg [7:0] data_i                                              ;
    reg [7:0] addr_rw_i                                           ;
    reg [7:0] prescaler_i                                         ;
    reg repeat_start_bit_i                                        ;	// repeat start bit from cmd register		
    reg trans_fifo_empty_i                                        ;
    reg rev_fifo_full_i                                           ;
    reg [7:0] state_done_time_i                                   ;
    reg ack_bit_i                                                 ;
    reg sda_i                                                     ;

    wire sda_o                                                    ;
    wire scl_o                                                    ;
    
    i2c_master_top master_top(
        .i2c_core_clock_i(i2c_core_clock_i)                       ,
        .reset_bit_i(reset_bit_i)                                 ,
        .enable_bit_i(enable_bit_i)                               ,
        .data_i(data_i)                                           ,
        .addr_rw_i(addr_rw_i)                                     ,
        .prescaler_i(prescaler_i)                                 ,
        .repeat_start_bit_i(repeat_start_bit_i)                   ,
        .rev_fifo_full_i(rev_fifo_full_i)                         ,
        .trans_fifo_empty_i(trans_fifo_empty_i)                   ,
        .state_done_time_i(state_done_time_i)                     ,
        .ack_bit_i(ack_bit_i)                                     ,
        .sda_i(sda_i)                                             ,
        .sda_o(sda_o)                                             ,
        .scl_o(scl_o)                                               
    );

    initial 
    begin
        i2c_core_clock_i = 1                                        ;
        reset_bit_i = 0                                             ;
        enable_bit_i = 0                                            ;
        data_i = 0                                                  ;
        addr_rw_i = 0                                               ;
        prescaler_i = 10                                             ;
        repeat_start_bit_i = 1                                      ;
        trans_fifo_empty_i = 0                                      ;
        rev_fifo_full_i = 0                                         ;
        state_done_time_i =  10                                      ;
        ack_bit_i = 1                                               ;
        sda_i = 0                                                   ;

        #100
        reset_bit_i = 1                                             ;
        #20
        enable_bit_i = 1                                            ;
        data_i = 8'b01010101                                        ;
        addr_rw_i = 8'b10101011                                     ;

        #50

        enable_bit_i = 0                                            ;
        
        #200
        sda_i = 0                                                   ;
        rev_fifo_full_i = 1                                         ;
        #50
        #240
        trans_fifo_empty_i = 1                                      ;
        addr_rw_i = 8'b10101011                                     ;
        //repeat start
        #400
        repeat_start_bit_i = 0                                      ;
        rev_fifo_full_i = 1                                         ;
    end

    always #1 i2c_core_clock_i = ~i2c_core_clock_i                  ;
endmodule