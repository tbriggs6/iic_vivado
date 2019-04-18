module sim_iic_control( );


// iic_control uses other device interfaces
//module iic_control(
//    input wire clk, aresetn,
    
//    clock_control_bus.ctrl clkd,
//    control_driver_bus.ctrl driver,
//    control_regs_bus.ctrl regs,
//    control_sdetect_bus.ctrl serial
//    );
    
    logic clk, aresetn;
    wire clock_scl;
    wire iic_scl, iic_sda;
    
    clock_control_bus clkd();
    clock_regs_bus cregs();
    clock_driver_bus cdrvr( );
    
    control_driver_bus drvr();
    control_regs_bus regs();
    control_sdetect_bus sdet();
    control_sgen_bus sgen();

    driver_sgen_bus sbus();
        
          
    iic_clock clock (
        .clk(clk), 
        .aresetn(aresetn),
        .ctrl(clkd), 
        .drvr(cdrvr), 
        .regs(cregs)
      );
        
        
    iic_control uut(
        .clk(clk), .aresetn(aresetn),
        .clkd(clkd), .drvr(drvr),
        .regs(regs), .sdet(sdet),
        .sgen(sgen));
  
    iic_sdetect sdetect (
        .clk(clk), .aresetn(aresetn),
        .iic_scl(iic_scl), .iic_sda(iic_sda),
        .sdet(sdet)
    );

    
    iic_driver_mux driver (
        .iic_scl(iic_scl), .iic_sda(iic_sda),
        .ctrl(drvr), .sclk(cdrvr), .sgen(sbus)  
    );
    
    iic_sgen generator (
        .clk(clk), .aresetn(aresetn),
        .ctrl(sgen), .drvr(sbus)
    );
       
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end
    
    initial begin
        aresetn = 0;
        
        #10;
        aresetn = 1;
        
        @(negedge clk);
        regs.on = 1;
        cregs.divider = 5;
        
        @(negedge clk);
        assert(uut.state == IDLE) else $fatal(1, "Control was not idle after ON transition");        
    
        @(negedge clk);
        regs.start = 1;
        
        @(negedge clk);
        assert(uut.state == MASTER_START) else $fatal(1, "Master did not start.");
        
        wait(uut.state == MASTER_SEND_ADDR);
        $finish;
    end
endmodule



    