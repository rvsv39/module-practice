`timescale 1ns/1ps

module vldrdy_distributor (
    input  wire clock,
    input  wire resetn,

    input  wire up_valid,
    output wire up_ready,

    output wire dn1_valid,
    input  wire dn1_ready,

    output wire dn2_valid,
    input  wire dn2_ready
);

reg dn1_fire_reg;
reg dn2_fire_reg;

wire up_fire  = up_valid && up_ready;
wire dn1_fire = dn1_valid && dn1_ready;
wire dn2_fire = dn2_valid && dn2_ready;

always @(posedge clock or negedge resetn) begin
    if (!resetn) begin
        dn1_fire_reg <= 0;
    end else begin
        if (up_fire) begin
            dn1_fire_reg <= 0;
        end else if (dn1_fire) begin
            dn1_fire_reg <= 1;
        end
    end
end

always @(posedge clock or negedge resetn) begin
    if (!resetn) begin
        dn2_fire_reg <= 0;
    end else begin
        if (up_fire) begin
            dn2_fire_reg <= 0;
        end else if (dn2_fire) begin
            dn2_fire_reg <= 1;
        end
    end
end

wire dn1_done = dn1_fire || dn1_fire_reg;
wire dn2_done = dn2_fire || dn2_fire_reg;
assign up_ready = dn1_done && dn2_done;

assign dn1_valid = up_valid && (!dn1_fire_reg);
assign dn2_valid = up_valid && (!dn2_fire_reg);

endmodule