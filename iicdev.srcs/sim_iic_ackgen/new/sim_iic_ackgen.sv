`default_nettype none
`timescale 1ns/1ns

module sim_iic_ackgen( );

    logic clk, aresetn;
    logic iic_sda, iic_scl;
    
    ackgen_control_bus ctrl( );
    ackgen_driver_bus drvr( );
    ackgen_registers_bus regs( );

    iic_ackgen uut( .* );
    
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end
    
    
    initial begin
        aresetn = 0;
        ctrl.ctrl_reset( );
        regs.regs_reset( );
        
        iic_sda = 1;
        iic_scl = 1;
        
        #10;
        aresetn = 1;
        ctrl.set_stretch(1);
        
        #4;
        assert (drvr.scl == 0) else
            $fatal(0, "Error - stretched clock should be 0");
            
        regs.set_acknack(1);
        ctrl.set_stretch(0);
        #1;
        iic_scl = 0;
        
        #4;
        assert (drvr.scl == 1) else
            $fatal(0, "Error - stretched clock should be 1");
            
        assert(drvr.sda == 1) else
            $fatal(0, "Error - should have NACKed");                 

        $finish;
        
end
        
endmodule
