module i2c_master_top(
    input i2c_core_clock_i                                          ,
    input reset_bit_i                                               ,
    input enable_bit_i                                              ,
    input [7:0] data_i                                              ,
    input [7:0] addr_rw_i                                           ,
    input [7:0] prescaler_i                                         ,
    input repeat_start_bit_i                                        ,	// repeat start bit from cmd register		
    input trans_fifo_empty_i                                        ,
    input rev_fifo_full_i                                           ,
    input [7:0] state_done_time_i                                   ,
    input ack_bit_i                                                 ,
    input sda_i                                                     ,

    inout sda_o                                                    ,
    inout scl_o                                                    
);
    
    wire temp_sda_o                                                 ;
    wire tem_scl_o                                                  ;
    wire [7:0] counter_detect_edge                                  ;
    wire [7:0] counter_data_ack                                     ;
    wire [7:0] counter_state_done_time_repeat_start                 ;

    wire start_cnt                                                          ;// start signal to datapath and clock generator						    
    wire write_addr_cnt                                                     ;// write addr signal to datapath and clock generator to transfer addr of slave												
    wire write_data_cnt                                                     ;// write data signal to datapath and clock generator to transfer data 						
    wire read_data_cnt                                                      ;// read data signal to datapath and clock generator to read data 
    wire write_ack_cnt                                                      ;// after read data is done, master send ack bit					
    wire read_ack_cnt                                                       ;// read ack from slave
    wire stop_cnt                                                           ;// stop signal to datapath and clock generator 	
    wire repeat_start_cnt                                                   ;// repeat start signal to datapath and clock generator					    
    wire scl_en				                                                ;// enable scl
    wire sda_en                                                             ;// enable sda 
    wire [7:0] data_o                                                       ;
    
    
    assign sda_o = sda_en == 1 ? temp_sda_o : 1'bz                  ;
    assign scl_o = scl_en == 1 ? tem_scl_o : 1                      ;
    //pullup(sda_o)                                                   ;
    i2c_clock_gen_block clock_gen(
        .i2c_core_clock_i(i2c_core_clock_i)                         ,
        .reset_bit_i(reset_bit_i)                                   ,
        .prescaler_i(prescaler_i)                                   ,
        .scl_o(tem_scl_o)                                           ,
        .counter_detect_edge_o(counter_detect_edge)                     
    );

    i2c_data_path_block datapath_block(
        .i2c_core_clock_i(i2c_core_clock_i)                         ,
        .reset_bit_i(reset_bit_i)                                   ,
        .sda_i(sda_i)                                               ,
        .data_i(data_i)                                             ,
        .addr_rw_i(addr_rw_i)                                       ,
        .ack_bit_i(ack_bit_i)                                       ,
        .start_cnt_i(start_cnt)                                     ,
        .write_addr_cnt_i(write_addr_cnt)                           ,
        .write_data_cnt_i(write_data_cnt)                           ,
        .read_data_cnt_i(read_data_cnt)                             ,
        .write_ack_cnt_i(write_ack_cnt)                             ,
        .read_ack_cnt_i(read_ack_cnt)                               ,
        .stop_cnt_i(stop_cnt)                                       ,
        .repeat_start_cnt_i(repeat_start_cnt)                       ,
        .counter_detect_edge_i(counter_detect_edge)                 ,
        .prescaler_i(prescaler_i)                                   ,
        .counter_state_done_time_repeat_start_i(counter_state_done_time_repeat_start),
        .sda_o(temp_sda_o)                                          ,
        .data_o(data_o)                                             ,
        .counter_data_ack_o(counter_data_ack)
    );

    i2c_fsm_block fsm_block(
        .i2c_core_clock_i(i2c_core_clock_i)                             ,	// i2c core clock
        .enable_bit_i(enable_bit_i)                                     , // enable bit from cmd register                  
        .reset_bit_i(reset_bit_i)                                       , // reset bit from cmd register	
        .rw_bit_i(addr_rw_i[0])                                         , //addr of slave and rw bit
        .sda_i(sda_i)                                                   , // sda line input	
        .repeat_start_bit_i(repeat_start_bit_i)                         ,	// repeat start bit from cmd register					         
        .trans_fifo_empty_i(trans_fifo_empty_i)                         ,	// status of trans fifo from fifo block 					         
        .rev_fifo_full_i(rev_fifo_full_i)                               , // status of rev fifo from fifo block
        .state_done_time_i(state_done_time_i)                           , //state done time 
        .counter_detect_edge_i(counter_detect_edge)                     , //counter detect edge from clock generator
        .counter_data_ack_i(counter_data_ack)                           , //counter data, ack from datapath
        .prescaler_i(prescaler_i)                                       , //value of prescaler register
        //---------------------------------------------------------             //----------------------output---------------
                                        
        .start_cnt_o(start_cnt)                                         ,	// start signal to datapath and clock generator						    
        .write_addr_cnt_o(write_addr_cnt)                               ,	// write addr signal to datapath and clock generator to transfer addr of slave												
        .write_data_cnt_o(write_data_cnt)                               ,	// write data signal to datapath and clock generator to transfer data 						
        .read_data_cnt_o(read_data_cnt)                                 , // read data signal to datapath and clock generator to read data 
        .write_ack_cnt_o(write_ack_cnt)                                 ,	// after read data is done, master send ack bit					
        .read_ack_cnt_o(read_ack_cnt)                                   ,	//read ack from slave
        .stop_cnt_o(stop_cnt)                                           ,	// stop signal to datapath and clock generator 	
        .repeat_start_cnt_o(repeat_start_cnt)                           , // repeat start signal to datapath and clock generator					    
        .scl_en_o(scl_en)				                                , // enable scl
        .sda_en_o(sda_en)                                               ,  // enable sda 	
        .counter_state_done_time_repeat_start_o(counter_state_done_time_repeat_start)
    );
endmodule