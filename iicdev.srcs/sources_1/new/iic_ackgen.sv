`timescale 1ns / 1ps
`default_nettype none

module iic_ackgen(
    input wire clk,
    input wire aresetn,
    
    input wire iic_scl,
    input wire iic_sda,
    
    ackgen_control_bus.agen ctrl,
    ackgen_driver_bus.agen drvr,
    ackgen_registers_bus.agen regs
    );
   
reg scl, sda;
    
always @(posedge clk) begin
if (aresetn == 0) begin
    scl <= 1;
    sda <= 1;
end
 
else begin
    
    // if control unit wants to stretch, then drive scl low & keep it there
    if (ctrl.stretch == 1) begin
        scl <= 0;
    end 
    
    // otherwise, release stretch
    else begin
        scl <= 1;
    end
    
    // only while the iic_scl line is change sda
    if (iic_scl == 0)    
        sda <= regs.ack_nack;    
end


end // always    

assign drvr.scl = scl;
assign drvr.sda = sda;

    
    
endmodule
