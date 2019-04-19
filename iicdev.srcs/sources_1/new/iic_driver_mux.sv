`timescale 1ns / 1ps
`default_nettype none


module iic_driver_mux(
    inout wire iic_sda,
    inout wire iic_scl,
    output wire enabled,
    
    ackgen_driver_bus.drvr agen,
    clock_driver_bus.drvr sclk,
    control_driver_bus.drvr ctrl,
    driver_sgen_bus.drvr sgen,
    driver_txreg_bus.drvr treg
    );
    
    assign iic_sda =  
        (ctrl.src_sgen == 1) ? sgen.sda  :
        (ctrl.src_txbuf == 1) ? treg.sda :
        (ctrl.src_agen == 1) ? agen.sda :                     
                     1'bz;
                     
    assign iic_scl = (ctrl.src_sgen == 1) ? sgen.scl  :
                     (ctrl.src_txbuf == 1) ? sclk.scl :
                     (ctrl.src_agen == 1) ? agen.scl :
                     1'bz;
               
    assign enabled = (ctrl.src_sgen == 1) || (ctrl.src_txbuf) || (ctrl.src_agen == 1) ? 1 : 0;
                         
endmodule
