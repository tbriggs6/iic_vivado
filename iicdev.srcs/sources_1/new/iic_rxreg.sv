`timescale 1ns / 1ps
`default_nettype none

module iic_rxreg(
    input wire clk,
    input wire aresetn,
    
    input wire iic_scl,
    input wire iic_sda,
    
    control_rxreg_bus.rreg ctrl,
    register_rxreg_bus.rreg regs
    );

logic last_iic_scl;
logic [7:0] rxdata;
logic [3:0] bit_count;
always @(posedge clk) begin
    if (aresetn == 0) begin
        ctrl.rreg_reset();
        regs.rreg_reset();
        last_iic_scl <= iic_scl;
        bit_count <= 0;
        rxdata <= 0;
        
    end // reset
    
    else begin
        
        // ctrl is enabled
        if (ctrl.enable) begin
            // sample the data on the rising edge of the clock
            if ((last_iic_scl == 0) && (iic_scl == 1) && (bit_count < 8)) begin
                rxdata <= { iic_sda, rxdata[7:1] };
                bit_count <= bit_count + 1;
                if (bit_count == 7) begin
                    regs.data <= { iic_sda, rxdata[7:1] };
                    regs.full <= 1;
                end                    
            end // end positive edge of scl

        end  // ctrl is enabled

        // if not enabled, reset the bit count
        else begin
            bit_count <= 0;
        end    
        
        // handle reading the received byte
        if ((regs.full == 1) && (regs.rden == 1)) begin
            regs.rdack <= 1;
            bit_count <= 0; // we are ready to start reading a new value
            regs.full <= 0;
            rxdata <= 0;
        end
        else begin
            regs.rdack <= 0;
        end
    end // not reset
    
    last_iic_scl <= iic_scl;
end // always    



assign ctrl.done = regs.full;
     
endmodule
