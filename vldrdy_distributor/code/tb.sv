`timescale 1ns/1ns

module ready_valid_distributor_tb ();
logic clock = '0;
logic resetn;

logic up_valid = '0;
logic up_ready;

logic dn1_valid;
logic dn1_ready = '0;

logic dn2_valid;
logic dn2_ready = '0;

always @(negedge clock) dn1_ready = $urandom();
always @(negedge clock) dn2_ready = $urandom();

initial begin
     $fsdbDumpfile("wave.fsdb");
     $fsdbDumpvars();
//    $dumpfile("dump.vcd");
//    $dumpvars;
    resetn = '0;
    #4;
    resetn = '1;
    #4;
    up_stimulus();
    #10;
    $finish();
end

task up_stimulus();
    @(negedge clock);
    up_valid = 1;
    for (int i = 0; i < 32; i++) begin
        int rand_delay;
        std::randomize(rand_delay) with { rand_delay dist { 0 := 5, [1 : 3] := 1 }; };
        if (rand_delay != 0) begin
            up_valid = '0;
            #(rand_delay * 2);
            up_valid = '1;
        end
        @(posedge clock && up_ready && up_valid);
        @(negedge clock);
    end
    up_valid = 0;
endtask

always #1 clock = ~clock;

always @(posedge clock) if (up_ready && up_valid)   $display("up  fire @%t", $time);
always @(posedge clock) if (dn1_ready && dn1_valid) $display("dn1 fire @%t", $time);
always @(posedge clock) if (dn2_ready && dn2_valid) $display("dn2 fire @%t", $time);

vldrdy_distributor dut (.*);

endmodule