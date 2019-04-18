module sim_iic_txreg();

    
/* 

module iic_txreg(
    input wire clk,
    input wire aresetn,
    
    input wire iic_scl,
    
    control_txreg_bus.treg ctrl,
    register_txreg_bus.treg regs,
    driver_txreg_bus.treg drvr 
    );
*/
logic clk, aresetn, iic_scl;
control_txreg_bus ctrl();
register_txreg_bus regs();
driver_txreg_bus drvr();

iic_txreg uut(.*);    


initial begin
    clk = 0;
    forever clk = #1 ~clk;
end

initial begin
    iic_scl = 1;
    #10;
    forever iic_scl = #12 ~iic_scl;
end

reg [7:0] data;
reg wren;

assign regs.data = data;
assign regs.wren = wren;

initial begin
    aresetn = 0;
    
    #10;
    aresetn = 1;
    data = 8'h63;
    wren = 1;
    
    wait (regs.wrack == 1);
    wren = 0;
    
    wait (ctrl.done == 1);
    
    $display("Byte sent?");
    $finish;
end        
   

endmodule