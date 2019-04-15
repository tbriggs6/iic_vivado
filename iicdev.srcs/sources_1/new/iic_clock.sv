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

modport ctrl (input clock_restart, clock_reset, clock_out_enable, output clock_out, clock_done);
modport regs (input clock_divider);

modport from_ctrl  (input clock_out, clock_done, output clock_restart, clock_reset, clock_out_enable );
modport from_regs  (output clock_divider);

endinterface


module iic_clock #(  parameter WIDTH=10 ) (
    input wire clk,
    input wire aresetn,
    
    output wire iic_sda,
    
    iic_clock_if.from_ctrl controller,
    iic_clock_if.from_regs divider
    );


logic [WIDTH-1:0] clock_count = 0;
logic last_clock_reset = 0;
logic clock_output_value = 0;

always @(posedge clk) begin
    if (aresetn == 0) begin
        clock_count <= divider.clock_divider;
        last_clock_reset <= 0;
        clock_output_value <= 0;
    end else begin
        
        if ((controller.clock_reset == 1) && (last_clock_reset == 0)) begin 
            clock_count <= divider.clock_divider;
        end 
        else if (clock_count == 0) begin
            clock_output_value <= ~clock_output_value;
            if (controller.clock_restart == 1)
                clock_count <= divider.clock_divider;
        end 
        else begin 
            clock_count <= clock_count - 1;
        end
        
        last_clock_reset <= controller.clock_reset;    
                                    
    end // else not reset           
end // always         

assign iic_sda = (controller.clock_out_enable == 1) ? clock_output_value : 1'bz;
assign controller.clock_out = clock_output_value;
assign controller.clock_done = (clock_output_value == 0) ? 1 : 0;

endmodule
