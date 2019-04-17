module sim_iic_control( );


    logic clk, aresetn;
    wire clock_scl;
    
    iic_regs_ctrl_if regs( );
    iic_clock_if sclk( );
    iic_sgen_if sgen( );
    iic_sdetect_if sdetect( );
    iic_driver_mux_if dmux( );
    
    iic_control uut(.*);
    
    iic_clock serial_clk (
        .clk(clk), .aresetn(aresetn), 
        .iic_scl(clock_scl), 
        .controller(sclk), .divider(regs)
    );

    iic_regs(
        .clk(clk), .aresetn(aresetn), .ctrl(regs)
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
        regs.divider = 5;
        
        @(negedge clk);
        assert(uut.state == IDLE) else $fatal("Control was not idle after ON transition");        
    
        @(negedge clk);
        regs.start = 1;
        
        @(negedge clk);
        assert(uut.state == MASTER_START) else $fatal("Master did not start.");
        
        wait(uut.state == MASTER_SEND_ADDR);
        $finish;
    end
endmodule



    