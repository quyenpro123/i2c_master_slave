module data_fifo_mem # (parameter	DATASIZE	=	8,
					    parameter	ADDRSIZE	=	4)
(
    input                   pclk_i              ,   // APB clock
    input                   i2c_core_clk_i      ,   // i2c clock core
    input   [7:0]           command_i           ,   // command from MCU include: enable, repeat_start, reset, r/w, winc, rinc
    input   [7:0]           data_from_apb_i     ,   // data from apb transfer to TX-FIFO
    input   [7:0]           data_from_sda_i     ,   // data from sda transfer to RX-FIFO
    input                   r_tx_fifo_en_i      ,   // enable read data from TX-FIFO
    input                   w_rx_fifo_en_i      ,   // enable write data to RX-FIFO

    output  [7:0]           data_to_apb_o       ,   // data receive from sda, which transfer to apb interface
    output  [7:0]           data_to_sda_o       ,   // data which receive from apb and then transfer to data_path
    output  [7:0]           status_o                // full, empty status of TX and RX memory
    // output                  tx_full_o           ,   // TX-mem is full
    // output                  tx_empty_o          ,   // Tx-memory is empty
    // output                  rx_full_o           ,   // RX-memory is full
    // output                  rx_empty_o              // RX-memory is empty
);

    // Decalar reg of output
    reg     [7:0]           data_to_apb         ;
    reg     [7:0]           data_to_sda         ;
    wire     [7:0]           status              ;

    // Connect reg to output
    //assign      data_to_apb_o   =   data_to_apb ;
    //assign      data_to_sda_o   =   data_to_sda ;     
    assign      status_o        =   status      ;

    assign      tx_rinc         =   r_tx_fifo_en_i      ;
    assign      rx_winc         =   w_rx_fifo_en_i      ;

    // Instance
    fifo_toplevel        TX_fifo
    (
	    .wdata_i            (data_from_apb_i    )			, // data which write to FIFO buffer

	    .winc_i             (command_i[3]       )			, // write increase how many cells
	    .wclk_i             (pclk_i             )			, // The clock of write-domain
	    .wrst_ni            (command_i[7]       )			, // The negative reset signal of write-domain

	    .rinc_i             (tx_rinc            )			, // read increase how many cells
	    .rclk_i             (i2c_core_clk_i     )			, // The clock of read-domain
	    .rrst_ni            (command_i[7]       )			, // The negative reset signal of read-domain

	    .rdata_o            (data_to_sda_o      )			, // Data which read from FIFO buffer
	    .rempty_o           (status[7]          )		    , // State of FIFO buffer is empty
	    .wfull_o            (status[6]          )			, // State of FIFO buffer is full
	    .r_almost_empty_o   (status[5]          )           , // almost empty
	    .w_almost_full_o    (status[4]          )		      // almost full

);


    fifo_toplevel        RX_fifo
    (
	    .wdata_i            (data_from_sda_i    )			, // data which write to FIFO buffer

	    .winc_i             (rx_winc            )			, // write increase how many cells
	    .wclk_i             (i2c_core_clk_i     )			, // The clock of write-domain
	    .wrst_ni            (command_i[7]       )			, // The negative reset signal of write-domain

	    .rinc_i             (command_i[0]       )			, // read increase how many cells
	    .rclk_i             (pclk_i             )			, // The clock of read-domain
	    .rrst_ni            (command_i[7]       )			, // The negative reset signal of read-domain

	    .rdata_o            (data_to_apb_o      )			, // Data which read from FIFO buffer
	    .rempty_o           (status[3]          )		    , // State of FIFO buffer is empty
	    .wfull_o            (status[2]          )			, // State of FIFO buffer is full
	    .r_almost_empty_o   (status[1]          )           , // almost empty
	    .w_almost_full_o    (status[0]          )		      // almost full

);


endmodule