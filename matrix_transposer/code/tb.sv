module tb();

reg clk, rst_n;
reg [31:0]  m_data;
reg         m_valid;
reg         f2m_ready;
wire        m_ready;
wire [31:0] m2f_data;
wire        m2f_valid;

initial begin
    f2m_ready = 1;
end

always #2 clk = ~clk;

initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    #8
    #1
    rst_n = 1'b1;
    
    @(negedge clk);
    m_valid = 1'd1;
    m_data = 32'h03020100;

    repeat(3)begin
        @(negedge clk)begin
            m_data <= m_data + 32'h10101010;
        end
    end

    @(negedge clk);
    m_valid <= 1'b0;

    repeat(3) @(negedge clk);

    repeat(4) begin
        @(negedge clk)begin
            m_valid <= 1'b1;
            m_data <= m_data + 32'h10101010;
        end
    end

    @(negedge clk);
    m_valid <= 1'b0;


    #50ns;
    $finish();
end

initial begin
    forever begin
        @(posedge clk)begin
            if(m_valid == 1'b1)begin
                $display("m_data = %d", m_data);
            end
        end
    end
end

initial begin
    forever begin
        @(posedge clk)begin
            if(m2f_valid == 1'b1)begin
                $display("m2f_data = %d", m2f_data);
            end
        end
    end
end

matrix_transposer matrix_transposer_inst(.*);

initial begin
    $fsdbDumpvars(0, tb);
end

endmodule


