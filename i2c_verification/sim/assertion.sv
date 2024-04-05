`ifndef ASSERT
`define ASSERT
`include "interface.sv"
   module assertion_cov(intf_cnt intf);
	int i = 0;

	always @(negedge intf.data_slave_read_valid) 
	begin
		if (intf.preset)
		begin
			check_data_master_sent: assert (intf.data_slave_read == intf.data_master[i]) $display("Assertion: Slave received successfully data %0x from master", intf.data_slave_read); else 
                                $error("Assertion: Slave received data: %0x!", intf.data_slave_read);
			$display(" data master sent: i = %0d, data = %0x", i, intf.data_master[i]);
			i <= i + 1;
		end
	end
	
	always @(posedge intf.stop)
		i <= 0;

	check_psel_penable_1: cover property(@(posedge intf.pclk) intf.psel ##1 intf.penable);
	check_psel_penable_2: cover property(@(posedge intf.pclk) ~intf.psel |-> ~intf.penable);
	check_sda_scl_reset: cover property(@(posedge intf.pclk) (intf.psel && intf.penable && intf.pwrite && (intf.paddr == 4) && ~intf.pwdata[7]) |-> (~intf.sda_io && ~intf.scl_io));
   endmodule
`endif
