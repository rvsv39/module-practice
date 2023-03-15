// hardware implementation of asciiTxt parser

// uint8_t asciiTxt[] = {0x00, 0x12, 0x23, 0x11, 0x11, 0x11, 0x11, // head
// 0x32, 0x30, 0x32, 0x33, 0x2f, 0x30, 0x33, 0x2f, 0x31, 0x35, // "2023/03/15" date
// 0x41, 0x30, // "0a 00" price
// 0x30, 0x32, // "00 02"   num
// 0x00, 0x11, 0x00, 0x11 // tail
// };

module parser(
    input wire          clk,
    input wire          rst_n,

    // input bus and valid
    input wire  [7:0]   data,
    input wire          data_valid,

     // output bus and valid
    output reg          out_valid,
    output reg [7:0]    date [8],
    output reg [7:0]  price[2],
    output reg [7:0]  num[2]
);

localparam logic [7:0] HEAD[4] = {8'h11, 8'h11, 8'h11, 8'h11};
localparam logic [7:0] TAIL[4] = {8'h00, 8'h11, 8'h00, 8'h11};

localparam logic [1:0] IDLE = 2'b01;
localparam logic [1:0] WORK = 2'b10;

// FSM
reg [1:0] cur_state, nxt_state;

always @(posedge clk) begin
    if (!rst_n) begin
        cur_state <= IDLE;
    end else begin
        cur_state <= nxt_state;
    end
end

reg [31:0] shft_reg;
always @(posedge clk) begin
    if (!rst_n) begin
        shft_reg <= '0;
    end else begin
        shft_reg <= data_valid ? {shft_reg[23:0], data} : shft_reg;
    end
end

wire to_work = shft_reg[0  +: 8] == HEAD[3] &&
               shft_reg[8  +: 8] == HEAD[2] &&
               shft_reg[16 +: 8] == HEAD[1] &&
               shft_reg[24 +: 8] == HEAD[0] ;

wire to_idle = shft_reg[0  +: 8] == TAIL[3] &&
               shft_reg[8  +: 8] == TAIL[2] &&
               shft_reg[16 +: 8] == TAIL[1] &&
               shft_reg[24 +: 8] == TAIL[0] ;

always @(*) begin
    unique case (cur_state)
        IDLE: begin
            nxt_state <= to_work ? WORK : cur_state;
        end
        WORK: begin
            nxt_state <= to_idle ? IDLE : cur_state;
        end
    endcase
end

reg [3:0] cnt;
always @(posedge clk) begin
    if (!rst_n) begin
        cnt <= '0;
    end else begin
        if (cur_state == WORK && data_valid) begin
            cnt <= cnt + 1;
        end else if (cur_state == IDLE) begin
            cnt <= '0;
        end
    end
end

always @(posedge clk) begin
    if (cur_state == WORK && data_valid) begin
       case (cnt) inside
        [4'h0 : 4'h7]: begin
            date[cnt] <= data;
        end
        [4'h8 : 4'h9]: begin
            price[cnt - 4'd8] <= data;
        end
        [4'ha : 4'hb]: begin
            num[cnt - 4'd10] <= data;
        end
       endcase
    end
end

endmodule