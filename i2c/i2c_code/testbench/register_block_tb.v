module register_block_tb();
    //-------------------------------slave apb - master apb--------------------------------------------------
    reg PCLK_i                                                              ; //clock 
    reg PRESET_N_i                                                          ; //reset signal
    reg PENABLE_i                                                           ; //enable signal from master to slave
    reg PSEL_i                                                              ; //select signal from master to slave
    reg [7:0]  PADDR_i                                                      ; //address master send to slave
    reg [7:0]  PWDATA_i                                                     ; //data master send to slave
    reg PWRITE_i                                                            ; //read/write signal from master
         
    wire [7:0] PRDATA_o                                                     ; //data slave send to master
    wire PREADY_o                                                           ; //ready signal slave send to master

    //-------------------------------register block - i2c core--------------------------------------------------
    reg [7:0]  RECEIVE_i                                                    ; //receive data input from receive fifo
    reg [7:0]  STATUS_i                                                     ; //status input from i2c core, written by i2c core
    wire [7:0] PRESCALER_o                                                  ; //output of prescaler register
    wire [7:0] CMD_o                                                        ; //output of cmd register
    wire [7:0] ADDRESS_RW_o                                                 ; //output of address_rw register
    wire [7:0] TRANSMIT_o                                                   ; //output of transmit register for transmit fifo

    i2c_register_block tb(
        .PCLK_i(PCLK_i)                                                     ,
        .PRESET_N_i(PRESET_N_i)                                             ,
        .PENABLE_i(PENABLE_i)                                               ,
        .PSEL_i(PSEL_i)                                                     ,
        .PADDR_i(PADDR_i)                                                   ,
        .PWDATA_i(PWDATA_i)                                                 ,
        .PWRITE_i(PWRITE_i)                                                 ,
        .PRDATA_o(PRDATA_o)                                                 ,
        .PREADY_o(PREADY_o)                                                 ,
        .RECEIVE_i(RECEIVE_i)                                               ,
        .STATUS_i(STATUS_i)                                                 ,
        .PRESCALER_o(PRESCALER_o)                                           ,
        .CMD_o(CMD_o)                                                       ,
        .ADDRESS_RW_o(ADDRESS_RW_o)                                         ,
        .TRANSMIT_o(TRANSMIT_o)                                             
    );
    
    initial 
    begin
           PCLK_i = 1                                                       ;
           PRESET_N_i = 0                                                   ;
           PENABLE_i = 0                                                    ;
           PSEL_i = 0                                                       ;
           PADDR_i = 0                                                      ;
           PWDATA_i = 0                                                     ;
           PWRITE_i = 0                                                     ;
           RECEIVE_i = 0                                                    ;
           STATUS_i = 0                                                     ;
           #10
           PRESET_N_i = 1                                                   ;
           #10
           PENABLE_i = 0                                                    ;
           PSEL_i = 1                                                       ;
           PWRITE_i = 1                                                     ;
           PADDR_i = 8'h02                                                  ;
           PWDATA_i = 8'hab                                                 ;
           #10
           PENABLE_i = 1                                                    ;
           #10
           PENABLE_i = 0                                                    ;
           PSEL_i = 0                                                       ;
           #20
           PSEL_i = 1                                                       ;
           PENABLE_i = 0                                                    ;
           PADDR_i = 8'h02                                                  ;
           PWRITE_i = 0                                                     ;
           #10
           PENABLE_i = 1                                                    ;
           #10
           PENABLE_i = 0                                                    ;
           PSEL_i = 0                                                       ;
            
    end

    always #5 PCLK_i = ~PCLK_i                                              ;
endmodule