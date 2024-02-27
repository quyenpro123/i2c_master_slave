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
    
    //variable of slave
    localparam          slave_addr_tb = 7'b1010101                              ;
    reg     [7:0]       data_o_tb = 8'b11001100                                 ;
    reg     [7:0]       read_byte_tb = 8'b0                                     ;
    reg     [7:0]       read_addr_tb = 8'b0                                     ;
    reg     [7:0]       read_data_tb = 8'b0                                     ;
    reg     [7:0]       counter_data_tb = 9                                     ;
    reg     [7:0]       counter_addr_tb = 9                                     ;
    reg     [7:0]       counter_write_data_tb = 9                               ;
    reg                 read_write_bit_tb = 0                                   ;       
                                                       
    reg sda_o_tb                                                                ;
    wire sda_i_tb                                                               ;
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
        .prdata_o(prdata_o)                                                     ,
        .pready_o(pready_o)                                                     ,
        .sda_io(sda_io)                                                         ,
        .scl_io(scl_io)
    );

    assign sda_io = sda_en_tb ? sda_o_tb : 1'bz                                 ;
    pullup(sda_io)                                                              ;
    assign sda_i_tb = sda_io                                                    ;

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
        sda_o_tb = 0                                                            ;
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
        pwdata_i = 8'b10101010                                                  ; //address value
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
        pwdata_i = 8'b10101010                                                  ; //data value
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
        
        //cpu enable i2c core and write repeat start bit
        #2                                                                      
        psel_i = 1                                                              ; //62
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b11100000                                                  ; //cmd register
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;//74
                        
        #816
        sda_en_tb = 0                                                           ; 
        sda_o_tb = 0                                                            ; //900 
        #730
        sda_en_tb = 0                                                           ; 
        sda_o_tb = 0                                                            ; //1620
        //cpu want read data from slave
        #2
        psel_i = 1                                                              ; 
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h04                                                         ;
        pwdata_i = 8'b10101011                                                  ; //address value
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;
        
        
        #694                                                                    ;//2330
        sda_en_tb = 0                                                           ; 
        sda_o_tb = 0                                                            ;
        #210
        //disable repeat start bit and enable bit
        #2
        psel_i = 1                                                              ; 
        penable_i = 0                                                           ;
        pwrite_i = 1                                                            ;
        paddr_i = 8'h01                                                         ;
        pwdata_i = 8'b00100000                                                  ; //cmd register
        #2
        psel_i = 1                                                              ;
        penable_i = 1                                                           ;
        #2
        psel_i = 0                                                              ;
        penable_i = 0                                                           ;//2536
        #674
//        sda_en_tb = 0                                                           ;//3210
//        sda_o_tb = 0                                                            ; 
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
    
    //detect start, repeat start
    always @(negedge sda_io)
    begin   
        if (scl_io == 1)
        begin
            counter_addr_tb <= 9                                                ;
        end     
    end    
    
    
    //read sda from slave
    always @(posedge scl_io)
    begin
        if (counter_addr_tb >= 1)
        begin
            read_byte_tb[counter_addr_tb - 2] <= sda_i_tb                       ;
            counter_addr_tb <= counter_addr_tb - 1                              ;
        end
        else if (counter_data_tb >= 1 && counter_addr_tb == 0)
        begin
            read_byte_tb[counter_data_tb - 2] <= sda_i_tb                       ;
            counter_data_tb <= counter_data_tb - 1                              ;
        end
        if (counter_write_data_tb == 0)
            if (sda_i_tb == 0)
            begin
                counter_write_data_tb <= 9                                      ;
                data_o_tb <= ~data_o_tb                                         ;
            end
    end
    
    //catch data
    always @(negedge scl_io)
    begin
        if (counter_addr_tb == 1)
        begin
            read_addr_tb <= read_byte_tb                                        ;
            if (read_byte_tb[7:1] == slave_addr_tb)
            begin
                read_write_bit_tb = read_byte_tb[0]                             ;
                sda_en_tb <= 1                                                  ; //2410
                sda_o_tb <= 0                                                   ;
            end
        end
        else if (counter_data_tb == 1)
            begin
                read_data_tb <= read_byte_tb                                    ;
                sda_en_tb <= 1                                                  ; //2410
                sda_o_tb <= 0                                                   ;  
            end
        if (counter_data_tb == 0 && counter_addr_tb == 0 && read_write_bit_tb == 0)
            counter_data_tb <= 9                                                ;
        else if (read_write_bit_tb == 1)
            counter_data_tb <= 0                                                ;
            
        if (read_write_bit_tb == 1 && counter_write_data_tb > 1 && counter_addr_tb == 0)
            begin               
                sda_en_tb <= 1                                                   ; //2410
                sda_o_tb <= data_o_tb[counter_write_data_tb - 2]                 ;
                counter_write_data_tb <= counter_write_data_tb - 1               ;
            end
        else if (counter_write_data_tb == 1)
            begin
                sda_en_tb <= 0                                                   ; //2410
                counter_write_data_tb <= counter_write_data_tb - 1               ;
            end
    end
    
    
    always #1 pclk_i = ~pclk_i                                                   ;
    always #5 i2c_core_clock_i = ~i2c_core_clock_i                               ;

endmodule