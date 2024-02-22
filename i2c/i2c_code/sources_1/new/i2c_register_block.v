module i2c_register_block(
    //-------------------------------slave apb - master apb--------------------------------------------------
    input                  PCLK_i                                                       , //clock 
    input                  PRESET_N_i                                                   , //reset signal
    input                  PENABLE_i                                                    , //enable signal from master to slave
    input                  PSEL_i                                                       , //select signal from master to slave
    input      [7:0]       PADDR_i                                                      , //address master send to slave
    input      [7:0]       PWDATA_i                                                     , //data master send to slave
    input                  PWRITE_i                                                     , //read/write signal from master
         
    output reg [7:0]       PRDATA_o                                                     , //data slave send to master
    output reg             PREADY_o                                                     , //ready signal slave send to master

    //-------------------------------register block - i2c core--------------------------------------------------
    input      [7:0]       RECEIVE_i                                                    , //receive data input from receive fifo
    input      [7:0]       STATUS_i                                                     , //status input from i2c core, written by i2c core
    output     [7:0]       PRESCALER_o                                                  , //output of prescaler register
    output     [7:0]       CMD_o                                                        , //output of cmd register
    output     [7:0]       ADDRESS_RW_o                                                 , //output of address_rw register
    output     [7:0]       TRANSMIT_o                                                     //output of transmit register for transmit fifo   
);
    //internal register
    reg [7:0] prescaler                                                                 ; //0x00
    reg [7:0] cmd                                                                       ; //0x01
    reg [7:0] transmit                                                                  ; //0x02
    reg [7:0] receive                                                                   ; //0x03
    reg [7:0] address_rw                                                                ; //0x04
    reg [7:0] status                                                                    ; //0x05

    assign PRESCALER_o = prescaler                                                      ; //update output of register internal
    assign CMD_o = cmd                                                                  ;
    assign ADDRESS_RW_o = address_rw                                                    ;
    assign TRANSMIT_o = transmit                                                        ;

    always @(posedge PCLK_i) 
    begin
        if (~PRESET_N_i)
            begin
                //reset internal register
                prescaler <= 0                                                          ; 
                cmd <= 0                                                                ;
                transmit <= 0                                                           ;
                receive <= 0                                                            ;
                address_rw <= 0                                                         ;
                status <= 0                                                             ;
                //reset output apb interface
                PRDATA_o <= 0                                                           ;
                PREADY_o <= 0                                                           ;
            end
        else
            begin
                if (PSEL_i == 1 && PENABLE_i == 1)                                         //apb master is in access phase
                    begin
                        PREADY_o <= 1                                                   ;
                        //cpu want to write data
                        if (PWRITE_i == 1)
                            case (PADDR_i)
                                8'h00:                                                        //write to prescaler register                                 
                                    prescaler <= PWDATA_i                               ;
                                8'h01:                                                        //write to cmd register                                                 
                                    cmd <= PWDATA_i                                     ;                                
                                8'h02:                                                        //write to transmit register                                                                           
                                    transmit <= PWDATA_i                                ;
                                //8'h03:                                                       receive register is read only for cpu                                                 
                              
                                8'h04:                                                        //write to address register                                                         
                                    address_rw <= PWDATA_i                              ;
                                //8'h05:                                                       //status register is read only for cpu                       
                            endcase
                        
                        //cpu want to read data
                        else
                            case (PADDR_i)
                                8'h00:                                                        //read from prescaler register                                 
                                    PRDATA_o <= prescaler                               ;
                                8'h01:                                                        //read from cmd register                                                 
                                    PRDATA_o <= cmd                                     ;
                                8'h02:                                                        //read from transmit register                                                                           
                                    PRDATA_o <= transmit                                ;
                                8'h03:                                                        //read from receive register                                             
                                    PRDATA_o <= receive                                 ;
                                8'h04:                                                        //read from address register                                                         
                                    PRDATA_o <= address_rw                              ;
                                8'h05:                                                        //read from status register                    
                                    PRDATA_o <= status                                  ;
                            endcase
                    end
                else                                                                      //apb master is in other phase
                    begin
                        PREADY_o <= 0                                                   ;
                        PRDATA_o <= 0                                                   ;
                    end
            end
    end
endmodule