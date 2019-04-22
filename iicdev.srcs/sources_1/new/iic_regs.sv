`timescale 1ns / 1ps
`default_nettype none


module iic_regs(
    input wire clk,
    input wire aresetn,
    
    register_user_bus.regs user_regs,
    
    // recieves ack_detected, ack_nack from
    // iic bus
    ackdet_register_bus.regs adet,
    
    // sources ack_nack to bus
    ackgen_registers_bus.regs agen,
    
    // sources divider to clock unit
    clock_regs_bus.regs dclk,
    
    // sources logic and start to control;
    // receives busy;
    control_regs_bus.regs ctrl,
    
    //  drives rden to rxreg,
    // receives data, rdack, and full
    register_rxreg_bus.regs rreg,

    // drivers the start detect bus
    register_sdetect_bus.regs sdet,     
    
    // drives data, wren to txreg
    // receives wrack, and full from txreg
    register_txreg_bus.regs treg    
    );


logic [31:0] registers [0:15];

const logic [31:0] power_on_vals[0:15] = '{ 
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0 };

const logic [31:0] masks[0:15] = '{ 
    32'h0077_947f, 32'h0000_04d8, 32'h0000_03ff, 32'h0000_03ff,
    32'h0000_ffff, 32'h0000_00ff, 32'h0000_00ff, 32'h0000_0000,
    0,0,0,0,
    0,0,0,0 };


function logic[31:0] read_reg(logic [3:0] regnum);
    case(regnum) 
    0: read_reg = registers[0];
    1: read_reg = registers[1];
    2: read_reg = registers[2];
    3: read_reg = registers[3];
    
    default: read_reg = 0;
    endcase
endfunction
 
always @(posedge user_regs.wren) begin
    $display("USER REGS WREN went high");
 end
  
// we have 16  16-bit registers to read/write 
always @(posedge clk) begin
    if (aresetn == 0) begin
        for (int i = 0; i < 16; i++)
            registers[i] <= power_on_vals[i];
    end // end reset
    else if (user_regs.wren == 1) begin
        registers[user_regs.regnum] <= user_regs.regdata & masks[user_regs.regnum];
        if (user_regs.regnum == 1) begin
            sdet.clr_start <= user_regs.regdata[3]; // clear the start bit
            sdet.clr_stop <= user_regs.regdata[4]; // clear the stop bit
            rreg.clr_ovflow <= user_regs.regdata[6]; // clear the overflow in the receiver
        end
                                
    end // end else if
    
    // handle changes from the slave logic
    if (ctrl.clr_start) registers[0][0] <= 0;
    if (ctrl.clr_restart) registers[0][1] <= 0;
    if (ctrl.clr_stop) registers[0][2] <= 0;
    if (ctrl.clr_rcen) registers[0][3] <= 0;
    if (ctrl.clr_acken) registers[0][4] <= 0;
    if (ctrl.clr_sclrel) registers[0][12] <= 0;
    
    registers[1][0] <= treg.full;
    registers[1][1] <= rreg.full;
    registers[1][2] <= ctrl.slv_rdnwr;
    registers[1][5] <= ctrl.slv_dna;
    registers[1][13] <= ctrl.slv_acktim;
    registers[1][14] <= treg.busy;
    registers[1][15] <= ctrl.ack_det;
end  // end always

assign user_regs.regdata = (user_regs.rden == 1) ? read_reg(user_regs.regnum) : 16'bz;   



/* ********************************************************* 
    MAP REGISTERS TO CONTROL SIGNALS
   ********************************************************* */
assign ctrl.start = registers[0][0];
assign ctrl.restart = registers[0][1];
assign ctrl.restart = registers[0][2];
assign ctrl.rcen = registers[0][3];
assign ctrl.acken = registers[0][4];
assign ctrl.ackdet = registers[0][5];
assign ctrl.stren = registers[0][6];
assign ctrl.a10m = registers[0][9];
assign ctrl.sclrel = registers[0][12];
assign ctrl.on = registers[0][15];
assign ctrl.dhen = registers[0][16];
assign ctrl.ahen = registers[0][17];


   
    
endmodule
