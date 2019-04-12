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

interface iic_ctrl2regs_if;
logic on, master, send_start;
logic addr_matched, start_detected, stop_detected;

modport regs (output on, master, send_start,
                    addr_matched, start_detected, stop_detected);
                    
modport ctrl (input on, send_start,
            output master, addr_matched, start_detected, stop_detected);
endinterface


typedef enum logic[6:0] { OFF, IDLE, MASTER_START, SLAVE_START } iic_ctrl_state_t;

module iic_control(
    input wire clk, aresetn,
    
    iic_ctrl2regs_if.ctrl regs,
    iic_sdetect_if.ctrl sdetect
    );
    

// master / not slave mode
logic master;

iic_ctrl_state_t state = OFF;
always @(posedge clk) begin
    if ((aresetn == 0) || regs.on == 0) begin
        state <= OFF;
        master <= 0;
        
    end else begin
    
    case(state)
    OFF: begin
        if (regs.on) state <= IDLE;
        else state <= OFF;
    end
    
    IDLE: begin
        if (sdetect.start_detected)
            state <= SLAVE_START;
        else if (regs.send_start)
            state <= MASTER_START;
    end
    
    SLAVE_START: begin
        $display("Slave start detected. %d", $time);
    end
    
    MASTER_START: begin
        $display("Master start started. %d", $time);
    end
    
    
    default:
        state <= OFF;
    endcase
    end // end else 

end // end always @ clk for state machine    
endmodule
