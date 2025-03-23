module apb_controller_tb;

reg Hclk;
reg Hresetn;
reg valid;
reg Hwrite;
reg Hwritereg;
reg [31:0] Hwdata;
reg [31:0] Haddr;
reg [31:0] Haddr1;
reg [31:0] Haddr2;
reg [31:0] Hwdata1;
reg [31:0] Hwdata2;
reg [31:0] Prdata;
reg [2:0] tempselx;
wire Pwrite;
wire Penable;
wire [2:0] Pselx;
wire [31:0] Paddr;
wire [31:0] Pwdata;
wire Hreadyout;

// Instantiate the APB_FSM_Controller module
apb_controller uut (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Prdata(Prdata),
    .Hwrite(Hwrite),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    .Pwrite(Pwrite),
    .Penable(Penable),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Hreadyout(Hreadyout)
);

// Clock generation
always #5 Hclk = ~Hclk;

// Test sequence
initial begin
    // Initialize signals
    Hclk = 0;
    Hresetn = 0;
    valid = 0;
    Hwrite = 0;
    Hwritereg = 0;
    Haddr = 32'h0000_0000;
    Hwdata = 32'h0000_0000;
    Haddr1 = 32'h0000_0000;
    Haddr2 = 32'h0000_0000;
    Hwdata1 = 32'h0000_0000;
    Hwdata2 = 32'h0000_0000;
    Prdata = 32'h0000_0000;
    tempselx = 3'b000;
    
    // Apply reset
    #10;
    Hresetn = 1;
    
    // Test the idle state
    valid = 0;
    #10;
    
    // Test a write operation
    valid = 1;
    Hwrite = 1;
    Haddr = 32'h8000_0000;
    Hwdata = 32'h1234_5678;
    tempselx = 3'b001;
    #10;
    
    // Test a read operation
    Hwrite = 0;
    Haddr = 32'h8400_0000;
    tempselx = 3'b010;
    #10;

    // Test the read enable state
    valid = 1;
    Hwrite = 0;
    Haddr = 32'h8800_0000;
    tempselx = 3'b100;
    #10;

    // Test the write enable state
    valid = 1;
    Hwrite = 1;
    Hwritereg = 1;
    Haddr2 = 32'h8C00_0000;
    Hwdata = 32'h8765_4321;
    tempselx = 3'b011;
    #10;

    // End of simulation
    $stop;
end

endmodule

