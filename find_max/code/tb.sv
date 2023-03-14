module tb();

reg       clk;
reg       rst_n;
reg [4:0] datain;
reg       datain_ena;

wire [4:0]  max;
wire [4:0]  submax;
wire        dataout_ena;

initial begin
    clk = 0;
end

always #1 clk <= ~clk;

initial begin
    rst_n = 0;
    #10
    rst_n = 1;
    @(negedge clk);
    datain_ena = 1;
    datain = 0;

    repeat(6) begin
        @(negedge clk);
        datain = $urandom_range(5'h1f, 0);
    end

    @(negedge clk);
    datain_ena = 0;

    #10;
    $finish();
end

initial begin
    $fsdbDumpvars(0);
end

find_max find_max_inst(.*);

endmodule