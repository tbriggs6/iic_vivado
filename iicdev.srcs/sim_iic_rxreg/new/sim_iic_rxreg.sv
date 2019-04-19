`timescale 1ns/1ns
`default_nettype none

module sim_iic_rxreg( );

    logic clk, aresetn;
    logic iic_sda, iic_scl;
    
    control_rxreg_bus ctrl();
    register_rxreg_bus regs();
    
    iic_rxreg uut(.*);
    
    initial begin
        clk = 0;
        forever clk = #1 ~clk;
    end
    
    
    task write_byte(logic [7:0] value);
        $display("Writing byte %x", value);
        
        ctrl.enable <= 1;
        if (iic_scl == 0) begin
            iic_scl <= 1;
            #12;
        end
        
        for (int i = 0; i < 8; i++) begin
            iic_scl <= 0;
            #3;
            iic_sda <= value[i];
            #3;
            iic_scl <= 1;
            #6;                
        end
        ctrl.enable <= 0;
    endtask
            
            
                
    initial begin
        iic_sda <= 1;
        iic_scl <= 1;
        
        #12;
        write_byte(8'h63);
        write_byte(8'ha4);
    
    end
    
    
// sda cannot change on high edge of scl    
assert property
    (@(posedge clk) iic_scl == 1 |=> $stable(iic_sda)) 
         else $fatal(3,"Error - not detect start");

assert property
    (@(posedge clk) (regs.full === ctrl.done))
        else $fatal(3,"Error - done and full should be the same");    
 
 assert property
    (@(posedge clk) $rose(regs.rden) |-> ##[1:8] $rose(regs.rdack)) // and $fell(regs.full))
        else $fatal(3,"Error - raising rden should cause rdack and clear full");
    
    initial begin
        aresetn <= 0;
        regs.regs_reset( );
        ctrl.ctrl_reset( );
        
        #10;
        aresetn <= 1;
        wait(ctrl.done == 1);
        regs.rden=1;
        wait(regs.rdack == 1);
        assert(regs.data == 8'h63) 
            else $fatal(3,"Error - did not receive data 1");
             
        wait(ctrl.done == 1);
        regs.rden=1;
        wait(regs.rdack == 1);
        assert(regs.data == 8'ha4) 
            else $fatal(3,"Error - did not receive data 2");

        $display("TEST PASSED");
        $finish;
    end
endmodule