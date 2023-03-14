module matrix_transposer(
    input  wire          clk,
    input  wire          rst_n,
    
    input  wire [31:0]   m_data,
    input  wire          m_valid,
    output wire          m_ready,

    output reg  [31:0]   m2f_data,
    output reg           m2f_valid,
    input  wire          f2m_ready 
);

reg        sel; // ping pang buffer
reg [31:0] buff[4][2];
reg [1:0]  cnt_in;
reg [1:0]  cnt_out;

assign m_ready = f2m_ready; // if dn is ready, I'm ready

wire up_fire = m_valid && m_ready;
always @(posedge clk) begin
    if (up_fire) begin
        buff[cnt_in][sel] <= m_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_in <= 0;
    end else begin
        if (up_fire) begin
            cnt_in <= cnt_in + 1'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sel <= 0;
    end else begin
        if (cnt_in == 2'd3 && m_valid) begin
            sel <= ~sel;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_out <= 0;
    end else begin
        if (m2f_valid) begin
            cnt_out <= cnt_out + 1'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m2f_valid <= 0;
    end else begin
        if (cnt_in == 2'd3 && m_valid) begin
            m2f_valid <= 1'd1;
        end else if (cnt_out == 2'd3) begin
            m2f_valid <= 1'd0;
        end
    end
end

always @(*) begin
    m2f_data = 32'd0;

    if (m2f_valid) begin
        m2f_data = {
            buff[3][~sel][cnt_out * 8 +: 8], 
            buff[2][~sel][cnt_out * 8 +: 8], 
            buff[1][~sel][cnt_out * 8 +: 8], 
            buff[0][~sel][cnt_out * 8 +: 8]
        };
    end
end

endmodule