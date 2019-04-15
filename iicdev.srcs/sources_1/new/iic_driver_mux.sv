`timescale 1ns / 1ps
`default_nettype none


interface iic_driver_mux_if;
logic drive_sgen, sgen_sda, sgen_scl;

modport ctrl (input drive_sgen);
modport sgen (input sgen_sda, sgen_scl);
modport mux (output drive_sgen, sgen_sda, sgen_scl);

endinterface

module iic_driver_mux(
    inout wire iic_sda,
    inout wire iic_scl,
    
    iic_driver_mux_if.mux mux
    );
    
assign iic_sda = (mux.drive_sgen) ? mux.sgen_sda : 1'bz;
assign iic_scl = (mux.drive_sgen) ? mux.sgen_scl : 1'bz;    
    
endmodule
