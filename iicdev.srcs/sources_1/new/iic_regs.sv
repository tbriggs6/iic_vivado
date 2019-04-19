`timescale 1ns / 1ps
`default_nettype none


module iic_regs(
    input wire clk,
    input wire aresetn,
    
    iic_regs_axi_if.axi axi,    
    iic_regs_ctrl_if.regs ctrl
    );
    
    localparam NUM_REGS = 8;
    
    logic [15:0] regs[(NUM_REGS-1):0];
    
    always @(posedge clk) begin
    if (aresetn == 0) begin
        for (int i = 0; i < NUM_REGS; i++)
            regs[i] <= 0;
    end
    else begin
    // handle a read
    if (axi.rdnwr == 1) begin
        if (axi.regnum >= NUM_REGS) axi.regval <= 16'd0;
        else axi.regval <= regs[ axi.regnum];
    end else begin
        if (axi.regnum <= NUM_REGS) begin 
            $display("REGWR: reg[%d] = %x", regnum, regval);
            regs[axi.regnum] <= axi.regval;
        end
    end // end else
    end // not reset
    end // always 

    
endmodule
