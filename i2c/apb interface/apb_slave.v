module apb_slave (
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
    //-------------------------------slave apb - register block--------------------------------------------------
    input      [7:0]       DATA_i                                                       , //data from register                                                                                         
    output reg [7:0]       DATA_o                                                       , //data slave send to register
    output reg [7:0]       REGISTER_ADDR_o                                              , //address of register
    
);
    always @(posedge pclk_i) 
    begin
        if (~PRESET_N_i)
            begin
                PREADY_i <= 0                                                           ;
                PRDATA_i <= 0                                                           ;
                DATA_o <= 0                                                             ;
                REGISTER_ADDR_o <= 0                                                    ;
            end
        else
            begin
                if (PSEL_i == 1 && PENABLE_i == 0)                                       //master is in setup phase
                begin
                    REGISTER_ADDR_o <= PADDR_i                                          ;
                    PREADY_o <= 0                                                       ;
                end
                else if (PSEL_i == 1 && PENABLE_i == 1)                                  //master is in access phase
                begin
                    PREADY_o <= 1                                                       ; 
                    if (PWRITE_i == 1)                                                   //master write data          
                        DATA_o <= PWDATA_i                                              ;
                    else                                                                 //master read data
                        PRDATA_o <= DATA_i                                              ;
                end
            end
    end

endmodule 