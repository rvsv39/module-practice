module tb();
reg          clk;
reg          rst_n;
reg  [7:0]   data;
reg          data_valid;
wire         out_valid;
wire [7:0]   date [8];
wire [7:0]   price[2];
wire [7:0]   num[2];

initial begin
    clk = 0;
end

always #1 clk <= ~clk;

initial begin
    rst_n = 0;
    #10
    rst_n = 1;
    @(negedge clk);
    data_valid = 1;
    data = 0;


    @(negedge clk);
    data_valid = 1;
    data = 8'h11;
    @(negedge clk);
    data_valid = 1;
    data = 8'h11;
    @(negedge clk);
    data_valid = 1;
    data = 8'h11;
    @(negedge clk);
    data_valid = 1;
    data = 8'h11;


    repeat(12) begin
        @(negedge clk);
        data = $urandom_range(5'h1f, 0);
    end

    @(negedge clk);
    data_valid = 1;
    data = 8'h00;
    @(negedge clk);
    data_valid = 1;
    data = 8'h11;
    @(negedge clk);
    data_valid = 1;
    data = 8'h00;
    @(negedge clk);
    data_valid = 1;
    data = 8'h11;


    @(negedge clk);
    data_valid = 0;

    #10;
    foreach (date[i])
        $display("date[%0d]=%2h", i, date[i]);
    foreach (price[i])
        $display("price[%0d]=%2h", i, price[i]);
    foreach (num[i])
        $display("num[%0d]=%2h", i, num[i]);
    $finish();
end

initial begin
    $fsdbDumpvars(0);
end

parser parser_inst(.*);

endmodule