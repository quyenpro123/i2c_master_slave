module apb_slave (
    input               PCLK_i                                                      , //clock 
    input               PRESET_N_i                                                  , //reset signal
    input               PENABLE_i                                                   , //enable signal from master to slave
    input               PSEL_i                                                      , //select signal from master to slave
    input   [7:0]       PADDR_i                                                     , //address master send to slave
    input   [7:0]       PWDATA_i                                                    , //data master send to slave
    input               PWRITE_i                                                    , //read/write signal from master

    output  [7:0]       PRDATA_o                                                    , //data slave send to master
    output              PREADY_o                                                      //ready signal slave send to master                                                                                         
);
    always @(posedge pclk_i) 
    begin
        if (~PRESET_N_i)
            begin
                PREADY_i <= 0                                                       ;
                PRDATA_i <= 0                                                       ;
            end
        else
            begin
                if (PSEL_i == 1 && PENABLE_i == 0 && PWRITE_i == 1)                   //master setup state
            end
    end

endmodule 