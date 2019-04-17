`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 02:26:45 PM
// Design Name: 
// Module Name: iic_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic[6:0] { OFF, IDLE, MASTER_START, MASTER_SEND_ADDR, SLAVE_START } iic_ctrl_state_t;

// iic_control uses other device interfaces
module iic_control(
    input wire clk, aresetn,
    
    iic_regs_ctrl_if.ctrl regs,
    iic_clock_if.ctrl sclk, 
    iic_sgen_if.ctrl sgen,
    iic_sdetect_if.ctrl sdetect,
    iic_driver_mux_if.ctrl dmux
    );
    
iic_ctrl_state_t state = OFF;
    
always @(posedge clk) begin
    if (aresetn == 0) begin
        state <= OFF;    
    end else if (regs.on == 0) state <= OFF;                
    else case(state)
    OFF:
        if (regs.on == 1) state <= IDLE;
        else state <= OFF;
        
    IDLE:
        if (regs.start == 1) begin
            state <= MASTER_START;
            sclk.clock_reset <= 1;
            sclk.clock_restart <= 0;
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
