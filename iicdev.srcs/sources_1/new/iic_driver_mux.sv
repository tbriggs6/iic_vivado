`timescale 1ns / 1ps
`default_nettype none


interface iic_driver_mux_if;
logic drive_sgen, sgen_sda, sgen_scl;

// modport named for the perspective of the device on the connection
// from the perspective of the control unit
modport ctrl (input drive_sgen);
modport dmux_ctrl (output drive_sgen);

// from the persepctive of the start / stop generator
modport sgen (input sgen_sda, sgen_scl);
modport dmux_sgen(output sgen_sda, sgen_scl);

endinterface

module iic_driver_mux(
    inout wire iic_sda,
    inout wire iic_scl,
    
    iic_driver_mux_if.ctrl2mux ctrl,
    iic_driver_mux_if.sgen2mux sgen
    );
    
assign iic_sda = (ctrl.drive_sgen) ? sgen.sgen_sda : 1'bz;
assign iic_scl = (ctrl.drive_sgen) ? sgen.sgen_scl : 1'bz;    
    
endmodule
