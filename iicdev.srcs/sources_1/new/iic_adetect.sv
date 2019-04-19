`timescale 1ns / 1ps
`default_nettype none


module iic_adetect(
    input wire clk,
    input wire aresetn,
    
    input wire iic_sda,
    input wire iic_scl,
    
    ackdet_control_bus.adet ctrl,
    ackdet_register_bus.adet regs
    );
    
logic last_iic_scl;

always @(posedge clk) begin
if (aresetn == 0) begin
    ctrl.adet_reset( );
    regs.adet_reset( );
    last_iic_scl <= iic_scl;
end  // end reset

else begin
    // catch the rising edge of the SCL to detect the ACK/NACK
    if (ctrl.enabled == 1) begin 
        if ((last_iic_scl == 0) && (iic_scl == 1)) begin
            ctrl.detected(iic_sda);
            regs.detected(iic_sda);
        end
    end

    // unit is not enabled
    else begin
        ctrl.adet_reset( );
        regs.adet_reset( );    
    end        
end

end // end always     
    
    
endmodule
