module i2c_clock_gen_block(
    input i2c_core_clock_i                                                                  , //i2c core clock
    input reset_bit_i                                                                       , //reset signal from cpu
    input [7:0] prescaler_i                                                                 , //value of prescaler register
    output scl_o                                                                            , //clock output from clock generator
    output reg [7:0] counter_detect_edge_o                                                  //counter for detecting edge of scl, 
);
    reg [7:0] counter_prescaler_clock                                                       ; // counter i2c core clock to generate scl clock
    reg temp_scl_o                                                                          ; // temp variable
    assign scl_o = temp_scl_o                                                               ; // update sda output clock

    //count i2c core clock, scl get positive edge when counter detect edge = 2 * prescaler - 1, opposite, counter detect edge = prescaler - 1 
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i )
            counter_detect_edge_o <= 2 * prescaler_i - 1                                    ;
        else
            if (counter_detect_edge_o == 0)   
                counter_detect_edge_o <= 2 * prescaler_i - 1                                ;
            else
                counter_detect_edge_o <= counter_detect_edge_o - 1                          ;
    end

    //counter i2c core clock to generate scl clock
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            counter_prescaler_clock <= prescaler_i - 1                                      ;
        else
            if (counter_prescaler_clock == 0)
                counter_prescaler_clock <= prescaler_i - 1                                  ;
            else
                counter_prescaler_clock <= counter_prescaler_clock - 1                      ;
    end

    //gen scl clock
    always @(posedge i2c_core_clock_i, negedge reset_bit_i) 
    begin
        if (~reset_bit_i)
            temp_scl_o <= 1                                                                 ;
        else    
            if (counter_prescaler_clock == 0)
                temp_scl_o <= ~temp_scl_o                                                   ;
            else    
                temp_scl_o <= temp_scl_o                                                    ;
    end


endmodule