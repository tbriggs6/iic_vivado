`timescale 1ns / 1ps
`default_nettype none

module iic_sgen(
    input wire clk,
    input wire aresetn,

    control_sgen_bus.sgen ctrl,
    driver_sgen_bus.sgen drvr   
    );


assign drvr.sda = (ctrl.gen_start == 1) ? 1'b0 : 1'b1;
assign drvr.scl = 1'b1;


endmodule
