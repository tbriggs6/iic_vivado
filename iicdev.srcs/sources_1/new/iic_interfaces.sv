`timescale 1ns / 1ps
`default_nettype none

/** Style requirement: bus names are alphabetical */
interface clock_control_bus;
    logic restart, reset, done;
    wire scl;
    
    modport clk  (input reset, restart, output done, scl,
        import clock_reset, clock_done);
    modport ctrl (output reset, restart, input done, scl,
        import control_reset, set_reset, set_restart);
    
    task clock_reset();
        done <= 0;
    endtask
    
    task clock_done( );
        done <= 1;
    endtask
    
    task control_reset();
        restart <= 0;
        reset <= 0;
    endtask
    
    task set_reset(bit val);
        reset <= val;
    endtask
    
    task set_restart(bit val);
        restart <= val;
    endtask
endinterface

interface clock_driver_bus;
    wire scl;
    wire sda;
    
    modport clk  (output scl, sda);
    modport drvr (input scl, sda);
endinterface

interface clock_regs_bus #(parameter WIDTH=10);
    logic [WIDTH-1:0] divider;
    
    modport clk  (input divider);
    modport regs (output divider, import regs_reset);
    
    task regs_reset( );
        divider <= 0;
    endtask
    
endinterface


import control_enums::*;

interface control_driver_bus;
    logic src_sgen;
    logic src_txbuf;
    import control_enums::*;
      
    modport ctrl  (output src_sgen, src_txbuf,
        import control_reset, set_source);
        
    modport drvr (input src_sgen, src_txbuf);
    
    task control_reset();
        src_sgen <= 0;
        src_txbuf <= 0;
    endtask
    
    task set_source(clock_source_t src);
        src_sgen <= 0;
        src_txbuf <= 0;
        case(src)
        SRC_SGEN: src_sgen <= 1; 
        SRC_TXBUF: src_txbuf <= 1;
        endcase
    endtask
    
endinterface




// interface between control unit and register file
interface control_regs_bus;
    logic on, start;
    wire busy;
    
    modport ctrl (input on, start, output busy );
    modport regs (output on, start, input busy );
    
    task regs_reset();
        on <= 0;
        start <= 0;
    endtask
    
endinterface

interface control_sdetect_bus;
    logic start_detected, stop_detected;
    
    modport ctrl (input start_detected, stop_detected);
    modport sdet (output start_detected, stop_detected, 
        import sdetect_reset, set_start_detected, set_stop_detected);
    
    
    task sdetect_reset();
        start_detected <= 0;
        stop_detected <= 0;
    endtask
    
    task set_start_detected();
        start_detected <= 1;
        stop_detected <= 0;
    endtask
    
    task set_stop_detected();
        stop_detected <= 1;
        start_detected <= 0;
    endtask
    
endinterface 


interface control_sgen_bus;
    logic gen_start, gen_stop;
    
    modport ctrl (output gen_start, gen_stop,  
        import control_reset, set_gen_start, set_gen_stop);
    modport sgen (input gen_start, gen_stop);
    
    task control_reset( );
        gen_start <= 0;
        gen_stop <= 0;
    endtask
    
    task set_gen_start();
        gen_start <= 1;
        gen_stop <= 0;
    endtask;
    
    task set_gen_stop();
        gen_start <= 0;
        gen_stop <= 1;
    endtask;
    
endinterface


interface control_txreg_bus;
    logic done;
    logic enable;
    
    modport ctrl(output enable, input done, 
        import control_reset, set_enable);
    modport treg(input enable, output done,
        import txreg_reset, set_done);
     
     task control_reset();
        enable <= 0;
     endtask
     
     task set_enable(bit value);
        enable <= value;
     endtask
     
     task txreg_reset( );
        done <= 0;
     endtask
     
     task set_done(bit value);
        done <= value;
     endtask
     
endinterface

interface driver_sgen_bus;
    wire scl;
    wire sda;
    
    modport sgen (output scl, sda);
    modport drvr (input scl, sda);
endinterface

interface driver_txreg_bus;
    wire scl;
    wire sda;
    
    modport treg (output scl, sda);
    modport drvr (input scl, sda); 
endinterface

interface register_txreg_bus;
    wire [7:0] data;
    wire wren;
    logic wrack;
    wire full;

    modport regs(output data, wren, input wrack, full);
    modport treg(input data, wren, output wrack, full,
        import txreg_reset, set_wrack);

    task txreg_reset( );
        wrack <= 0;
    endtask
    
    task set_wrack(bit value);
        wrack <= value;
    endtask
    
endinterface
    
        