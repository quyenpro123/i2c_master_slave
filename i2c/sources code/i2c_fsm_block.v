module i2c_fsm_block(
    //---------------------------------------------------------            //----------------------input---------------
    input i2c_core_clock_i                                                                  ,	// i2c core clock
    input enable_bit_i                                                                      , // enable bit from cmd register                  
    input reset_bit_i                                                                       , // reset bit from cmd register	
    input rw_bit_i                                                                          , //rw bit from addr_rw_bit register   
    input sda_i                                                                             , // sda line input	
    input repeat_start_bit_i                                                                ,	// repeat start bit from cmd register					         
    input trans_fifo_empty_i                                                                ,	// status of trans fifo from fifo block 					         
    input rev_fifo_full_i                                                                   , // status of rev fifo from fifo block
    input [7:0] state_done_time_i                                                           , //state done time 
    input [7:0] counter_detect_edge_i                                                       , //counter detect edge from clock generator
    input [7:0] counter_data_ack_i                                                          , //counter data, ack from datapath
    input [7:0] prescaler_i                                                                 , //value of prescaler register
    input       read_almost_empty_i                                                         ,
    //---------------------------------------------------------             //----------------------output---------------
    							    
    output reg start_cnt_o                                                                  ,	// start signal to datapath and clock generator						    
    output reg write_addr_cnt_o                                                             ,	// write addr signal to datapath and clock generator to transfer addr of slave												
    output reg write_data_cnt_o                                                             ,	// write data signal to datapath and clock generator to transfer data 						
    output reg read_data_cnt_o                                                              , // read data signal to datapath and clock generator to read data 
    output reg write_ack_cnt_o                                                              ,	// after read data is done, master send ack bit					
    output reg read_ack_cnt_o                                                               ,	//read ack from slave
    output reg stop_cnt_o                                                                   ,	// stop signal to datapath and clock generator 	
    output reg repeat_start_cnt_o                                                           , // repeat start signal to datapath and clock generator
    
    output reg write_fifo_en_o                                                              , //signal that datapath write data which read recently into receive fifo
    output reg read_fifo_en_o                                                               , //signal that datapath read data which cpu want to send to i2c slave from transmit fifo
    					    
    output reg scl_en_o				                                                        , // enable scl
    output reg sda_en_o                                                                     , // enable sda 	
    output reg [7:0] counter_state_done_time_repeat_start_o                                   //for state: repeat start
    //---------------------------------------------------------
);
    localparam IDLE = 0							                                            ;
    localparam START = 1 							                                        ;
    localparam ADDR = 2							                                            ;
    localparam read_addr_ack = 3						                                    ;
    localparam write_data = 4						                                        ;
    localparam read_data = 5						                                        ;
    localparam read_data_ack = 6						                                    ;
    localparam write_data_ack = 7						                                    ;
    localparam repeat_start = 8						                                        ;
    localparam stop = 9							                                            ;


    reg [3:0] current_state       	               		                                    ;
    reg [3:0] next_state                    					                            ;
    reg [7:0] counter_state_done_time_start_stop    						                ; //for state: start, stop
    
    
     // counter state done time for start, stop condition
     always @(posedge i2c_core_clock_i, negedge reset_bit_i)
     begin
        
        if (~reset_bit_i)
            counter_state_done_time_start_stop <= state_done_time_i                                                                 ;
        else                         
                if (current_state == IDLE                                                                                            //in IDLE state, when master get enable bit-- 
                    && enable_bit_i == 1 && counter_state_done_time_start_stop != 0)                                                 //--start counter clock (detail in current_state and input to next_state)
                    counter_state_done_time_start_stop <= counter_state_done_time_start_stop - 1                                    ;
                else if ((current_state == START || current_state == stop)
                        && counter_state_done_time_start_stop != 0 && counter_detect_edge_i > (prescaler_i - 1))                     //in start or stop state, start counter clock 
                    counter_state_done_time_start_stop <= counter_state_done_time_start_stop - 1                                    ;
                else if (counter_state_done_time_start_stop == 0 
                        || (current_state == ADDR && counter_state_done_time_start_stop == 1))   
                    counter_state_done_time_start_stop <= state_done_time_i                                                         ;
                else
                    counter_state_done_time_start_stop <= counter_state_done_time_start_stop                                        ;
    end
    
    // counter state done time for repeat start condition
     always @(posedge i2c_core_clock_i, negedge reset_bit_i)
     begin
        
        if (~reset_bit_i)
            counter_state_done_time_repeat_start_o <= (2 * prescaler_i - 1)                                                         ;
        else
            if (current_state == repeat_start
                    && counter_state_done_time_repeat_start_o != 0 && counter_detect_edge_i > (prescaler_i - 1))                      //in repeat_start state, start counter clock 
                counter_state_done_time_repeat_start_o <= counter_state_done_time_repeat_start_o - 1                                ;
            else if (next_state == repeat_start && (current_state == read_data_ack || current_state == read_addr_ack))   
                counter_state_done_time_repeat_start_o <= (2 * prescaler_i - 1)                                                     ;
            else if (next_state == repeat_start && current_state == write_data_ack)
                counter_state_done_time_repeat_start_o <= prescaler_i + 1                                                           ;
            else
                counter_state_done_time_repeat_start_o <= counter_state_done_time_repeat_start_o                                    ;
    end
    
    //output control signals to trans fifo block
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            read_fifo_en_o <= 0                                                                                                     ;
        else
            begin
                if (next_state == write_data && (current_state == read_addr_ack || current_state == read_data_ack) && read_almost_empty_i == 0)                   //prepare data from trans fifo to send to slave
                    read_fifo_en_o <= 1                                                                                             ;
                else
                    read_fifo_en_o <= 0                                                                                             ;
            end
    end

    //output control signals to receive fifo block
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            write_fifo_en_o <= 0                                                                                                     ;
        else
            begin
                if (next_state == write_data_ack && current_state == read_data )                                                      //prepare data from trans fifo to send to slave
                    write_fifo_en_o <= 1                                                                                             ;
                else
                    write_fifo_en_o <= 0                                                                                             ;
            end
    end
    
     //register state logic
    always @(posedge i2c_core_clock_i, negedge reset_bit_i)
    begin
        
        if (~reset_bit_i)
                current_state <= IDLE					                                                ;		
        else
            if (next_state == stop && (current_state == read_addr_ack || current_state == read_data_ack))
                if (counter_data_ack_i == 9 && counter_detect_edge_i == prescaler_i)
                    current_state <= next_state				                                            ; //update current state
                else
                    current_state <= current_state                                                      ;
            else
                current_state <= next_state                                                             ; //update current state
    end
    //current_state and input to next_state
    always @*
    begin
        case (current_state)
            //---------------------------------------------------------
            IDLE: begin
                if (enable_bit_i && counter_state_done_time_start_stop == 0)                                         // hold 4 cylcle i2c core clock before transfer to next state
                    next_state = START                                                                  ;
                else
                    next_state = IDLE                                                                   ;
            end     
            //----------------------------------------------------------
            START: begin                                                                                //hold 4 cylcle i2c core clock before transfer to next state
                if (counter_state_done_time_start_stop == 1)
                    next_state = ADDR                                                                   ;
                else
                    next_state = START                                                                  ;
            end
            //---------------------------------------------------------
            ADDR: begin
                if (counter_data_ack_i == 1)
                    next_state = read_addr_ack                                                          ;
                else
                    next_state = ADDR                                                                   ;
            end 
            //---------------------------------------------------------
            read_addr_ack: begin                                                                        //read ack when scl is positive edge
                if (counter_data_ack_i == 0)
                    begin
                        if (sda_i == 1)
                            if (repeat_start_bit_i == 1)
                                  next_state = repeat_start                                             ;
                            else
                                  next_state = stop                                                     ;
                        else
                            if (rw_bit_i == 1)
                              next_state = read_data                                                    ;
                            else
                              next_state = write_data                                                   ;
                    end
                else if (next_state == stop)
                    next_state = next_state                                                             ;
                else
                    next_state = read_addr_ack                                                          ;
            end
            //---------------------------------------------------------
            write_data: begin                                                                           //write data   
                if (counter_data_ack_i == 1)
                    next_state = read_data_ack                                                          ;
                else
                    next_state = write_data                                                             ;
            end 
            //---------------------------------------------------------
            read_data: begin                                                                             //read data  
                if (counter_data_ack_i == 1)                          
                    next_state = write_data_ack                                                         ;
                else
                    next_state = read_data                                                              ;
            end
            //---------------------------------------------------------
            read_data_ack: begin                                                                         // read ack from slave
                if (counter_data_ack_i == 0)
                        if (trans_fifo_empty_i == 1 || sda_i == 1)
                            if (repeat_start_bit_i == 1)
                              next_state = repeat_start                                                 ;
                            else
                              next_state = stop                                                         ;
                        else
                            next_state = write_data                                                     ;
                else if (next_state == stop)
                    next_state = next_state                                                             ;
                else
                    next_state = read_data_ack                                                          ;
                
            end
            //---------------------------------------------------------
            write_data_ack: begin                                                                         //if rev fifo is not full, continue read data
                if (counter_data_ack_i == 9 && counter_detect_edge_i == prescaler_i) 
                    if (rev_fifo_full_i == 0 )
                            next_state = read_data                                                      ;
                    else
                        if (repeat_start_bit_i == 1)                
                            next_state = repeat_start                                                   ;
                        else 
                            next_state = stop                                                           ;
                else
                    next_state = write_data_ack                                                         ;
            end
            //---------------------------------------------------------
            repeat_start: begin
                 if (counter_state_done_time_repeat_start_o == 0)
                    next_state = ADDR                                                                   ;
                else
                    next_state = repeat_start                                                           ;
            end
            //---------------------------------------------------------
            stop: begin
                if (counter_state_done_time_start_stop == 0)
                    next_state = IDLE                                                                   ;
                else
                    next_state = stop                                                                   ;
            end 
            //---------------------------------------------------------
            default: begin
                next_state = IDLE                                                                       ;
            end
        endcase
        
    
    end
    //current state to output
    always @*
    begin
