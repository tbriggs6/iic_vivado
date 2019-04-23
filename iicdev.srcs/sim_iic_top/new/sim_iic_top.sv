module sim_iic_top( );

logic clk, aresetn;
wire iic_sda, iic_scl;
register_user_bus user_regs();

pullup p1 (iic_sda);
pullup p2 (iic_scl);


iic_top uut(.*);

initial begin
    clk = 0;
    forever clk = #1 ~clk;
end

logic [3:0] regnum;
logic [31:0] write_data;
logic rden, wren;
wire [31:0] read_data = user_regs.regdata;

assign user_regs.regnum = regnum;
assign user_regs.rden = rden;
assign user_regs.wren = wren;
assign user_regs.regdata = (wren == 1) ? write_data : 32'bz;

task write_register(logic [3:0] num, logic [31:0] data);
    @(negedge clk);
    regnum = num;
    write_data = data;
    rden = 0;
    wren = 1;
  
    #4;
    @(negedge clk);
    wren <= 0;
endtask    



initial begin
    wait(iic_scl == 1) && (iic_sda == 0);
    $display("start detected.");
  
end

initial begin
    aresetn = 0;
    #10;
    aresetn = 1;
    
    // set clock divider
    write_register(4, 10);
    
    // turn unit on
    write_register(0, 16'b1000000000000000);
    
    // initiate a start 
    write_register(0, 16'b1000000000000001);
    
    
    $finish;
    
end
    

endmodule