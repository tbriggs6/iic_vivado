`timescale 1ns / 1ps
`default_nettype none

interface ackdet_control_bus;
    logic ack_detected;
    logic ack_nack;
    logic enabled;
    
    modport ctrl (input ack_detected, ack_nack, output enabled,
        import control_reset, set_enabled);
    modport adet (output ack_detected, ack_nack, input enabled,
        import adet_reset, detected);
    
    task control_reset( );
        enabled <= 0;
    endtask
    
    task set_enabled(bit val);
        enabled <= val;
    endtask
    
    
    task adet_reset( );
        ack_detected <= 0;
        ack_nack <= 0;
    endtask
    
    task detected(bit acknack);
        ack_detected <= 1;
        ack_nack <= acknack;
    endtask        
endinterface

interface ackdet_register_bus;
    logic ack_detected;
    logic ack_nack;
    
    modport regs (input ack_detected, ack_nack);
    modport adet (output ack_detected, ack_nack,
        import adet_reset, detected);
    
    task adet_reset( );
        ack_detected <= 0;
        ack_nack <= 0;
    endtask
    
    task detected(bit acknack);
        ack_detected <= 1;
        ack_nack <= acknack;
    endtask        
    
    
endinterface

interface ackgen_control_bus;
    logic stretch;
    
    modport agen (input stretch);
    modport ctrl (output stretch,
        import control_reset, set_stretch);
    
    task control_reset( );
        stretch <= 0;
    endtask

    task set_stretch(bit value);
        stretch <= value;
    endtask
        
endinterface     


interface ackgen_driver_bus;
    wire scl;
    wire sda;
    
    modport agen (output scl, sda);
    modport drvr (input scl, sda);
endinterface


interface ackgen_registers_bus;
    logic ack_nack;
     
    modport agen (input ack_nack);
    modport regs (output ack_nack,
        import regs_reset, set_acknack);
    
    task regs_reset( );
        ack_nack <= 0;
    endtask
    
    task set_acknack(bit value);
        ack_nack <= value;
    endtask
endinterface     



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
    logic src_agen;
    
    import control_enums::*;
      
    modport ctrl  (output src_sgen, src_txbuf, src_agen,
        import control_reset, set_source);
        
    modport drvr (input src_sgen, src_txbuf, src_agen);
    
    task control_reset();
        src_sgen <= 0;
        src_txbuf <= 0;
        src_agen <= 0;
    endtask
    
    task set_source(clock_source_t src);
        src_sgen <= 0;
        src_txbuf <= 0;
        src_agen <= 0;
        
        case(src)
        SRC_SGEN: src_sgen <= 1; 
        SRC_TXBUF: src_txbuf <= 1;
        SRC_AGEN: src_agen <= 1;
        endcase
    endtask
    
endinterface




// interface between control unit and register file
interface control_regs_bus;
    wire on;
    wire start, restart, stop;
    wire clr_start, clr_restart, clr_stop;
    
    wire rcen, acken, sclrel;
    wire clr_rcen, clr_acken, clr_sclrel;
    
    wire ackdet;
    wire stren, a10m;
    wire dhen, ahen; 
    wire busy;
    
    wire slv_rdnwr, slv_dna, slv_acktim;
    wire ack_det;
    
    modport ctrl (input on, start, restart, stop, rcen, acken, ackdet, stren, a10m, sclrel, dhen, ahen, 
            output busy, clr_start, clr_restart, clr_stop, clr_rcen, clr_acken, clr_sclrel, slv_rdnwr, slv_dna, slv_acktim, ack_det);
            
    modport regs (output on, start, restart, stop, rcen, acken, ackdet, stren, a10m, sclrel, dhen, ahen, 
            input busy, clr_start, clr_restart, clr_stop, clr_rcen, clr_acken, clr_sclrel, slv_rdnwr, slv_dna, slv_acktim, ack_det );
    
endinterface


interface control_rxreg_bus;
    logic done;
    logic enable;
    
    modport ctrl(output enable, input done, 
        import control_reset, set_enable);
        
    modport rreg(input enable, output done,
        import rreg_reset, set_done);
     
     task control_reset();
        enable <= 0;
     endtask
     
     task set_enable(bit value);
        enable <= value;
     endtask
     
     task rreg_reset( );
        done <= 0;
     endtask
     
     task set_done(bit value);
        done <= value;
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




interface register_rxreg_bus;
    logic [7:0] data;
    logic rden;
    logic rdack;
    logic full;
    logic ovflow;
    logic clr_ovflow;
    
    modport regs(input data, rdack, full, ovflow, output rden, clr_ovflow,
        import regs_reset);
        
    modport rreg(input rden, clr_ovflow, output data, rdack, full,
        import rreg_reset);
    
    task regs_reset( );
        rden <= 0;
        clr_ovflow <= 0;
    endtask
    
    task rreg_reset( );
        rdack <= 0;
        data <= 0;
        full <= 0;
        ovflow <= 0;
    endtask
    
endinterface


interface register_sdetect_bus;
    wire start_detected, stop_detected;
    logic clr_start, clr_stop;
    
    modport regs (input start_detected, stop_detected, output clr_start, clr_stop,
        import regs_reset);
    modport sdet (output start_detected, stop_detected, input clr_start, clr_stop); 
    
    task regs_reset( );
        clr_start <= 0;
        clr_stop <= 0;
    endtask        
    
endinterface 



interface register_txreg_bus;
    wire [7:0] data;
    wire wren;
    logic wrack;
    wire full;
    wire busy;
    
    modport regs(output data, wren, input wrack, full, busy);
    modport treg(input data, wren, output wrack, full, busy,
        import txreg_reset, set_wrack);

    
    task txreg_reset( );
        wrack <= 0;
    endtask
    
    task set_wrack(bit value);
        wrack <= value;
    endtask
    
endinterface
    
        
        
        
interface register_user_bus;
    wire [3:0] regnum;
    wire [31:0] regdata;
    wire rden;
    wire wren;

    modport regs(input regnum, rden, wren, inout regdata);
    modport user(output regnum, rden, wren, inout regdata);
    
endinterface          
            
            
            
            