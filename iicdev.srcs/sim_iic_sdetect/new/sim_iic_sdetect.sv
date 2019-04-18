`default_nettype none;
`timescale 1ns/1ns;

module sim_iic_sdetect( );

logic clk, aresetn, iic_scl, iic_sda;
control_sdetect_bus sdet();

iic_sdetect uut( .* );

initial begin
    clk = 0;
    forever clk = #1 ~clk;
end


assert property
    (@(posedge clk) ((iic_scl == 1) && ($fell(iic_sda))) |-> ##1 ($rose(sdet.start_detected)))
         else $fatal("Error - not detect start");
    


initial begin
    aresetn = 0;
    iic_scl = 1;
    iic_sda = 1;
    #10;
    aresetn = 1;
    iic_sda = 0;
    #10;
    $finish;
end

endmodule