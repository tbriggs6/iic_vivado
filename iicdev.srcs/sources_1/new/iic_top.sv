`timescale 1ns / 1ps
`default_nettype none


module iic_top(
    input wire clk,
    input wire aresetn,
    inout wire iic_sda,
    inout wire iic_scl,
    
    register_user_bus.regs user_regs
    );
    
    
    ackdet_control_bus adet2ctrl();
    ackdet_register_bus adet2regs();
    
    ackgen_control_bus agen2ctrl();
    ackgen_driver_bus agen2drvr();
    ackgen_registers_bus agen2regs();
    
    clock_control_bus clk2ctrl();
    clock_driver_bus clk2drvr();
    clock_regs_bus clk2regs();
    
    control_driver_bus ctrl2drvr();
    control_regs_bus ctrl2regs( );
    control_rxreg_bus ctrl2rreg( );
    control_sdetect_bus ctrl2sdet( );
    control_sgen_bus ctrl2sgen( );
    control_txreg_bus ctrl2treg( );

    driver_sgen_bus drvr2sgen();
    driver_txreg_bus drvr2treg();
    
    register_rxreg_bus regs2rreg();
    register_sdetect_bus regs2sdet();
    register_txreg_bus regs2treg();
    
    iic_control control (
        .clk(clk), .aresetn(aresetn),
        .adet(adet2ctrl),
        .agen(agen2ctrl),
        .clkd(clk2ctrl), 
        .drvr(ctrl2drvr),
        .regs(ctrl2regs),
        .rreg(ctrl2rreg),
        .sdet(ctrl2sdet),
        .sgen(ctrl2sgen),
        .treg(ctrl2treg)
    );
        
    
    iic_ackgen ackgen (
        .clk(clk), .aresetn(aresetn),
        .iic_scl(iic_scl), .iic_sda(iic_sda),
        .ctrl(agen2ctrl), 
        .drvr(agen2drvr),
        .regs(agen2regs)
    );
    
    
    iic_adetect adetect (
        .clk(clk), .aresetn(aresetn),
        .iic_scl(iic_scl), 
        .iic_sda(iic_sda),
        .ctrl(adet2ctrl), 
        .regs(adet2regs)
        );


    iic_clock clock (
        .clk(clk), .aresetn(aresetn),
        .ctrl(clk2ctrl), 
        .drvr(clk2drvr),
        .regs(clk2regs)
    );
    
    wire enabled;
    wire drvr_iic_sda, drvr_iic_scl;
    
    iic_driver_mux driver_mux (
        .iic_sda(drvr_iic_sda), 
        .iic_scl(drvr_iic_scl),
        .enabled(enabled),
        .sclk(clk2drvr), 
        .ctrl(ctrl2drvr),
        .agen(agen2drvr),
        .sgen(drvr2sgen),
        .treg(drvr2treg)
    );

    
    
    iic_regs regs (
        .clk(clk), .aresetn(aresetn),
        .user_regs(user_regs),
        .adet(adet2regs),
        .agen(agen2regs),
        .dclk(clk2regs),     
        .ctrl(ctrl2regs),
        .rreg(regs2rreg),
        .sdet(regs2sdet),
        .treg(regs2treg)
    );        
    
    
//    iic_rxreg rxreg (
//        .clk(clk), .aresetn(aresetn),
//        .iic_scl(iic_scl), 
//        .iic_sda(iic_sda),
//        .ctrl(ctrl2rreg), 
//        .regs(regs2rreg)
//        );
        
        
    iic_sdetect sdetect (
        .clk(clk), .aresetn(aresetn),
        .iic_scl(iic_scl), 
        .iic_sda(iic_sda),
        .sdet(ctrl2sdet)
    );
    
    
    iic_sgen sgen (
        .clk(clk), .aresetn(aresetn),
        .ctrl(ctrl2sgen),
        .drvr(drvr2sgen)
    );
    
  
    iic_txreg txreg (
        .clk(clk), .aresetn(aresetn),
        .iic_scl(iic_scl),
        .ctrl(ctrl2treg),
        .regs(regs2treg),
        .drvr(drvr2treg)
    );


    
    assign iic_sda = (enabled == 1) ? drvr_iic_sda : 1'bz;
    assign iic_scl = (enabled == 1) ? drvr_iic_scl : 1'bz;
    
endmodule
