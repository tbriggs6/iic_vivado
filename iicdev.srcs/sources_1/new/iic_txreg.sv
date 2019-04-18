`timescale 1ns / 1ps
`default_nettype none

module iic_txreg(
    input wire clk,
    input wire aresetn,
    
    input wire iic_scl,
    
    control_txreg_bus.treg ctrl,
    register_txreg_bus.treg regs,
    driver_txreg_bus.treg drvr 
    );
    
logic last_scl;    
logic [7:0] txreg;

enum int  { 
    IDLE, WAIT_CLK, TX0, TX1, TX2, TX3, 
    TX4, TX5, TX6, TX7, DONE } state = IDLE;


assign drvr.sda = 
    (state == TX0) ? txreg[0] :
    (state == TX1) ? txreg[1] :
    (state == TX2) ? txreg[2] :
    (state == TX3) ? txreg[3] :
    (state == TX4) ? txreg[4] :
    (state == TX5) ? txreg[5] :
    (state == TX6) ? txreg[6] :
    (state == TX7) ? txreg[7] : 1'b1;

assign drvr.scl = iic_scl;

always @(posedge clk) begin
if (aresetn == 0) begin
    txreg <= 0;
    last_scl <= iic_scl;
    
    ctrl.txreg_reset();
    regs.txreg_reset();
end else begin
    last_scl <= iic_scl;
    
    case(state)
    IDLE: begin
        ctrl.set_done(0);
        
        if (regs.wren == 1) begin
            txreg <= regs.data;
            regs.set_wrack(1);
            if (iic_scl == 0) 
                state <= TX0;
            else
                state <= WAIT_CLK;
        end
        else 
            state <= IDLE;
    end
                
    WAIT_CLK: begin
        regs.set_wrack(0);
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX0;
        else
            state <= WAIT_CLK;
    end
                        
    TX0: begin
        regs.set_wrack(0);
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX1;
    end
    
    TX1:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX2;
            
    TX2:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX3;
            
    TX3:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX4;
            
    TX4:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX5;
            
    TX5:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX6;
            
    TX6:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= TX7;
            
    TX7:
        if ((last_scl == 1) && (iic_scl == 0))
            state <= DONE;
                        
    DONE: begin
        ctrl.set_done(1);
        
        if (iic_scl == 0) state <= DONE;
        else state <= IDLE;
    end
            
    endcase
end // else begin
end // always
endmodule
