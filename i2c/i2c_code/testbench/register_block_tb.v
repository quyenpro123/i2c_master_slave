module register_block_tb();
    //-------------------------------slave apb - master apb--------------------------------------------------
    reg pclk_i                                                              ; //clock 
    reg preset_n_i                                                          ; //reset signal
    reg penable_i                                                           ; //enable signal from master to slave
    reg psel_i                                                              ; //select signal from master to slave
    reg [7:0]  paddr_i                                                      ; //address master send to slave
    reg [7:0]  pwdata_i                                                     ; //data master send to slave
    reg pwrite_i                                                            ; //read/write signal from master
         
    wire [7:0] prdata_o                                                     ; //data slave send to master
    wire pready_o                                                           ; //ready signal slave send to master

    //-------------------------------register block - i2c core--------------------------------------------------
    reg [7:0]  receive_i                                                    ; //receive data input from receive fifo
    reg [7:0]  status_i                                                     ; //status input from i2c core, written by i2c core
    wire [7:0] prescaler_o                                                  ; //output of prescaler register
    wire [7:0] cmd_o                                                        ; //output of cmd register
    wire [7:0] address_rw_o                                                 ; //output of address_rw register
    wire [7:0] transmit_o                                                   ; //output of transmit register for transmit fifo
    wire       rx_fifo_read_enable_o                                        ;
    wire       tx_fifo_write_enable_o                                       ;

    i2c_register_block tb(
        .pclk_i(pclk_i)                                                     ,
        .preset_n_i(preset_n_i)                                             ,
        .penable_i(penable_i)                                               ,
        .psel_i(psel_i)                                                     ,
        .paddr_i(paddr_i)                                                   ,
        .pwdata_i(pwdata_i)                                                 ,
        .pwrite_i(pwrite_i)                                                 ,
        .prdata_o(prdata_o)                                                 ,
        .pready_o(pready_o)                                                 ,
        .receive_i(receive_i)                                               ,
        .status_i(status_i)                                                 ,
        .prescaler_o(prescaler_o)                                           ,
        .cmd_o(cmd_o)                                                       ,
        .address_rw_o(address_rw_o)                                         ,
        .tx_fifo_write_enable_o(tx_fifo_write_enable_o)                     ,
        .rx_fifo_read_enable_o(rx_fifo_read_enable_o)                       ,
        .transmit_o(transmit_o)                                             
    );
    
    initial 
    begin
           pclk_i = 1                                                       ;
           preset_n_i = 0                                                   ;
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           paddr_i = 0                                                      ;
           pwdata_i = 0                                                     ;
           pwrite_i = 0                                                     ;
           receive_i = 0                                                    ;
           status_i = 0                                                     ;
           //---------------test write data-------------------------------
           #10
           preset_n_i = 1                                                   ;
           #10
           penable_i = 0                                                    ;
           psel_i = 1                                                       ;
           pwrite_i = 1                                                     ;
           paddr_i = 8'h02                                                  ;
           pwdata_i = 8'hab                                                 ;
           #10
           penable_i = 1                                                    ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           
           #10
           penable_i = 0                                                    ;
           psel_i = 1                                                       ;
           pwrite_i = 1                                                     ;
           paddr_i = 8'h04                                                  ;
           pwdata_i = 8'hba                                                 ;
           #10
           penable_i = 1                                                    ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           //-----------------test read data----------------------------------
           #30
           psel_i = 1                                                       ;
           penable_i = 0                                                    ;
           paddr_i = 8'h02                                                  ;
           pwrite_i = 0                                                     ;
           #10
           penable_i = 1                                                    ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           #10
           penable_i = 0                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 1                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           
           #10
           paddr_i = 8'h04                                                  ;
           penable_i = 0                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 1                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
           
           #10
           paddr_i = 8'h03                                                  ;
           penable_i = 0                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 1                                                    ;
           psel_i = 1                                                       ;
           #10
           penable_i = 0                                                    ;
           psel_i = 0                                                       ;
    end

    always #5 pclk_i = ~pclk_i                                              ;
endmodule