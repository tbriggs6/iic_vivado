`timescale 1ns / 1ps
`default_nettype none


module iic_driver_mux(
    inout wire iic_sda,
    inout wire iic_scl,
    
    clock_driver_bus.drvr sclk,
    control_driver_bus.drvr ctrl,
    driver_sgen_bus.drvr sgen 
    );
    
    assign iic_sda = (ctrl.src_sgen == 1) ? sgen.sda  :
                     1'bz;
                     
    assign iic_scl = (ctrl.src_sgen == 1) ? sgen.scl  :
                     1'bz;
                     
endmodule
