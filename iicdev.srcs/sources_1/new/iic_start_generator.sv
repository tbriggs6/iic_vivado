`timescale 1ns / 1ps
`default_nettype none


interface iic_sgen_if;
logic gen_start, gen_stop;

modport ctrl (output gen_start, gen_stop);
modport sgen (input gen_start, gen_stop);

endinterface


module iic_sgen(
    input wire clk,
    input wire aresetn,
    
    output wire iic_scl, 
    output wire iic_sda,
    
    iic_sgen_if.sgen sgen
    );


assign iic_scl = (sgen.gen_start == 1) ? 1'b1 : 
                 (sgen.gen_stop == 1) ?  1'b1 : 1'b1;
                 
assign iic_sda = (sgen.gen_start == 1) ? 1'b0 :
                 (sgen.gen_stop == 1) ? 1'b1  : 1'b1;

endmodule
