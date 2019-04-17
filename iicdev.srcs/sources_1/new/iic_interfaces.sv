`timescale 1ns / 1ps
`default_nettype none

/** Style requirement: bus names are alphabetical */
interface clock_control_bus;
    logic restart, reset, done;
    wire scl;
    
    modport clk  (input reset, restart, output done, scl);
    modport ctrl (output reset, restart, input done, scl);
    
endinterface

interface clock_driver_bus;
    wire scl;
    wire sda;
    
    modport clk  (output scl, sda);
    modport drvr (input scl, sda);
endinterface

interface clock_regs_bus #(parameter WIDTH=10);
    wire [WIDTH-1:0] divider;
    
    modport clk  (input divider);
    modport regs (output divider);
    
endinterface



interface control_driver_bus;
    wire src_clock;
    wire src_sgen;
    
    modport ctrl  (output src_clock, src_sgen);
    modport drvr (input src_clock, src_sgen);
endinterface




// interface between control unit and register file
interface control_regs_bus;
    wire on, start, busy;
    
    modport ctrl (input on, start, output busy );
    modport regs (output on, start, input busy );
endinterface

interface control_sdetect_bus;
    wire start_detected, stop_detected;
    
    modport ctrl (input start_detected, stop_detected);
    modport sdet (output start_detected, stop_detected);
endinterface 


interface control_sgen_bus;
    logic gen_start, gen_stop;
    
    modport ctrl (output gen_start, gen_stop);
    modport sgen (input gen_start, gen_stop);
    
endinterface


interface driver_sgen_bus;
    wire scl;
    wire sda;
    
    modport sgen (output scl, sda);
    modport drvr (input scl, sda);
endinterface

         