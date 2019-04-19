`timescale 1ns / 1ps
`default_nettype none


typedef enum logic[6:0] { OFF, IDLE, MASTER_START, MASTER_SEND_ADDR, SLAVE_START } iic_ctrl_state_t;

import control_enums::*;


// iic_control uses other device interfaces
module iic_control(
    input wire clk, aresetn,
    ackdet_control_bus adet,
    ackgen_control_bus agen,
    clock_control_bus.ctrl clkd,
    control_driver_bus.ctrl drvr,
    control_regs_bus.ctrl regs,
    control_rxreg_bus.ctrl rreg,
    control_sdetect_bus.ctrl sdet,
    control_sgen_bus.ctrl sgen,
    control_txreg_bus.ctrl treg
    );
    

iic_ctrl_state_t state = OFF;
    
always @(posedge clk) begin
    if (aresetn == 0) begin
        state <= OFF;
        
        clkd.control_reset();        
        sgen.control_reset();
        
    end else if (regs.on == 0) state <= OFF;                
    else case(state)
    OFF: begin
        drvr.set_source(SRC_OFF);
        if (regs.on == 1) state <= IDLE;
        else state <= OFF;
    end
    
    IDLE: begin
        drvr.set_source(SRC_OFF);
        if (regs.start == 1) begin
            state <= MASTER_START;
            clkd.set_reset(1);
            clkd.set_restart(0);
        end
        else if (sdet.start_detected == 1) state <= SLAVE_START;
        else state <= IDLE;
    end
    
    MASTER_START: begin
        if (clkd.done == 1) 
            state <= MASTER_SEND_ADDR;
             
        sgen.set_gen_start();
        drvr.set_source(SRC_SGEN);
        
        clkd.set_reset(0);
    end
    
    MASTER_SEND_ADDR: begin
        state <= MASTER_SEND_ADDR;
        sgen.control_reset();
        drvr.set_source(SRC_TXBUF);
        
    end
           
           
    SLAVE_START: begin
        state <= SLAVE_START;
    end
                                         
    endcase
end // end always
    
endmodule
