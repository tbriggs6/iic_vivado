`timescale 1ns / 1ps
`default_nettype none


interface iic_clock_if #(parameter WIDTH = 10);

logic clock_restart;        // automatically restart the clock when it times out
logic clock_reset;          // reset the clock to divider value on positive edge
logic clock_out_enable;     // enable the module to drive SDA 
logic clock_out;            // the clock out signal
logic clock_done;           // the clock reached zero

// the value of the clock_divider
logic [(WIDTH-1):0] clock_divider;   

// modport named with the perspective of the device
// from the perspective of the control unit
modport ctrl (output clock_restart, clock_reset, clock_out_enable, 
    input clock_out, clock_done);
    
// from the perpsective of the clock, connecting to control    
modport clock_ctrl (input clock_restart, clock_reset, clock_out_enable, 
    output clock_out, clock_done);

endinterface


module iic_clock #(  parameter WIDTH=10 ) (
    input wire clk,
    input wire aresetn,
    
    output wire iic_scl,
    
    iic_clock_if.clock_ctrl controller,
    iic_regs_ctrl_if.sclk divider
    );


logic [WIDTH-1:0] clock_count = 0;
logic clock_output_value = 0;

always @(posedge clk) begin
    if (aresetn == 0) begin
        clock_count <= divider.clock_divider;
        clock_output_value <= 0;
        controller.clock_done <= 0;
    end else begin
        
        if (controller.clock_reset == 1)  begin 
            clock_count <= divider.clock_divider;
            controller.clock_done <= 0;
        end 
        
        // the clock expired....
        else if (clock_count == 0) begin
            // we haven't seen this clock expiration before
            if (controller.clock_done == 0) begin
                controller.clock_done <= 1;
                 
                if (controller.clock_restart == 1)
                    clock_count <= divider.clock_divider;
                    controller.clock_out <= ~controller.clock_out;
            end
        end
            
        else begin
            if ((controller.clock_restart == 1) && (controller.clock_done == 1))
                controller.clock_done <= 0;

            clock_count <= clock_count - 1;
        end
                                            
    end // else not reset           
end // always         

assign iic_scl = (controller.clock_out_enable == 1) ? clock_output_value : 1'bz;
assign controller.clock_out = clock_output_value;


endmodule
