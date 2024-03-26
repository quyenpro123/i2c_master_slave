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

    wire    [7:0]       prdata_o                                                ;
    wire                pready_o                                                ;
    wire                sda_io                                                  ;
    wire                scl_io                                                  ;
        
    dut_top dut(
        .i2c_core_clock_i(i2c_core_clock_i)                                     ,
        .pclk_i(pclk_i)                                                         ,
        .preset_n_i(preset_n_i)                                                 ,
        .penable_i(penable_i)                                                   ,
        .psel_i(psel_i)                                                         ,
        .paddr_i(paddr_i)                                                       ,
        .pwdata_i(pwdata_i)                                                     ,
        .pwrite_i(pwrite_i)                                                     ,
        .prdata_o(prdata_o)                                                     ,
        .pready_o(pready_o)                                                     ,
        .sda_io(sda_io)                                                         ,
        .scl_io(scl_io)
    );
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
        #10

        preset_n_i = 1                                                          ;

        #20
        //--------------------test write + repeat start + read------------------ 
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
        pwdata_i = 8'b00100100                                                  ; //reset command is set
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
        pwdata_i = 8'h20                                                  ; //address value
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
        pwdata_i = 8'h00                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;

        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b01010101                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b01010001                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b00110101                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b01111101                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        #2                                                                      
        psel_i = 1                                                              ; //56
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h02                                                         ;
        pwdata_i = 8'b01110111                                                  ; //data value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        //cpu enable i2c core and write repeat start bit
        #2                                                                      
        psel_i = 1                                                              ; //62
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b01100100                                                  ; //cmd register
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;//74
        $display("dut: %0d", $time);
        
        #5400
        //cpu want read data from slave
        #2
        psel_i = 1                                                              ; 
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h04                                                         ;
        pwdata_i = 8'h21                                                        ; //address value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        
        #694                                                                    ;//2330
        #210
        //disable repeat start bit and enable bit
        #2
        psel_i = 1                                                              ; 
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b01100100                                                  ; //cmd register
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;//2536
        #674
        #2000
        //cpu read to status register
        #2
        psel_i = 1                                                              ; //#32
        penable_i = 0                                                           ;
        pwrite_i = 0                                                            ;
        paddr_i = 8'h03                                                         ;
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        #2
        psel_i = 1                                                              ; //#32
        penable_i = 0                                                           ;
        pwrite_i = 0                                                            ;
        paddr_i = 8'h03                                                         ;
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
    end
    
    always #1 pclk_i = ~pclk_i                                                   ;
    always #5 i2c_core_clock_i = ~i2c_core_clock_i                               ;

endmodule