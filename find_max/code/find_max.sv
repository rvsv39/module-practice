// implement both in sv and c, fit the software part interview

module find_max(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [4:0] datain,
    input  wire       datain_ena,
    output reg  [4:0] max,
    output reg  [4:0] submax,
    output reg        dataout_ena
);

// falling edge detection
reg datain_ena_d1;
always @(posedge clk) begin
    datain_ena_d1 <= datain_ena;
end

// find max
always @(posedge clk) begin
    if (!rst_n) begin
        max <= '0;
        submax <= '0;
    end
    else if (datain_ena) begin
        max <= (datain > max) ? datain : max;
        submax <= (datain > max) ? max : submax;
    end
end

// output
wire out_ena = ~datain_ena && datain_ena_d1;
always @(posedge clk) begin
    if (out_ena) begin
        dataout_ena <= 1;
    end else begin
        dataout_ena <= 0;
    end
end

endmodule