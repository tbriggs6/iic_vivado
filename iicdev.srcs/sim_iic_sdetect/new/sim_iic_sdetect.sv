`default_nettype none;
`timescale 1ns/1ns;

module sim_iic_sdetect( );

logic clk, aresetn, scl, sda;
iic_sdetect_if detector();

iic_sdetect uut( .* );

initial begin
    clk = 0;
    forever clk = #1 ~clk;
end


assert property
    (@(posedge clk) ((scl == 1) && ($fell(sda))) |-> ##1 ($rose(detector.start_detected)))
         else $fatal("Error - not detect start");
    


initial begin
    aresetn = 0;
    scl = 1;
    sda = 1;
    #10;
    aresetn = 1;
    sda = 0;
    #10;
    $finish;
end

endmodule