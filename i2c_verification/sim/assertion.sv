`ifndef ASSERT
`define ASSERT
`include "interface.sv"
   module assertion_cov(intf_cnt intf);
	int i = 0;
	logic [7:0] data_master[$];
	always @(negedge intf.data_slave_read_valid) 
	begin
		i = ++;
	end

	always @(negedge intf.data_slave_read_valid) 
	begin
		check_data_master_sent: assert (intf.data_slave_read == data_master[i]) $display("Slave received completely data %0x from master", intf.data_slave_read); else 
                                $error("Slave received data incorrectly!"); 
	end
	

	check_psel_penable_1: cover property(@(posedge intf.pclk) intf.psel ##1 intf.penable);
	check_psel_penable_2: cover property(@(posedge intf.pclk) ~intf.psel |-> ~intf.penable);
	check_sda_scl_reset: cover property(@(posedge intf.pclk) (intf.psel && intf.penable && intf.pwrite && (intf.paddr == 4) && ~intf.pwdata[7]) |-> (~intf.sda_io && ~intf.scl_io));
   endmodule
`endif
