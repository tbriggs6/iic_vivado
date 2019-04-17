`default_nettype none
`timescale 1ns/1ns

module sim_iic_clock( );

    logic clk, aresetn;

    clock_regs_bus regs();
    clock_control_bus ctrl();
    clock_driver_bus drvr();
    
    
    iic_clock uut( .* ); 
    
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
    
assign regs.divider = 4;

initial begin
    aresetn = 0;
    #15;
    aresetn = 1;

    @(negedge clk);
    ctrl.reset = 1;
    ctrl.restart = 1;
    
    @(negedge clk);
    ctrl.reset = 0;
    
    @(negedge ctrl.scl);
    @(negedge ctrl.scl);
    @(negedge ctrl.scl);
    @(negedge ctrl.scl);
    
        
    $finish;
end
    
    
endmodule