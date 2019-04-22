`timescale 1ns / 1ps



interface axi_slave_if  #
(
// User parameters ends
// Do not modify the parameters beyond this line

// Width of S_AXI data bus
parameter integer C_S_AXI_DATA_WIDTH	= 32,
// Width of S_AXI address bus
parameter integer C_S_AXI_ADDR_WIDTH	= 4
)
(
		// Global Clock Signal
		wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		logic  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		logic  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		logic [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		logic  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		logic  S_AXI_ARREADY,
		// Read data (issued by slave)
		logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		logic [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		logic  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		logic  S_AXI_RREADY
	);



endinterface


package axi_bus;
class axi_slave #( parameter REGWIDTH=8, parameter DATAWIDTH=32 );

localparam integer ADDR_LSB = (DATAWIDTH/32) + 1;
localparam integer OPT_MEM_ADDR_BITS = 1;

virtual task handle_reset( ); endtask
virtual task handle_write(input integer regnum, input integer value); endtask
virtual function integer handle_read(input integer regnum); endfunction

virtual axi_slave_if slave;

logic aw_en;
logic [REGWIDTH-1:0] axi_awaddr;

function new (virtual axi_slave_if slave);
    this.slave = slave;
endfunction

task run;
begin
    $display("AXI BUS STARTING");
    fork 
    
    forever @(posedge slave.S_AXI_ACLK) begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_AWREADY <= 1'b0;
	      aw_en <= 1'b1;
	    end 
	  else
	    begin    
	      if (~slave.S_AXI_AWREADY && slave.S_AXI_AWVALID && slave.S_AXI_WVALID && aw_en)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          slave.S_AXI_AWREADY <= 1'b1;
	          aw_en <= 1'b0;
	        end
	        else if (slave.S_AXI_BREADY && slave.S_AXI_BVALID)
	            begin
	              aw_en <= 1'b1;
	              slave.S_AXI_AWREADY <= 1'b0;
	            end
	      else           
	        begin
	          slave.S_AXI_AWREADY <= 1'b0;
	        end
	    end 
	end      // end forever 
	
	
//		// Implement axi_awaddr latching
//	// This process is used to latch the address when both 
//	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	 
	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~slave.S_AXI_AWREADY && slave.S_AXI_AWVALID && slave.S_AXI_WVALID && aw_en)
	        begin
	          // Write Address latching 
	          axi_awaddr <= slave.S_AXI_AWADDR;
	        end
	    end 
	end // forever
    
    forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_WREADY <= 1'b0;
	    end 
	  else
	    begin    
	      if (~slave.S_AXI_WREADY && slave.S_AXI_WVALID && slave.S_AXI_AWVALID && aw_en )
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          slave.S_AXI_WREADY <= 1'b1;
	        end
	      else
	        begin
	          slave.S_AXI_WREADY <= 1'b0;
	        end
	    end 
	end 
	
	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	       handle_reset();
	    end 
	  else begin
	    if (slave.S_AXI_WREADY && slave.S_AXI_WVALID && slave.A_AXI_AWREADY && slave.S_AXI_AWVALID)
	      begin
	      
	        handle_write( slave.S_AXI_AWADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB ], slave.S_AXI_WDATA);
	        
	        
	       end  //end if
      end // end else
    end // forever  
	
	
	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_BVALID  <= 0;
	      slave.S_AXI_BRESP   <= 2'b0;
	    end 
	  else
	    begin    
	      if (slave.S_AXI_AWREADY && slave.S_AXI_AWVALID && ~slave.S_AXI_BVALID && slave.S_AXI_WREADY && slave.S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          slave.S_AXI_BVALID <= 1'b1;
	          slave.S_AXI_BRESP  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (slave.S_AXI_BREADY && slave.S_AXI_BVALID) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              slave.S_AXI_BVALID <= 1'b0; 
	            end  
	        end
	    end
	end  
	
	
	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_ARREADY <= 1'b0;
	      slave.S_AXI_ARADDR <= 32'b0;
	    end 
	  else
	    begin    
	      if (~slave.S_AXI_ARREADY && slave.S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          slave.S_AXI_ARREADY <= 1'b1;
	          // Read address latching
	          slave.S_AXI_ARADDR  <= slave.S_AXI_ARADDR;
	        end
	      else
	        begin
	          slave.S_AXI_ARREADY <= 1'b0;
	        end
	    end 
	end       

	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_RVALID <= 0;
	      slave.S_AXI_RRESP <= 0;
	    end 
	  else
	    begin    
	      if (slave.S_AXI_ARREADY && slave.S_AXI_ARVALID && ~slave.S_AXI_RVALID )
	        begin
	          // Valid read data is available at the read data bus
	          slave.S_AXI_RVALID  <= 1'b1;
	          slave.S_AXI_RRESP  <= 2'b0; // 'OKAY' response
	        end   
	      else if (slave.S_AXI_RVALID  && slave.S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          slave.S_AXI_RVALID  <= 1'b0;
	        end                
	    end
	end
	
	
	forever @( posedge slave.S_AXI_ACLK )
	begin
	  if ( slave.S_AXI_ARESETN == 1'b0 )
	    begin
	      slave.S_AXI_RDATA <= 0;
	    end 
	  else
	    
	      if (slave.S_AXI_ARREADY & slave.S_AXI_ARVALID & ~slave.S_AXI_RVALID)
	        begin
	          slave.S_AXI_RDATA <= handle_read(slave.S_AXI_ARADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]);     // register read data
	        end   
	end

    join_none;
end         
endtask

endclass
endpackage
