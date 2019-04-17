`timescale 1ns / 1ps
`default_nettype none

typedef enum logic[6:0] { OFF, IDLE, MASTER_START, MASTER_SEND_ADDR, SLAVE_START } iic_ctrl_state_t;

// iic_control uses other device interfaces
module iic_control(
    input wire clk, aresetn,
    
    clock_control_bus.ctrl clkd,
    control_driver_bus.ctrl driver,
    control_regs_bus.ctrl regs,
    control_sdetect_bus.ctrl serial
    );
    
iic_ctrl_state_t state = OFF;
    
always @(posedge clk) begin
    if (aresetn == 0) begin
        state <= OFF;
        
        clkd.reset <= 0;
        clkd.restart <= 0;
        clkd.out_enable <= 0;
            
    end else if (regs.on == 0) state <= OFF;                
    else case(state)
    OFF:
        if (regs.on == 1) state <= IDLE;
        else state <= OFF;
        
    IDLE:
        if (regs.start == 1) begin
            state <= MASTER_START;
            clkd.reset <= 1;
            clkd.restart <= 0;
        end
        else if (sdetect.start_detected == 1) state <= SLAVE_START;
        else state <= IDLE;
        
    MASTER_START: begin
        if (sclk.clock_done == 1) 
            state <= MASTER_SEND_ADDR;
             
        sgen.gen_start <= 1;
        sclk.clock_reset <= 0;
    end
    
    MASTER_SEND_ADDR: begin
        state <= MASTER_SEND_ADDR;
    end
           
           
    SLAVE_START: begin
        state <= SLAVE_START;
    end
                                         
    endcase
end // end always
    
endmodule
