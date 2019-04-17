`timescale 1ns / 1ps
`default_nettype none


interface iic_sgen_if;
logic gen_start, gen_stop;

// modports named for the perspective of the device connection

// how the control unit sees this connection
modport ctrl (output gen_start, gen_stop);

// how this device sees the connection
modport sgen (input gen_start, gen_stop);

endinterface


module iic_sgen(
    input wire clk,
    input wire aresetn,
    
    inout wire iic_sda,
    inout wire iic_scl,
    
    iic_sgen_if.sgen sgen
    );


assign iic_sda = (sgen.gen_start == 1) ? 1'b0 :
                 (sgen.gen_stop == 1) ? 1'b1  : 1'bz;

assign iic_scl = (sgen.gen_start == 1) || (sgen.gen_stop == 1) ? 1'b1 : 1'bz;


endmodule