//         sda_en_o = 0                                                ;     
//         scl_en_o = 0                                                ;
        case (current_state)
            //---------------------------------------------------------
            IDLE: begin
                sda_en_o = 0                                                ;     
                scl_en_o = 0                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;                          					
            end
            //---------------------------------------------------------
            START: begin  
                if (counter_detect_edge_i <= (2 * prescaler_i - 3))
                    sda_en_o = 1                                            ;
                else
                    sda_en_o = sda_en_o                                     ;    
                scl_en_o = 0                                                ;	
                start_cnt_o = 1                                             ; //fsm inform to data_path and clock_gen generate start condition                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            end
            //---------------------------------------------------------
            ADDR: begin
                sda_en_o = 1                                                ;     
                scl_en_o = 1                                                ;
                start_cnt_o = 0                                             ;
                write_addr_cnt_o = 1                                        ; //signal to datapath write addr of slave in sda line                                            							
                write_ack_cnt_o = 0                                         ;   
                read_ack_cnt_o = 0                                          ;                                             							                                          							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            
            end
            //---------------------------------------------------------
            read_addr_ack: begin
                if (counter_detect_edge_i == (prescaler_i - 2))
                    sda_en_o = 0                                            ;
                else
                    sda_en_o = sda_en_o                                     ;
                scl_en_o = 1                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 1                                          ;                                             							                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            end
            //---------------------------------------------------------
            write_data: begin
                if (counter_detect_edge_i == (prescaler_i - 3))
                    sda_en_o = 1                                            ;
                else
                    sda_en_o = sda_en_o                                     ;      
                scl_en_o = 1                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							                                             							
                write_data_cnt_o = 1                                        ; //signal to datapath write data in sda line                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            end
            //---------------------------------------------------------
            read_data: begin
                sda_en_o = 0                                                ;      
                scl_en_o = 1                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 1                                         ; //signal to datapath read data in sda line when scl in positive edge                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;        
            end
            //---------------------------------------------------------
            read_data_ack: begin
                if (counter_detect_edge_i == (prescaler_i - 2))
                    sda_en_o = 0                                            ;
                else
                    sda_en_o = sda_en_o                                     ;      
                scl_en_o = 1                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 1                                          ;                                             							                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            end
            //---------------------------------------------------------
            write_data_ack: begin
                if (counter_detect_edge_i == (prescaler_i - 3))
                    sda_en_o = 1                                            ;
                else
                    sda_en_o = sda_en_o                                     ;       
                scl_en_o = 1                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 1                                         ; //signal to data_path write ack in sda line
                read_ack_cnt_o = 0                                          ;                                             							                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;                                          					
            end
            //---------------------------------------------------------
            repeat_start: begin
                if (counter_detect_edge_i == (prescaler_i - 2))
                    sda_en_o = 1                                            ;
                else
                    sda_en_o = sda_en_o                                     ;      
                if (counter_state_done_time_repeat_start_o < prescaler_i)
                    scl_en_o = 0                                            ;
                else
                    scl_en_o = scl_en_o                                     ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 1                                      ; //signal to both data_path and clock_gen to generate repeat start condition  
            end
            //---------------------------------------------------------
            stop: begin
                if (counter_detect_edge_i == (prescaler_i - 3))
                    sda_en_o = 1                                            ;
                else
                    sda_en_o = sda_en_o                                     ;
                if (counter_detect_edge_i == (2 * prescaler_i - 2) )
                    scl_en_o = 0                                            ;
                else
                    scl_en_o = scl_en_o                                     ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;
                read_ack_cnt_o = 0                                          ;                                             							                                             							
                write_data_cnt_o = 0                                        ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 1                                              ; //signal to both data_path and clock_gen to generate stop condition                                                   						    
                repeat_start_cnt_o = 0                                      ;                                          					
            end
            //---------------------------------------------------------
             default: begin
                sda_en_o = 0                                                ; 
                scl_en_o = 0                                                ;			
                start_cnt_o = 0                                             ;                                                						    
                write_addr_cnt_o = 0                                        ;                                            							
                write_ack_cnt_o = 0                                         ;                                             							
                write_data_cnt_o = 0                                        ;
                read_ack_cnt_o = 0                                          ;                                            							
                read_data_cnt_o = 0                                         ;                                             						
                stop_cnt_o = 0                                              ;                                                   						    
                repeat_start_cnt_o = 0                                      ;
            end
        endcase
    end
    
endmodule 