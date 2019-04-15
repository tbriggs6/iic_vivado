`timescale 1ns / 1ps
`default_nettype none

module sim_iic_control(   );
    
    wire iic_sda, iic_scl;
    reg iic_active;
    wire sda, scl;
    
    assign sda = (iic_active) ? iic_sda : 1'bz;
    assign scl = (iic_active) ? iic_scl : 1'bz;
    
    logic clk, aresetn;
    
    iic_clock_if clockif( );
    iic_clock clock( .clk(clk), .aresetn(aresetn),
        .iic_sda(iic_sda), .controller(clockif), .divider(clockif));

    iic_sgen_if sgenif( );
    iic_sgen sgen( .clk(clk), .aresetn(aresetn),
        .iic_sda(iic_sda), .iic_scl(iic_scl), .sgen(sgenif));
    
    iic_sdetect_if detector( );
    iic_sdetect sdetect ( .sda(sda), .scl(scl), .clk(clk), 
        .aresetn(aresetn), .detector(detector) );
    
    iic_driver_mux_if dmux( );
    iic_driver_mux driver_mux (
        .iic_sda(iic_sda), .iic_scl(iic_scl), .mux(dmux)   );
        
    iic_ctrl2regs_if regs( );
    iic_control ctrl ( .clk(clk), .aresetn(aresetn), 
        .regs(regs), .sclk(clockif), .sgen(sgenif), .sdetect(detector),
        .dmux(dmux) );
    
    
    // set the clock divider to 6
    assign clockif.clock_divider = 6;
    
    // drive the clk     
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end

    pullup (weak1) p1 (sda);
    pullup (weak1) p2 (scl);             
             
    // drive the logic signals
    initial begin
        iic_active = 0;
        aresetn = 0;
        regs.send_start = 0;
        
        #10;
        @(negedge clk);
        aresetn = 1;
        
        @(negedge clk);
        regs.on = 1;
        
        @(negedge clk);
        assert(ctrl.state == IDLE) else $error("Control didn't turn on");
        regs.send_start = 1;
        
        
        @(negedge clk);
        assert(detector.start_detected == 1) else $error("Did not detect a start.");
        assert(ctrl.state == SLAVE_START) else $error("Controller did not enter start.");
        
        $display("Reached the end of the simulation");
        $finish;
    end
                 
endmodule
