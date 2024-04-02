module dut_top
#(
    parameter                           DATA_SIZE = 8	        ,
    parameter                           ADDR_SIZE = 8
)
(
    input                               i2c_core_clk_i          ,   // clock core of i2c
    input                               pclk_i                  ,   //  APB clock
    input                               preset_n_i              ,   //  reset signal is active-LOW
    input   [ADDR_SIZE - 1 : 0]         paddr_i                 ,   //  address of APB slave and register map
    input                               pwrite_i                ,   //  HIGH is write, LOW is read
    input                               psel_i                  ,   //  select slave interface
    input                               penable_i               ,   //  Enable. PENABLE indicates the second and subsequent cycles of an APB transfer.
    input   [DATA_SIZE - 1 : 0]         pwdata_i                ,   //  data write

    output  [DATA_SIZE - 1 : 0]         prdata_o                ,   //  data read
    output                              pready_o                ,   //  ready to receive data
    output                              start                   ,
    output                              stop                    ,
    output  [DATA_SIZE - 1 : 0]         data_slave_read         ,
    output                              data_slave_read_valid   ,
    inout                               sda_io                  ,
    inout                               scl_io
);

    i2c_top master(
        .i2c_core_clk_i(i2c_core_clk_i)                                                 ,
        .pclk_i(pclk_i)                                                                 ,
        .preset_ni(preset_n_i)                                                         	,
        .penable_i(penable_i)                                                           ,
        .psel_i(psel_i)                                                                 ,
        .paddr_i(paddr_i)                                                               ,
        .pwdata_i(pwdata_i)                                                             ,
        .pwrite_i(pwrite_i)                                                             ,
        .prdata_o(prdata_o)                                                             ,
        .pready_o(pready_o)                                                             ,
        .sda(sda_io)                                                                    ,
        .scl(scl_io)
    );

    i2c_slave_model slave(
        .sda(sda_io)                                                                    ,
        .scl(scl_io)                                                                    ,
        .data_slave_read(data_slave_read)                                               ,
        .data_slave_read_valid(data_slave_read_valid)                                   ,
        .start(start)                                                                   ,
        .stop(stop)
    );

endmodule