`timescale 1ns / 1ps
`default_nettype none


module iic_regs(
    input wire clk,
    input wire aresetn,
    
    
    // recieves ack_detected, ack_nack from
    // iic bus
    ackdet_register_bus.regs adet,
    
    // sources ack_nack to bus
    ackgen_registers_bus.regs agen,
    
    // sources divider to clock unit
    clock_regs_bus.regs dclk,
    
    // sources logic and start to control;
    // receives busy;
    control_regs_bus.regs ctrl,
    
    //  drives rden to rxreg,
    // receives data, rdack, and full
    register_rxreg_bus.regs rreg,
    
    // drives data, wren to txreg
    // receives wrack, and full from txreg
    register_txreg_bus.regs treg    
    );
    
   
    
endmodule
