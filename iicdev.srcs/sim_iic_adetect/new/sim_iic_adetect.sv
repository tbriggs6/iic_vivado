`default_nettype none
`timescale 1ns/1ns

module sim_iic_adetect( );

    logic clk, aresetn;
    logic iic_sda, iic_scl;
    
    ackdet_register_bus regs();
    ackdet_control_bus ctrl();
    
    
    iic_adetect uut( .* );
    
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end
    
    initial begin
    
        aresetn = 0;
        iic_sda <= 1;
        iic_scl <= 0;
        
        #10;
        aresetn = 1;
        
        @(negedge clk);
        ctrl.enabled <= 1;
        #4;
        iic_scl <= 1;
        #4;
        assert (regs.ack_detected == 1) 
            else $fatal(3, "REGS ACK was not detected.");
        assert (ctrl.ack_detected == 1)
            else $fatal(3, "CTRL ACK was not detected.");
            
        assert (regs.ack_nack == 1)
            else $fatal(3,"REGS ACK was not NACK");
        assert (ctrl.ack_nack == 1)
            else $fatal(3,"CTRL ACK was not NACK");
                         
        ctrl.enabled <= 0;
        iic_scl <= 0;
        
        #4;
        assert (regs.ack_detected == 0) 
            else $fatal(3, "REGS ACK was detected, but should be clear");
        assert (ctrl.ack_detected == 0) 
            else $fatal(3, "CTRL ACK was detected, but should be clear");

        ctrl.enabled <= 1;
        iic_sda <= 0;    
        #4;
        iic_scl <= 1;
        #4;
        assert (regs.ack_detected == 1) 
            else $fatal(3, "REGS ACK was not detected.");
        assert (ctrl.ack_detected == 1)
            else $fatal(3, "CTRL ACK was not detected.");
            
        assert (regs.ack_nack == 0)
            else $fatal(3,"REGS ACK was not NACK");
        assert (ctrl.ack_nack == 0)
            else $fatal(3,"CTRL ACK was not NACK");

        $finish;
end

endmodule