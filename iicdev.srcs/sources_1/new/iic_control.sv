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


typedef enum logic[6:0] { OFF, IDLE, MASTER_START, MASTER_WACK1, SLAVE_START } iic_ctrl_state_t;

module iic_control(
    input wire clk, aresetn,
    
    iic_ctrl2regs_if.ctrl regs,
    iic_clock_if.ctrl sclk,
    iic_sgen_if.ctrl sgen,
    iic_sdetect_if.ctrl sdetect,
    iic_driver_mux_if.ctrl dmux
    );
    

// master / not slave mode
logic master;

iic_ctrl_state_t state = OFF;
always @(posedge clk) begin
    if ((aresetn == 0) || regs.on == 0) begin
        state <= OFF;
        master <= 0;
        
        // reset devices
        sgen.gen_stop = 0;
        sgen.gen_start = 0;
        sclk.clock_reset = 0;
        sclk.clock_restart = 0;
        sclk.clock_out_enable = 0;
        
        
    end else begin
    
    case(state)
    OFF: begin
        if (regs.on) state <= IDLE;
        else state <= OFF;
    end
    
    IDLE: begin
        sclk.clock_restart <= 0;
        sclk.clock_out_enable <= 0;
        sclk.clock_reset <= 1;
        
        dmux.drive_sgen <= 0;
        
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
        sclk.clock_restart <= 0;
        sclk.clock_out_enable <= 0;
        sclk.clock_reset <= 0;
        
        dmux.drive_sgen <= 1;
        
        sgen.gen_start <= 1;
        if (sclk.clock_done == 1) state <= MASTER_WACK1;
        
    end

    MASTER_WACK1: begin
       $finish; 
    end    
    
    default:
        state <= OFF;
    endcase
    end // end else 

end // end always @ clk for state machine    
endmodule
