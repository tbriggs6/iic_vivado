`timescale 1ns / 1ps
`default_nettype none


interface iic_sdetect_if;
logic start_detected, stop_detected;

// modports named for the perspective of the device making the connection

// from the perspective of the control unit
modport ctrl (input start_detected, stop_detected);

modport sdetect (output start_detected, stop_detected);

endinterface


module iic_sdetect(
    input wire clk,
    input wire aresetn,
    
    input wire scl, 
    input wire sda,
    
    iic_sdetect_if.sdetect ctrl
    );

logic last_sda;
logic start_detected;
logic stop_detected;

always @(posedge clk) begin
    if (aresetn == 0) begin
        start_detected <= 0;
        stop_detected <= 0;
        last_sda <= sda;
    end
    else begin
        if ((scl == 1) && (last_sda == 1) && (sda == 0))
            start_detected <= 1;
        if ((scl == 1) && (last_sda == 0) && (sda == 1))
            stop_detected <= 1;
        if (scl == 0) begin
            start_detected <= 0;
            stop_detected <= 0;
        end
                    
    last_sda <= sda;
    end // end else
end // end always block    

assign ctrl.start_detected = start_detected;
assign ctrl.stop_detected = stop_detected;
    
endmodule
