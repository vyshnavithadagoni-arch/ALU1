// TESTBENCH WITH FUNCTIONAL COVERAGE

module alu_compare_tb;

    reg [31:0] A, B;
    reg [2:0] opcode;

    wire [31:0] ref_out;
    wire Z_ref, C_ref, V_ref, S_ref;

    wire [31:0] gen_out;
    wire carry_gen, zero_gen, V_gen;

    integer i;
    integer errors;

    // Instantiate RTLs
    ref_rtl REF (A, B, opcode, ref_out, Z_ref, C_ref, V_ref, S_ref);
    gen_rtl GEN (A, B, opcode, gen_out, carry_gen, V_gen, zero_gen);

    // COVERAGE
   
    covergroup alu_cg;

        opcode_cp: coverpoint opcode {
            bins all_ops[] = {[0:7]};
        }

        zero_cp: coverpoint zero_gen {
            bins zero_0 = {0};
            bins zero_1 = {1};
        }

        carry_cp: coverpoint carry_gen {
            bins c0 = {0};
            bins c1 = {1};
        }

        overflow_cp: coverpoint V_gen {
            bins v0 = {0};
            bins v1 = {1};
        }

        // Cross coverage
        cross opcode, zero_gen;
        cross opcode, carry_gen;
        cross opcode, V_gen;

    endgroup

    alu_cg cg = new();

    // TEST

    initial begin
        errors = 0;
        $display("Starting Test...");

        for (i = 0; i < 500; i++) begin

            opcode = $urandom_range(0,7);

            // BIASED RANDOM 
            case ($urandom_range(0,5))
                0: begin A = 0; B = 0; end
                1: begin A = 32'hFFFFFFFF; B = 1; end
                2: begin A = 32'h7FFFFFFF; B = 1; end
                3: begin A = 32'h80000000; B = 32'hFFFFFFFF; end
                4: begin A = $random; B = $random; end
                5: begin A = $random % 100; B = $random % 100; end
            endcase

            // avoid divide by zero
            if (opcode == 3'b111 && B == 0)
                B = 1;

            #10;

            cg.sample();

            // RESULT CHECK
            if (ref_out !== gen_out) begin
                $display("Mismatch A=%0d B=%0d op=%b REF=%0d GEN=%0d",
                          A, B, opcode, ref_out, gen_out);
                errors++;
            end

            // ZERO
            if (Z_ref !== zero_gen) errors++;

            // CARRY
            if ((opcode == 3'b000 || opcode == 3'b001) &&
                (C_ref !== carry_gen)) errors++;

            // OVERFLOW
            if ((opcode == 3'b000 || opcode == 3'b001) &&
                (V_ref !== V_gen)) errors++;

        end

        $display("Functional Coverage = %0.2f %%", cg.get_coverage());

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TOTAL ERRORS = %0d", errors);

        $finish;
    end

endmodule