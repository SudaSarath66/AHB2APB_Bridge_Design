module ahb_slave_tb;

reg Hclk;
reg Hresetn;
reg Hwrite;
reg Hreadyin;
reg [1:0] Htrans;
reg [31:0] Haddr;
reg [31:0] Hwdata;
reg [31:0] Prdata;
wire valid;
wire [31:0] Haddr1;
wire [31:0] Haddr2;
wire [31:0] Hwdata1;
wire [31:0] Hwdata2;
wire [31:0] Hrdata;
wire Hwritereg;
wire [2:0] tempselx;
wire [1:0] Hresp;

// Instantiate the AHB_slave_interface module
ahb_slave uut (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Htrans(Htrans),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Prdata(Prdata),
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Hrdata(Hrdata),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    .Hresp(Hresp)
);

// Clock generation
always #5 Hclk = ~Hclk;

// Test sequence
initial begin
    // Initialize signals
    Hclk = 0;
    Hresetn = 0;
    Hwrite = 0;
    Hreadyin = 1;
    Htrans = 2'b00;
    Haddr = 32'h0000_0000;
    Hwdata = 32'h0000_0000;
    Prdata = 32'h0000_0000;
    
    // Apply reset
    #10;
    Hresetn = 1;
    
    // Perform a write operation
    Hwrite = 1;
    Htrans = 2'b10;
    Haddr = 32'h8000_0000;
    Hwdata = 32'h1234_5678;
    #10;
    
    // Perform a read operation
    Hwrite = 0;
    Htrans = 2'b11;
    Haddr = 32'h8400_0000;
    Prdata = 32'h8765_4321;
    #10;

    // Test tempselx logic
    Haddr = 32'h8800_0000;
    #10;
    
    // End of simulation
    $stop;
end

endmodule
