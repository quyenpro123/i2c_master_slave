module i2c_register_block(
    //-------------------------------slave apb - master apb--------------------------------------------------
    input                  pclk_i                                                       , //clock 
    input                  preset_n_i                                                   , //reset signal
    input                  penable_i                                                    , //enable signal from master to slave
    input                  psel_i                                                       , //select signal from master to slave
    input      [7:0]       paddr_i                                                      , //address master send to slave
    input      [7:0]       pwdata_i                                                     , //data master send to slave
    input                  pwrite_i                                                     , //read/write signal from master
         
    output reg [7:0]       prdata_o                                                     , //data slave send to master
    output reg             pready_o                                                     , //ready signal slave send to master

    //-------------------------------register block - i2c core--------------------------------------------------
    input      [7:0]       receive_i                                                    , //receive data input from receive fifo
    input      [7:0]       status_i                                                     , //status input from i2c core, written by i2c core
    output     [7:0]       prescaler_o                                                  , //output of prescaler register
    output     [7:0]       cmd_o                                                        , //output of cmd register
    output     [7:0]       address_rw_o                                                 , //output of address_rw register
    output     [7:0]       transmit_o                                                   , //output of transmit register for transmit fifo   
    output reg             tx_fifo_write_enable_o                                       ,    
    output reg             rx_fifo_read_enable_o                                        
);
    //internal register
    reg [7:0] prescaler                                                                 ; //0x00
    reg [7:0] cmd                                                                       ; //0x01
    reg [7:0] transmit                                                                  ; //0x02
    reg [7:0] receive                                                                   ; //0x03
    reg [7:0] address_rw                                                                ; //0x04
    reg [7:0] status                                                                    ; //0x05
    reg [2:0] counter_read                                                              ; 
    

    assign prescaler_o = prescaler                                                      ; //update output of register internal
    assign cmd_o = cmd                                                                  ;
    assign address_rw_o = address_rw                                                    ;
    assign transmit_o = transmit                                                        ;

    always @(posedge pclk_i) 
    begin
        if (~preset_n_i)
            begin
                //reset internal register
                prescaler <= 0                                                          ; 
                cmd <= 0                                                                ;
                transmit <= 0                                                           ;
                receive <= 0                                                            ;
                address_rw <= 0                                                         ;
                status <= 0                                                             ;
                //reset output apb interface
                prdata_o <= 0                                                           ;
                pready_o <= 1                                                           ;
                counter_read <= 0                                                       ;
                tx_fifo_write_enable_o <= 0                                             ;
                rx_fifo_read_enable_o <= 0                                              ;
            end
        else
            begin
                if (psel_i == 1 && penable_i == 0)
                    begin
                        counter_read <= 0                                               ;
                        if (pwrite_i == 0)
                        begin
                            if (paddr_i == 8'h03)
                                rx_fifo_read_enable_o <= 1                              ;
                            counter_read <= counter_read + 1                            ; 
                        end
                    end
                else if (psel_i == 1 && penable_i == 1)
                    begin
                        if (pwrite_i == 1)
                            case (paddr_i)
                                8'h00:                                                        //write to prescaler register                                 
                                    prescaler <= pwdata_i                               ;
                                8'h01:                                                        //write to cmd register                                                 
                                    cmd <= pwdata_i                                     ;                                
                                8'h02:                                                        //write to transmit register
                                begin                                                                           
                                    transmit <= pwdata_i                                ;
                                    tx_fifo_write_enable_o <= 1                         ;
                                end
                                //8'h03:                                                       receive register is read only for cpu                                                 
                              
                                8'h04:                                                        //write to address register                                                         
                                    address_rw <= pwdata_i                              ;
                                //8'h05:                                                       //status register is read only for cpu                       
                            endcase
                            
                        if (pwrite_i == 0)
                            counter_read <= counter_read + 1                            ;
                            case (paddr_i)
                                8'h00:                                                        //read from prescaler register                                 
                                    prdata_o <= prescaler                               ;
                                8'h01:                                                        //read from cmd register                                                 
                                    prdata_o <= cmd                                     ;
                                8'h02:                                                        //read from transmit register                                                                           
                                    prdata_o <= transmit                                ;
                                8'h03: 
                                begin                                                       //read from receive register                                             
                                    prdata_o <= receive                                 ;
                                    rx_fifo_read_enable_o <= 0                          ;
                                end
                                8'h04:                                                        //read from address register                                                         
                                    prdata_o <= address_rw                              ;
                                8'h05:                                                        //read from status register                    
                                    prdata_o <= status                                  ;
                            endcase
                    end
                else if (psel_i == 0 && penable_i == 0)
                    begin   
                        tx_fifo_write_enable_o <= 0                                         ;
                        if (counter_read > 1)
                            counter_read <= counter_read + 1                                ;
                        else 
                            prdata_o <= 0                                                   ;
                    end
            end
    end
endmodule