module i2c_master_fsm (
    input           enable_i            ,   // enable signal from MCU
    input           reset_ni            ,   // reset negative signal from MCU
    input           repeat_start_i      ,   // repeat start signal from MCU
    input           rw_i                ,   // bit 1 is read - 0 is write
    input           full_i              ,   // FIFO buffer is full
    input           empty_i             ,   // FIFO buffer is empty
    input           i2c_core_clk_i      ,   // i2c core clock
    input           i2c_sda_i           ,   // i2c sda feedback to FSM
    input           i2c_scl_i           ,   // i2c scl feedback to FSM

    output          w_fifo_en_o         ,   //  enable write data into fifo memory
    output          r_fifo_en_o         ,   //  enable read data from fifo memory

    output	    reg             sda_low_en_o        ,   // when = 1 enable sda down 0
    output	    reg             clk_en_o            ,   // enbale to generator clk
    output	    reg             write_data_en_o     ,   // enable write data on sda
    output	    reg             write_addr_en_o     ,   // enable write address of slave on sda
    output	    reg             receive_data_en_o   ,   // enable receive data from sda
    output              [3:0]   count_bit_o         ,   // count bit data from 7 down to 0
    output	    reg             i2c_sda_en_o        ,   // allow impact to sda
    output	    reg             i2c_scl_en_o        ,   // allow impact to scl 
    output                      start_done_o        ,   // state-start done
    output                      reset_done_o            
);

    // State
    parameter   IDLE            =   4'b0000   ;
    parameter   START           =   4'b0001   ;
    parameter   ADDRESS         =   4'b0010   ;
    parameter   READ_ACK        =   4'b0011   ;
    parameter   WRITE_DATA      =   4'b0100   ;
    parameter   READ_LATER_ACK  =   4'b0101   ;

    parameter   READ_DATA       =   4'b0110   ;
    parameter   WRITE_ACK       =   4'b0111   ;

    parameter   REPEAT_START    =   4'b1000   ;
    parameter   STOP            =   4'b1001   ;

    // Declare current state, next state
    reg     [3:0]       currrent_state              ;
    reg     [3:0]       next_sate                   ;

    // Declare count value
    //reg     [2:0]       count_clk_core              ;
    reg                 confirm                     ;   // when i2c_scl_i from 1 down to 0, confirm = 1 
    reg     [3:0]       count_scl_posedge           ;
    reg     [3:0]       count_scl_posedge_temp      ;
    reg     [3:0]       count_bit                   ;
	reg		read_ack_to_read_done	                ;
	reg		read_ack_to_write_done	                ;
    reg     scl_later		                        ;
    wire    scl_positive	                        ;
	wire	scl_negative	                        ;


    // Declare register of ouput
    reg                 w_fifo_en                               ;
    reg                 r_fifo_en                               ;
    reg                 start_done                              ;
    reg                 reset_done                              ;

    assign              count_bit_o         =   count_bit       ;
    assign              w_fifo_en_o         =   w_fifo_en       ;
    assign              r_fifo_en_o         =   r_fifo_en       ;
    assign              start_done_o        =   start_done      ;
    assign              reset_done_o        =   reset_done      ;

    // Current State register logic
    always @ (posedge i2c_core_clk_i,   negedge reset_ni) begin
        if (~reset_ni) begin

            currrent_state      <=  IDLE        ;
            reset_done          <=  1           ;

        end

        else begin

            currrent_state  	<=  next_sate   ;
            reset_done          <=  0           ;

        end

    end

    // Next state comnibational logic
    always @ (*)    begin

        case (currrent_state)

            IDLE    :   begin
                
                if (enable_i ) begin
                    next_sate   =   START      ;
                end
                else begin
                    next_sate   =   IDLE       ;
                end

            end


            START   :   begin

				if (i2c_scl_i == 0) begin                           //  Wait for scl low, and then to next sate

                	next_sate           =   ADDRESS             ;

                end

                else begin

                    next_sate           =   START               ;

                end

            end


            ADDRESS :   begin

                //When the 8 bits data have been transmitted, 
                //wait for the scl line is low and then move to the next state
                if (count_scl_posedge == 8 && scl_negative == 1) begin
                    next_sate   =   READ_ACK    ;
                end
                else begin
                    next_sate   =   ADDRESS     ;
                end 

            end

            READ_ACK    :   begin

				// When have an ACK or NACK, wait for scl is negedge and then to next state
                if ((scl_negative == 1) && (read_ack_to_read_done == 0 && read_ack_to_write_done == 0)) begin

                    next_sate   =   STOP    ;

                end

				else if ((scl_negative == 1) && (read_ack_to_read_done == 1)) begin

					next_sate       		=   READ_DATA	;

				end

				else if ((scl_negative == 1) && (read_ack_to_write_done == 1)) begin

					next_sate       		=    WRITE_DATA   ;

				end				

                else begin
                    next_sate     =       READ_ACK    ;
                end

            end

            WRITE_DATA  :   begin

                //When the 8 bits data have been transmitted, 
                //wait for the scl line is high and then move to the next state
                if (count_scl_posedge == 8 && scl_negative == 1) begin

                    next_sate   =   READ_LATER_ACK              ;

                end 

                else begin

                    next_sate   =   WRITE_DATA                  ;

                end

            end

            READ_LATER_ACK  :   begin

                if (repeat_start_i) begin

                    next_sate   =   REPEAT_START                ;

                end

				else if ((scl_negative == 1) && ((empty_i == 1) || (read_ack_to_write_done == 0))) begin

					next_sate	=	STOP	                    ;

				end

				else if ((scl_negative) && (read_ack_to_write_done == 1)) begin		// wait for scl low and then to next state

					next_sate				=	WRITE_DATA		;

				end
		
                else begin

                    next_sate           =       READ_LATER_ACK  ;

                end

            end

            READ_DATA   :   begin

                if (count_scl_posedge == 8 && scl_negative == 1) begin
                    next_sate       =       WRITE_ACK       ;
                    
                end 
                else begin
                    next_sate       =       READ_DATA       ;
                end

            end

            WRITE_ACK   :   begin

				if (scl_negative) begin

                	if (repeat_start_i) begin
                    	next_sate       =      REPEAT_START     ; 
                	end 
                	else if (full_i == 0) begin
                    	next_sate       =       READ_DATA       ;
                	end
                	else begin
                    	next_sate       =       STOP            ;
                	end

				end
				else begin
					next_sate		=		WRITE_ACK		;
				end

            end

            REPEAT_START    :    begin
                if (scl_positive) begin
                    next_sate           =       START         ;
                end
                else begin
                    next_sate           =       REPEAT_START    ;
                end

            end

            STOP    :   begin

				if (scl_positive) begin
                	next_sate           	=       IDLE            ;
				end
				else begin
					next_sate				=		STOP			;
				end

            end


            default: next_sate      	=       IDLE            ;
        endcase

    end

    // Output and internal signal combinational logic
    always @(*) begin
        
        case (currrent_state)
            
            IDLE            :   begin
                //  Output
                clk_en_o            =       0           ;
                sda_low_en_o        =       0           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       0           ;
                i2c_scl_en_o        =       0           ;

                //  Internal signal
                start_done              =   0           ;
            end

            //-------------------------------------------------------
            START           :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       1           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       1           ;
                i2c_scl_en_o        =       1           ;
                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            ADDRESS         :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       0           ;
                write_data_en_o     =       0           ;
                receive_data_en_o   =       0           ;

                //when scl is low, we can write address of slave on sda line
                if (i2c_scl_i == 0)    
                    write_addr_en_o     =       1       ;
                else    
                    write_addr_en_o     =       0       ;

				i2c_sda_en_o    		=       1       ;
                i2c_scl_en_o        	=       1       ;
                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            READ_ACK        :   begin
                // Output
                clk_en_o            =       1           ;
                sda_low_en_o        =       0           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       0           ;
                i2c_scl_en_o        =       1           ;

                //Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            WRITE_DATA      :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;

                //when scl is low, we can write data on sda line
                if (i2c_scl_i == 0)    
                    write_data_en_o     =       1           ;
                else    
                    write_data_en_o     =       0           ;

				i2c_sda_en_o    		=       1           ;
                i2c_scl_en_o        	=       1           ;
                                
                //  Internal signal
                start_done              =   1           ;                
            end

            //-------------------------------------------------------
            READ_LATER_ACK  :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       1           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       0           ;
                i2c_scl_en_o        =       1           ;

                // Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            READ_DATA       :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       0           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;

                //when scl is hight, we can receive data from sda
                if (i2c_scl_i)    
                    receive_data_en_o   =       1       ;
                else    
                    receive_data_en_o   =       0       ;

                i2c_sda_en_o        =       0           ;
                i2c_scl_en_o        =       1           ;
                                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            WRITE_ACK       :   begin
                clk_en_o            =       1           ;
                sda_low_en_o        =       1           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       1           ;
                i2c_scl_en_o        =       1           ;
                                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            REPEAT_START    :   begin
                clk_en_o            =       1           ;
				sda_low_en_o    	=       0           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       0           ; // off i2c_sda_en to pull sda upto 1
                i2c_scl_en_o        =       1           ;
                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            STOP            :   begin
                clk_en_o            =       1           ;
                if (i2c_sda_i == 1) begin                   //  If sda is high, we will set sda to low
                    sda_low_en_o    =       1           ;
                end
                else begin
                    sda_low_en_o    =       0           ;
                end
                
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       1           ;
                i2c_scl_en_o        =       1           ;
                                
                //  Internal signal
                start_done              =   1           ;
            end

            //-------------------------------------------------------
            default         :   begin
                clk_en_o            =       0           ;
                sda_low_en_o        =       0           ;
                write_data_en_o     =       0           ;
                write_addr_en_o     =       0           ;
                receive_data_en_o   =       0           ;
                i2c_sda_en_o        =       0           ;
                i2c_scl_en_o        =       0           ;
                                
                //  Internal signal
                start_done              =   0           ;
            end
        endcase

    end

    //--------------------------------------------------------------------
    // Detect positive scl

    always @(posedge    i2c_core_clk_i, negedge     reset_ni) begin
        if (~reset_ni) begin
            scl_later   <=  1              ;
        end
        else begin
            scl_later   <=  i2c_scl_i       ;
        end
    end

    assign  scl_positive = i2c_scl_i & (~scl_later) 	;
	assign 	scl_negative = (~i2c_scl_i) & (scl_later)	;

    // end detect positive scl
    //------------------------------------------------------------------------
    
    // Handle count_scl_posedge
    always @(*) begin
        if (currrent_state  ==  ADDRESS  || currrent_state == READ_DATA  ||  currrent_state  ==  WRITE_DATA) begin
            //count_scl_posedge   =   scl_positive ? (count_scl_posedge + 1) : count_scl_posedge  ;
            if (scl_positive) begin
                count_scl_posedge   =   count_scl_posedge   +   1   ;
            end
            else begin
                count_scl_posedge   =   count_scl_posedge_temp      ;
            end

        end
        else begin
            count_scl_posedge   =   0   ;
        end
    end


    // Handle read/write-enbale signal to FIFO and count posedge of clock core
    always @ (posedge i2c_core_clk_i	, negedge reset_ni) begin
        if (~reset_ni) begin
            r_fifo_en               <=  0              	;
			w_fifo_en	            <=	0				;
            count_scl_posedge_temp  <=  0               ;
            count_bit               <=  0               ;
            read_ack_to_read_done	<=	0               ;
            read_ack_to_write_done	<=	0               ;
            
        end
        else begin
            count_scl_posedge_temp  <=  count_scl_posedge   ;
			// enable read/ write data from/to FIFO when READ_LATER_ACK state and WRITE_ACK state
			// at frist READ_ACK state , data is always valid, do not enable read.
            if ((currrent_state == READ_LATER_ACK) && (scl_positive == 1)) begin
				r_fifo_en   <=  1           ;
			end
			else begin
				r_fifo_en	<=	0	        ;
			end

			if ((currrent_state == WRITE_ACK) && (scl_positive == 1)) begin
				w_fifo_en   <=  1           ;
			end
			else begin
				w_fifo_en	<=	0	        ;
			end

            // Handle count_bit to transfer to datapath
            if (currrent_state  ==  ADDRESS  || currrent_state  ==  WRITE_DATA) begin

            // Each postitive of scl, if count_bit != 0 , reduce count_bit by 1
                count_bit     <=   (count_bit_o != 0 && scl_positive) ? (count_bit - 1) : count_bit  ;

            end

            else if (currrent_state == READ_DATA) begin

                // Each negative of scl, if count_bit != 0 , reduce count_bit by 1
                count_bit     <=   (count_bit_o != 0 && scl_negative) ? (count_bit - 1) : count_bit   ;

            end

            else begin
                count_bit     <=   7           ;
            end

            // Handle internal signal : read_ack_to_read/write_done
            if ((currrent_state == READ_ACK) || (currrent_state == READ_LATER_ACK)) begin
                if (scl_positive == 1 && i2c_sda_i == 0 && rw_i == 1 && full_i == 0) begin    

                    read_ack_to_read_done	<=	1         ; 
                    read_ack_to_write_done	<=	0         ;

                end

                else if (scl_positive == 1 && i2c_sda_i == 0 && rw_i == 0 && empty_i == 0) begin

                    read_ack_to_read_done	<=	0        ;
                    read_ack_to_write_done	<=	1        ;

                end
            end
            else begin
                read_ack_to_read_done	<=	0        ;
                read_ack_to_write_done	<=	0        ;
            end

        end

    end

endmodule