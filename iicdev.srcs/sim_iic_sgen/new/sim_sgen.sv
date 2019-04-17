`default_nettype none
`timescale 1ns/1ns

module sim_sgen( );

logic clk, aresetn;
wire iic_sda;
iic_sgen_if sgen( );

iic_sgen uut(.*);

initial begin
    clk = 0;
    forever clk = #1 ~clk;
end

assert property
    (@(posedge clk) (sgen.gen_start === 1) |-> (iic_sda === 1'b0));
    
assert property
    (@(posedge clk) (sgen.gen_stop === 1) |-> (iic_sda !== 1'b1));
    
assert property
    (@(posedge clk) (sgen.gen_stop === 0) and (sgen.gen_start === 0) |-> (iic_sda === 1'bz));

initial begin 
    aresetn = 0;
    sgen.gen_stop = 0;
    sgen.gen_start = 0;
    
    #10;
    aresetn = 1;
    sgen.gen_stop = 0;
    sgen.gen_start = 1;
    #10;
    sgen.gen_start = 0;
    #10;
    $finish;
end

endmodule
