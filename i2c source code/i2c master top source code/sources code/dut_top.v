module dut_top(
    input               i2c_core_clock_i                                                ,

    input               pclk_i                                                          , //apb clock
    input               preset_n_i                                                      , //apb reset
    input               penable_i                                                       ,
    input               psel_i                                                          ,
    input       [7:0]   paddr_i                                                         ,
    input       [7:0]   pwdata_i                                                        ,
    input               pwrite_i                                                        ,

    //----------------------------------------------------------------------------------
    output      [7:0]   prdata_o                                                        ,
    output              pready_o                                                        ,
    output              start                                                           ,
    output              stop                                                            ,
    inout               sda_io                                                          ,
    inout               scl_io
    );
    
    pullup(sda_io);

    i2c_master_top master(
        .i2c_core_clock_i(i2c_core_clock_i)                                             ,
        .pclk_i(pclk_i)                                                                 ,
        .preset_n_i(preset_n_i)                                                         ,
        .penable_i(penable_i)                                                           ,
        .psel_i(psel_i)                                                                 ,
        .paddr_i(paddr_i)                                                               ,
        .pwdata_i(pwdata_i)                                                             ,
        .pwrite_i(pwrite_i)                                                             ,
        .prdata_o(prdata_o)                                                             ,
        .pready_o(pready_o)                                                             ,
        .sda_io(sda_io)                                                                 ,
        .scl_io(scl_io)
    );

    i2c_slave_model slave(
        .sda(sda_io)                                                                    ,
        .scl(scl_io)                                                                    ,
        .start(start)                                                                   ,
        .stop(stop)
    );
endmodule