`default_nettype none
`timescale 1ns/1ns

module sim_iic_clock( );

    logic clk, aresetn;
    logic iic_sda;

    iic_clock_if clockif( );
    iic_clock uut( 
        .clk(clk), .aresetn(aresetn),
        .iic_sda(iic_sda), .controller(clockif), .divider(clockif)
    );
    
    // create the logic clock
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end

    // generate the test signals
    initial begin
        aresetn = 0;
        #10;
        aresetn = 1;
    end
    
    /*  
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
*/

initial begin
    #15;
    @(negedge clk);
    
    clockif.regs.clock_divider = 4;
    clockif.ctrl.clock_restart = 1;
    clockif.ctrl.clock_reset = 1 ;
    clockif.clock_out_enable = 0;
    @(negedge clk);
    @(negedge clk);
    clockif.ctrl.clock_reset = 0;
    
    @(posedge clockif.ctrl.clock_out);
    @(posedge clockif.ctrl.clock_out);
    clockif.ctrl.clock_restart = 0;
    
    for (int i = 0; i < 12; i++) begin
        #1 assert (clockif.ctrl.clock_out == 1) 
            else $error("clock should stay high after cycle complete.");
    end
    
    $finish;
end
    
    
endmodule