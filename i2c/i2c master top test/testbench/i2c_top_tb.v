module i2c_top_tb();
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
    wire                sda_i                                                   ;

    wire    [7:0]       prdata_o                                                ;
    wire                pready_o                                                ;
    wire                sda_o                                                   ;
    wire                scl_o                                                   ;

    reg sda_tb                                                                  ;
    reg sda_en_tb                                                               ;

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
        .ack_bit_i(ack_bit_i)                                                   ,
        .sda_i(sda_i)                                                           ,
        .prdata_o(prdata_o)                                                     ,
        .pready_o(pready_o)                                                     ,
        .sda_o(sda_o)                                                           ,
        .scl_o(scl_o)
    );

    assign sda_o = sda_en_tb ? sda_tb : 1'bz                                    ;
    pullup(sda_o)                                                               ;
    assign sda_i = sda_o                                                        ;

    initial 
    begin
        i2c_core_clock_i = 1                                                    ;
        pclk_i = 1                                                              ;
        preset_n_i = 0                                                          ;
        penable_i = 0                                                           ;
        psel_i = 0                                                              ;
        paddr_i = 0                                                             ;
        pwdata_i = 0                                                            ;
        pwrite_i = 0                                                            ;
        state_done_time_i = 4                                                   ;
        ack_bit_i = 0                                                           ;
        sda_en_tb = 0                                                           ;
        sda_tb = 0                                                              ;
        #10
        
        preset_n_i = 1                                                          ;
        
        #20
        
        //cpu write to prescaler register
        #2
        psel_i = 1                                                              ; //#32
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h00                                                         ;
        pwdata_i = 8'b00000100                                                  ; //prescaler value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        #10
        
        //cpu write to cmd register to disable reset i2c core
        psel_i = 1                                                              ; //46
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b00100000                                                  ; //reset command is set
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        
        
        
        //cpu send address of slave, and read write bit
        #2                                                                      
        psel_i = 1                                                              ; //50
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h04                                                         ;
        pwdata_i = 8'b10101010                                                  ; //prescaler value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        //cpu send data which is sent to slave
        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b10101010                                                  ; //prescaler value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        //cpu enable i2c core
        #2                                                                      
        psel_i = 1                                                              ; //62
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b01100000                                                  ; //prescaler value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;//68
        penable_i = 0                                                           ;
        
        #742                                                                      //810
        sda_en_tb = 1                                                           ;
        sda_tb = 0                                                              ;
        #90
        sda_en_tb = 0                                                           ; //900
        sda_tb = 0                                                              ;
    end

    always #1 pclk_i = ~pclk_i                                                  ;
    always #5 i2c_core_clock_i = ~i2c_core_clock_i                              ;

endmodule