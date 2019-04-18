`timescale 1ns / 1ps
`default_nettype none


module iic_sdetect(
    input wire clk,
    input wire aresetn,
    
    input wire iic_scl, 
    input wire iic_sda,
    
    control_sdetect_bus sdet
    );

logic last_sda;

always @(posedge clk) begin
    if (aresetn == 0) begin
       
       sdet.sdetect_reset();
       
        last_sda <= iic_sda;
    end
    else begin
        if ((iic_scl == 1) && (last_sda == 1) && (iic_sda == 0))
            sdet.set_start_detected();
        if ((iic_scl == 1) && (last_sda == 0) && (iic_sda == 1))
            sdet.set_stop_detected();
        if (iic_scl == 0) begin
            sdet.sdetect_reset();
        end
                    
    last_sda <= iic_sda;
    end // end else
end // end always block    

endmodule
