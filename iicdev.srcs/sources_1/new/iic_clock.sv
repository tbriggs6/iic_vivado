`timescale 1ns / 1ps
`default_nettype none


module iic_clock #(  parameter WIDTH=10 ) (
    input wire clk,
    input wire aresetn,
    
    clock_control_bus.clk ctrl,
    clock_driver_bus.clk drvr,
    clock_regs_bus.clk regs    
    );


logic [WIDTH-1:0] clock_count = 0;
logic scl = 1;
logic sda = 1;

always @(posedge clk) begin
    if (aresetn == 0) begin
        clock_count <= regs.divider;
        scl <= 1;
        
        ctrl.clock_reset();
    end else begin
        
        if (ctrl.reset == 1)  begin 
            clock_count <= regs.divider;
            ctrl.clock_reset();
        end 
        
        // the clock expired....
        else if (clock_count == 0) begin
            // we haven't seen this clock expiration before
            if (ctrl.done == 0) begin
                ctrl.clock_done();
                scl <= ~scl;
                
                if (ctrl.restart == 1) begin
                    clock_count <= regs.divider;
                end
            end
        end
            
        else begin
            if ((ctrl.restart == 1) && (ctrl.done == 1))
                ctrl.clock_reset();
            
            clock_count <= clock_count - 1;
        end
                                            
    end // else not reset           
end // always         


assign drvr.scl = scl;
assign drvr.sda = sda;
assign ctrl.scl = scl;

endmodule
