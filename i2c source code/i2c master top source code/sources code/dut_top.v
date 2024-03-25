module dut_top();
    reg                 i2c_core_clock_i                                        ;
    reg                 pclk_i                                                  ;
    reg                 preset_n_i                                              ;
    reg                 penable_i                                               ;
    reg                 psel_i                                                  ;
    reg     [7:0]       paddr_i                                                 ;
    reg     [7:0]       pwdata_i                                                ;
    reg                 pwrite_i                                                ;
    reg     [7:0]       state_done_time_i                                       ;
    reg                 ack_bit_i                                               ;

    wire    [7:0]       prdata_o                                                ;
    wire                pready_o                                                ;
    wire                sda_io                                                  ;
    wire                scl_io                                                  ;

    i2c_master_top master(
        .i2c_core_clock_i(i2c_core_clock_i)                                     ,
        .pclk_i(pclk_i)                                                         ,
        .preset_n_i(preset_n_i)                                                 ,
        .penable_i(penable_i)                                                   ,
        .psel_i(psel_i)                                                         ,
        .paddr_i(paddr_i)                                                       ,
        .pwdata_i(pwdata_i)                                                     ,
        .pwrite_i(pwrite_i)                                                     ,
        .state_done_time_i(state_done_time_i)                                   ,
        .prdata_o(prdata_o)                                                     ,
        .pready_o(pready_o)                                                     ,
        .sda_io(sda_io)                                                         ,
        .scl_io(scl_io)
    );

    i2c_slave_model slave(
        .sda_io(sda_io)                                                         ,
        .scl_io(scl_io)
    );
endmodule