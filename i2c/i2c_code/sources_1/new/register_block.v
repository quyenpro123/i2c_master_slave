module register_block(
    input                   CLOCK_i                                                 , //clock for register block
    input                   RESET_i                                                 , //reset for register block
    input   [7:0]           DATA_i                                                  , //data in from apb slave
    input   [7:0]           REGISTER_ADDR_i                                         , //address of register from apb slave
    input   [7:0]           RECEIVE_i                                               , //receive data input from receive fifo
    input   [7:0]           STATUS_i                                                , //status input from i2c core, written by i2c core
    input                   PWRITE_i                                                , //write/read signal from cpu

    output  [7:0]           PRESCALER_o                                             , //output prescaler register
    output  [7:0]           CMD_o                                                   , //output cmd register
    output  [7:0]           ADDRESS_RW_o                                            , //output address_rw register
    output  [7:0]           TRANSMIT_o                                              , //output transmit register for transmit fifo
    output  [7:0]           RECEIVE_o                                               , //output receive register
    output  [7:0]           STATUS_o                                                , //output status (read only for cpu)
);
    reg [7:0] prescaler                                                             ;
    reg [7:0] cmd                                                                   ;
    reg [7:0] transmit                                                              ;
    reg [7:0] receive                                                               ;
    reg [7:0] address                                                               ;
    reg [7:0] status                                                                ;

    always @() 
    begin
        
    end


endmodule