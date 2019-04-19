`timescale 1ns / 1ps
`default_nettype none

module iic_rxreg(
    input wire clk,
    input wire aresetn,
    
    control_rxreg_bus.treg ctrl,
    register_rxreg_bus.rreg regs
    );
endmodule
