module i2c_data_path_block (
    input i2c_core_clock_i                                                                  ,
    input reset_bit_i                                                                       ,
    input sda_i                                                                             ,
    input [7:0] data_i                                                                      ,
    input [7:0] addr_rw_i                                                                   ,
    input ack_bit_i                                                                         ,
    input start_cnt_i                                                                       ,						    
    input write_addr_cnt_i                                                                  ,
    input write_data_cnt_i                                                                  ,	 						
    input read_data_cnt_i                                                                   , 
    input write_ack_cnt_i                                                                   ,
    input read_ack_cnt_i                                                                    ,
    input stop_cnt_i                                                                        ,	
    input repeat_start_cnt_i                                                                ,
    input [7:0] counter_state_done_time_repeat_start_i                                      , 					    
    input [7:0] counter_detect_edge_i                                                       ,
    input [7:0] prescaler_i                                                                 ,

    output sda_o                                                                            ,
    output reg [7:0] data_o                                                                 ,
    output reg [7:0] counter_data_ack_o                                           
);
    reg temp_sda_o                                                                          ;
    assign sda_o = temp_sda_o                                                               ; //update sda
    
    //handle counter data, ack
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i || counter_data_ack_o == 0)
            counter_data_ack_o <= 9                                                         ;
        else if (counter_detect_edge_i == (2 * prescaler_i - 1) &&                           //when posedge of scl
                (write_addr_cnt_i || write_ack_cnt_i ||
                read_data_cnt_i || write_data_cnt_i || read_ack_cnt_i))
            
            counter_data_ack_o = counter_data_ack_o - 1                                     ;
    end

    //handle sda when datapath write
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            temp_sda_o <= 1                                                                 ;  
        else
            begin
                if (start_cnt_i == 1)
                    temp_sda_o <= 0                                                             ;
                else if (write_addr_cnt_i && counter_detect_edge_i == (prescaler_i - 2))        // write addr after negedge of scl 1 i2c core clock        
                    temp_sda_o <= addr_rw_i[counter_data_ack_o - 2]                             ;
                else if (write_data_cnt_i && counter_detect_edge_i == (prescaler_i - 2))        // write data after negedge of scl 1 i2c core clock            
                    temp_sda_o <= data_i[counter_data_ack_o - 2]                                ;
                else if (write_ack_cnt_i && counter_detect_edge_i == (prescaler_i - 2))         // write ack after negedge of scl 1 i2c core clock
                    temp_sda_o <= ack_bit_i                                                     ;
                else if (stop_cnt_i && counter_detect_edge_i == (prescaler_i - 2))                  
                    temp_sda_o <= 0                                                             ;
                else if (repeat_start_cnt_i)                                                    //not handle yet
                    if (counter_state_done_time_repeat_start_i > 1)
                        temp_sda_o <= 1                                                         ;
                    else if (counter_state_done_time_repeat_start_i == 1)
                        temp_sda_o <= 0                                                         ;
                  
            end
    end

    //handle when datapath read
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            data_o <= 0                                                                     ;
        else
            if (read_data_cnt_i && 
                counter_detect_edge_i == (2 * prescaler_i - 1))
                
                data_o[counter_data_ack_o - 2] <= sda_i                                     ;
    end


endmodule