module i2c_top      #(parameter     DATA_SIZE   =   8   ,
                      parameter     ADDR_SIZE   =   8   )
(
    input                               i2c_core_clk_i      ,   // clock core of i2c
    input                               pclk_i              ,   //  APB clock
    input                               preset_ni           ,   //  reset signal is active-LOW
    input   [ADDR_SIZE - 1 : 0]         paddr_i             ,   //  address of APB slave and register map
    input                               pwrite_i            ,   //  HIGH is write, LOW is read
    input                               psel_i              ,   //  select slave interface
    input                               penable_i           ,   //  Enable. PENABLE indicates the second and subsequent cycles of an APB transfer.
    input   [DATA_SIZE - 1 : 0]         pwdata_i            ,   //  data write

    output  [DATA_SIZE - 1 : 0]         prdata_o            ,   //  data read
    output                              pready_o            ,   //  ready to receive data
    inout                               sda                 ,
    inout                               scl             
);


 
    // Decalar netlist
    wire                        i2c_sda_en                      ;
    wire                        i2c_scl_en                      ;
    wire                        i2c_sda                         ;
    wire                        i2c_scl                         ;

    wire                        clk_en                          ;
    wire                        reset_n                         ;
    wire                        enable                          ;
    wire                        repeat_start                    ;
    wire                        rw                              ;
	wire						w_fifo_en						;
	wire						r_fifo_en_o						;
    wire                        sda_low_en                      ;
    wire                        write_data_en                   ;
    wire                        write_addr_en                   ;
    wire                        receive_data_en                 ;
    wire	[3:0]               count_bit                       ;

    wire  [DATA_SIZE - 1 : 0]   data                            ;
    wire  [DATA_SIZE - 1 : 0]   data_from_sda                   ;
    wire  [DATA_SIZE - 1 : 0]   data_to_sda                     ;
    wire  [DATA_SIZE - 1 : 0]   data_to_apb                     ;
    wire  [7:0]                 to_status_reg                   ;
    wire  [7:0]                 data_from_apb                   ;
    wire  [7:0]                 slave_address               	;
    wire  [7:0]                 command                         ;
	wire  [7:0]					status							;
    wire  [7:0]                 prescale                        ;

    wire                        start_done                      ;
    wire                        reset_done                      ;

    assign      sda     =   i2c_sda_en ? i2c_sda : 1'bz         ;
    assign      scl     =   i2c_scl_en ? i2c_scl : 1         ;

    pullup (sda)    ;
    //pullup (scl)    ;

    // get command bit
    assign      enable          =       command[6]            ;
    assign      reset_n         =       command[7]            ;
    assign      repeat_start    =       command[5]            ;
    assign      rw              =       slave_address[0]      ;

    // get tx-empty, rx-full from status reg
    assign      tx_empty        =       status[7]   ;	
    assign      rx_full         =       status[2]   ;

    // push data to i2c line
    assign      i2c_sda_o       =       i2c_sda     ;
    assign      i2c_scl_o       =       i2c_scl     ;

    // dut
    clock_generator                              clock_generator 
    (
		.i2c_core_clk_i	    (i2c_core_clk_i     )     ,   // i2c core clock
    	.clk_en_i		    (clk_en		        )     ,   // enbale clock to scl
		.reset_ni		    (reset_n		    )	  ,
        .prescale_i         (prescale           )     ,
    	.i2c_scl_o 		    (i2c_scl		    )         // scl output
    );


    i2c_master_fsm                                  i2c_master_fsm
    (
        .enable_i           (enable             )      ,   // enable signal from MCU
    	.reset_ni           (reset_n            )      ,   // reset negative signal from MCU
    	.repeat_start_i     (repeat_start       )      ,   // repeat start signal from MCU
    	.rw_i               (rw                 )      ,   // bit 1 is read - 0 is write
    	.full_i             (rx_full            )      ,   // FIFO buffer is full
    	.empty_i            (tx_empty           )      ,   // FIFO buffer is empty
    	.i2c_core_clk_i     (i2c_core_clk_i     )      ,   // i2c core clock
    	.i2c_sda_i          (sda                )      ,   // i2c sda feedback to FSM
    	.i2c_scl_i          (scl                )      ,   // i2c scl feedback to FSM

		.w_fifo_en_o		(w_fifo_en			)		,
		.r_fifo_en_o		(r_fifo_en			)		,

    	.sda_low_en_o       (sda_low_en         )      ,   // when = 1 enable sda down 0
    	.clk_en_o           (clk_en             )      ,   // enbale to generator clk
    	.write_data_en_o    (write_data_en      )      ,   // enable write data on sda
    	.write_addr_en_o    (write_addr_en      )      ,   // enable write address of slave on sda
    	.receive_data_en_o  (receive_data_en    )      ,   // enable receive data from sda
    	.count_bit_o        (count_bit          )      ,   // count bit data from 7 down to 0
    	.i2c_sda_en_o       (i2c_sda_en         )      ,   // allow impact to sda
    	.i2c_scl_en_o       (i2c_scl_en         )      ,   // allow impact to scl
        .start_done_o       (start_done         )      ,
        .reset_done_o       (reset_done         )
    );


    data_path_i2c_to_core   # (DATA_SIZE    , ADDR_SIZE    )                           
    data_path_i2c_to_core (
        .data_i               (data_to_sda      )         ,   // data from fifo buffer
        .addr_i               (slave_address    )         ,   // address of slave
        .count_bit_i          (count_bit        )         ,   // sda input
        .i2c_core_clk_i       (i2c_core_clk_i   )         ,
        .reset_ni             (reset_n          )         ,
        .i2c_sda_i            (sda              )         ,   // sda line

        .sda_low_en_i         (sda_low_en       )         ,   // control sda signal from FSM, when 1 sda = 0
        .write_data_en_i      (write_data_en    )         ,   // enable write data signal from FSM
        .write_addr_en_i      (write_addr_en    )         ,   // enable write slave's signal to sda 
        .receive_data_en_i    (receive_data_en  )         ,   // enable receive data from sda

        .data_from_sda_o      (data_from_sda    )         ,   // data from sda to write to FIFO buffer
        .i2c_sda_o            (i2c_sda          )            // i2c sda output   
    );


    data_fifo_mem # (DATA_SIZE, ADDR_SIZE)      data_fifo_mem (
        .pclk_i             (pclk_i         )   ,   // APB clock
        .i2c_core_clk_i     (i2c_core_clk_i )   ,   // i2c clock core
        .command_i          (command        )   ,   // command from MCU include: enable, repeat_start, reset, r/w, winc, rinc
        .data_from_apb_i    (data_from_apb  )   ,   // data from apb transfer to TX-FIFO
        .data_from_sda_i    (data_from_sda  )   ,   // data from sda transfer to RX-FIFO
        .r_tx_fifo_en_i     (r_fifo_en      )   ,   // enable read data from TX-FIFO
        .w_rx_fifo_en_i     (w_fifo_en      )   ,   // enable write data to RX-FIFO

        .data_to_apb_o      (data_to_apb    )   ,   // data receive from sda, which transfer to apb interface
        .data_to_sda_o      (data_to_sda    )   ,   // data which receive from apb and then transfer to data_path
        .status_o           (status		    )       // full, empty status of TX and RX memory
    );


    apb_slave_interface # (DATA_SIZE, ADDR_SIZE)    apb_slave_interface (
        .pclk_i             (pclk_i         )         ,   //  clock
        .preset_ni          (preset_ni      )         ,   //  reset signal is active-LOW
        .paddr_i            (paddr_i        )         ,   //  address of APB slave and register map
        .pwrite_i           (pwrite_i       )         ,   //  HIGH is write, LOW is read
        .psel_i             (psel_i         )         ,   //  select slave interface
        .penable_i          (penable_i      )         ,   //  Enable. PENABLE indicates the second and subsequent cycles of an APB transfer.
        .pwdata_i           (pwdata_i       )         ,   //  data write
        .to_status_reg_i    (status         )         ,
	    .data_fifo_i        (data_to_apb    )	      ,   //  data from FIFO memory

        .prdata_o           (prdata_o       )         ,   //  data read
        .pready_o           (pready_o       )         ,   //  ready to receive data
        .reg_transmit_o     (data_from_apb  )         ,
        .reg_slave_address_o(slave_address  )         ,
        .reg_command_o      (command        )         ,
        .reg_prescale_o     (prescale       )         ,
        .start_done_i       (start_done     )         ,
        .reset_done_i       (reset_done     )
    );
endmodule