module alu_compare_tb;

    reg [31:0] A, B;
    reg [2:0] opcode;

    wire [31:0] ref_out;
    wire Z_ref, C_ref, V_ref, S_ref;

    wire [31:0] gen_out;
    wire carry_gen, zero_gen, V_gen;

    integer i;

    //dut
    ref_rtl REF (A, B, opcode, ref_out, Z_ref, C_ref, V_ref, S_ref);
    gen_rtl GEN (A, B, opcode, gen_out, carry_gen, V_gen, zero_gen);

    // Clock for assertions
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;

    // Counters
    integer pass_count = 0;
    integer fail_count = 0;

    
    // ASSERTIONS

    // RESULT CHECK
    property p_result;
        @(posedge clk) ref_out == gen_out;
    endproperty

    assert property (p_result)
    begin
        pass_count++;
        $display("PASS | A=%0d B=%0d OPCODE=%b RESULT=%0d TIME=%0t",
                  A, B, opcode, gen_out, $time);
    end
    else begin
        fail_count++;
        $error("FAIL RESULT | A=%0d B=%0d OPCODE=%b REF=%0d GEN=%0d TIME=%0t",
                A, B, opcode, ref_out, gen_out, $time);
    end

    // ZERO FLAG
    property p_zero;
        @(posedge clk) (gen_out == 0) |-> (zero_gen == 1);
    endproperty

    assert property (p_zero)
    else begin
        fail_count++;
        $error("FAIL ZERO | RESULT=%0d ZERO=%b TIME=%0t",
                gen_out, zero_gen, $time);
    end

    // CARRY
    property p_carry;
        @(posedge clk)
        (opcode inside {3'b000,3'b001}) |-> (carry_gen == C_ref);
    endproperty

    assert property (p_carry)
    else begin
        fail_count++;
        $error("FAIL CARRY | A=%0d B=%0d C_REF=%b C_GEN=%b TIME=%0t",
                A, B, C_ref, carry_gen, $time);
    end

    // OVERFLOW ADD
    property p_overflow_add;
        @(posedge clk)
        (opcode == 3'b000) |->
        (V_gen == ((A[31]==B[31]) && (gen_out[31]!=A[31])));
    endproperty

    assert property (p_overflow_add)
    else begin
        fail_count++;
        $error("FAIL ADD OVF | A=%0d B=%0d V=%b TIME=%0t",
                A, B, V_gen, $time);
    end

    // OVERFLOW SUB
    property p_overflow_sub;
        @(posedge clk)
        (opcode == 3'b001) |->
        (V_gen == ((A[31]!=B[31]) && (gen_out[31]!=A[31])));
    endproperty

    assert property (p_overflow_sub)
    else begin
        fail_count++;
        $error("FAIL SUB OVF | A=%0d B=%0d V=%b TIME=%0t",
                A, B, V_gen, $time);
    end

    // DIV BY ZERO
    property p_div_zero;
        @(posedge clk)
        (opcode == 3'b111 && B == 0) |-> (gen_out == 0);
    endproperty

    assert property (p_div_zero)
    else begin
        fail_count++;
        $error("FAIL DIV0 | TIME=%0t", $time);
    end

    // RANDOM + EDGE TESTING
  
    initial begin
        $display("===== STARTING ALU VERIFICATION =====");

        for (i = 0; i < 1000; i++) begin

            opcode = $urandom_range(0,7);

            case ($urandom_range(0,8))
                0: begin A = 0; B = 0; end
                1: begin A = 32'hFFFFFFFF; B = 1; end
                2: begin A = 32'h7FFFFFFF; B = 1; end
                3: begin A = 32'h80000000; B = 32'hFFFFFFFF; end
                4: begin A = $random; B = $random; end
                5: begin A = $urandom; B = $urandom; end
                6: begin A = $random % 1000; B = $random % 1000; end
                7: begin A = -($random % 1000); B = -($random % 1000); end
                8: begin A = {16'hFFFF, $random}; B = {16'h0000, $random}; end
            endcase

            if (opcode == 3'b111 && B == 0)
                B = 1;

            #10;
        end

        $display("====== TEST EXECUTION COMPLETED =======");
        $finish;
    end

    // FINAL REPORT
  
    final begin
        $display("\n======================================");
        $display("        ALU ASSERTION REPORT");
        $display("======================================");
        $display("TOTAL TESTS = %0d", pass_count + fail_count);
        $display("PASS COUNT  = %0d", pass_count);
        $display("FAIL COUNT  = %0d", fail_count);

        if (fail_count == 0)
            $display("FINAL STATUS: ALL TESTS PASSED ");
        else
            $display("FINAL STATUS: FAILURES DETECTED");

        $display("============================\n");
    end

endmodule