`timescale 1ns/1ns

module sync_fifo_tb();

parameter WIDTH = 8;
parameter DEPTH = 16;

reg                     clk         ;
reg                     rstn        ;

reg     [WIDTH-1:0]     data_in     ;
reg                     rd_en       ;
reg                     wr_en       ;

wire    [WIDTH-1:0]     data_out    ;
wire                    empty       ;
wire                    full        ;

always #5 clk = ~clk;

initial begin
    clk     <= 1'b0;
    rstn    <= 1'b0;
    data_in <= 'd0;
    rd_en   <= 1'b0;
    wr_en   <= 1'b0;

    //write 16 times to make fifo full
    #10
    rstn    <= 1'b1;
    repeat(16)begin
        @(negedge clk)begin
            wr_en   <= 1'b1;
            data_in <= $random; // generate 8bit random number data_in
        end
    end

    //read 16 times to make fifo empty
    repeat(16)begin
        @(negedge clk)begin
            wr_en   <= 1'b0;
            rd_en   <= 1'b1;
        end
    end

    //read and write 8 times
    repeat(8)begin
        @(negedge clk)begin
            wr_en   <= 1'b1;
            data_in <= $random;
            rd_en   <= 1'b0;
        end
    end

    //Continuous read and write
    forever begin
        @(negedge clk)begin
            wr_en   <= 1'b1;
            data_in <= $random;
            rd_en   <= 1'b1;
        end
    end
end

initial begin
    #800
    $finish();
end

initial begin
    $fsdbDumpfile("sync_fifo.fsdb");
    $fsdbDumpvars(0);
end

sync_fifo #(
    .WIDTH      (WIDTH)     ,
    .DEPTH      (DEPTH)
)u_sync_fifo
(
    .clk        (clk)       ,
    .rstn       (rstn)      ,
    .data_in    (data_in)   ,
    .rd_en      (rd_en)     ,
    .wr_en      (wr_en)     ,

    .data_out   (data_out)  ,
    .fifo_empty (empty)     ,
    .fifo_full  (full)
);

endmodule