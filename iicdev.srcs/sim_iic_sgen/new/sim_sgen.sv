`default_nettype none
`timescale 1ns/1ns

module sim_sgen( );

logic clk, aresetn;
control_sgen_bus ctrl();
driver_sgen_bus drvr();

iic_sgen uut(.*);

initial begin
    clk = 0;
    forever clk = #1 ~clk;
end

assert property
    (@(posedge clk) $rose(ctrl.gen_start) |-> $fell(drvr.sda));
    
assert property
    (@(posedge clk) $rose(ctrl.gen_stop) |-> (drvr.sda === 1'b1));
    
initial begin 
    aresetn = 0;
    ctrl.gen_stop = 0;
    ctrl.gen_start = 0;
    
    #10;
    aresetn = 1;
    ctrl.gen_stop = 0;
    ctrl.gen_start = 1;
    #10;
    ctrl.gen_start = 0;
    #10;
    $finish;
end

endmodule
