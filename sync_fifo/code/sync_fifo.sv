module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input                       clk         ,
    input                       rstn        ,   // reset while rstn is negative

    //write interface
    input       [WIDTH-1:0]     data_in     ,   // input data
    input                       wr_en       ,   // write enable

    //read interface
    input                       rd_en       ,   // read enable
    output  reg    [WIDTH-1:0]  data_out    ,

    output  wire                fifo_empty  ,
    output  wire                fifo_full
);

reg [clog(DEPTH) : 0] wr_ptr; // the highest bit for FIFO state judgement
reg [clog(DEPTH) : 0] rd_ptr;

// FIFO state
wire full = (wr_ptr[clog(DEPTH) - 1 : 0] == rd_ptr[clog(DEPTH) - 1 : 0]) &&
            (wr_ptr[clog(DEPTH)] != rd_ptr[clog(DEPTH)]);
wire empty = wr_ptr == rd_ptr;
assign fifo_full = full;
assign fifo_empty = empty;

// pointer
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wr_ptr <= '0;
    end else begin
        if (wr_en && !full) begin
            wr_ptr <= wr_ptr + 1;
        end
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rd_ptr <= '0;
    end else begin
        if (rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
end

// dual port ram
reg [WIDTH - 1 : 0] ram [0 : DEPTH - 1];
always @(posedge clk) begin
    if (wr_en) begin
        ram[wr_ptr[clog(DEPTH) - 1 : 0]] <= data_in;
    end
end

always @(posedge clk) begin
    if (rd_en) begin
        data_out <= ram[rd_ptr[clog(DEPTH) - 1 : 0]];
    end
end

// clog
function integer clog (input integer depth); // 16 -> 2 ^ 4 -> 4
    for (clog = 0; depth - 1 > 0; clog = clog + 1) begin
        depth = depth >> 1;
    end
    // $display("depth = %d", clog);
endfunction

endmodule