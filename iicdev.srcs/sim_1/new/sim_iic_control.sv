`timescale 1ns / 1ps
`default_nettype none

module sim_iic_control(   );
    
    reg iic_sda, iic_scl, iic_active;
    wire sda, scl;
    
    assign sda = (iic_active) ? iic_sda : 1'bz;
    assign scl = (iic_active) ? iic_scl : 1'bz;
    
    logic clk, aresetn;
    
    
    iic_sdetect_if detector( );
    iic_sdetect sdetect ( .sda(sda), .scl(scl), .clk(clk), 
        .aresetn(aresetn), .detector(detector) );
    
    iic_ctrl2regs_if regs( );
    iic_control ctrl ( .clk(clk), .aresetn(aresetn), 
        .regs(regs), .sdetect(detector) );
    
    
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
        #10;
        @(negedge clk);
        aresetn = 1;
        
        @(negedge clk);
        regs.on = 1;
        
        @(negedge clk);
        assert(ctrl.state == IDLE) else $error("Control didn't turn on");
        
        // drive a start bit
        iic_active <= 1;
        iic_scl <= 1;
        iic_sda <= 0;        
        
        @(negedge clk);
        assert(detector.start_detected == 1) else $error("Did not detect a start.");
        assert(ctrl.state == SLAVE_START) else $error("Controller did not enter start.");
        
        $display("Reached the end of the simulation");
        $finish;
    end
                 
endmodule
