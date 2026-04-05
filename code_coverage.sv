module testbench;

    // Inputs
    reg [31:0] A, B;
    reg [2:0] opcode;

    // Outputs
    wire [31:0] gen_result;
    wire carry;
    wire V;
    wire zero;

    // DUT
    gen_rtl dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .gen_result(gen_result),
        .carry(carry),
        .V(V),
        .zero(zero)
    );

    // =============================
    // COVERAGE VARIABLES
    // =============================
    integer cov_add = 0;
    integer cov_sub = 0;
    integer cov_and = 0;
    integer cov_or  = 0;
    integer cov_xor = 0;
    integer cov_not = 0;
    integer cov_mul = 0;
    integer cov_div = 0;

    integer cov_zero = 0;
    integer cov_overflow = 0;
    integer cov_div_by_zero = 0;

    integer i;

    // =============================
    // TASK: COVERAGE UPDATE
    // =============================
    task update_coverage;
        begin
            // Opcode coverage
            case(opcode)
                3'b000: cov_add++;
                3'b001: cov_sub++;
                3'b010: cov_and++;
                3'b011: cov_or++;
                3'b100: cov_xor++;
                3'b101: cov_not++;
                3'b110: cov_mul++;
                3'b111: cov_div++;
            endcase

            // Zero case
            if (gen_result == 0)
                cov_zero++;

            // Overflow
            if (V == 1)
                cov_overflow++;

            // Division by zero
            if (opcode == 3'b111 && B == 0)
                cov_div_by_zero++;
        end
    endtask

    // =============================
    // TEST + COVERAGE
    // =============================
    initial begin

        // -------- Directed Tests --------
        A = 32'h7FFFFFFF; B = 1; opcode = 3'b000; #1; update_coverage(); // ADD overflow
        A = 32'h80000000; B = 1; opcode = 3'b001; #1; update_coverage(); // SUB overflow
        A = 0; B = 0; opcode = 3'b010; #1; update_coverage();           // ZERO case
        A = 10; B = 0; opcode = 3'b111; #1; update_coverage();          // DIV by zero

        // -------- Random Tests --------
        for (i = 0; i < 100; i = i + 1) begin
            A = $random;
            B = $random;
            opcode = $urandom_range(0,7)[2:0];  // FIXED (no warning)

            #1;
            update_coverage();
        end

        // =============================
        // COVERAGE REPORT
        // =============================
        $display("\n===== FUNCTIONAL COVERAGE REPORT =====");

        $display("ADD  covered : %0d", cov_add);
        $display("SUB  covered : %0d", cov_sub);
        $display("AND  covered : %0d", cov_and);
        $display("OR   covered : %0d", cov_or);
        $display("XOR  covered : %0d", cov_xor);
        $display("NOT  covered : %0d", cov_not);
        $display("MUL  covered : %0d", cov_mul);
        $display("DIV  covered : %0d", cov_div);

        $display("\nZERO cases        : %0d", cov_zero);
        $display("OVERFLOW cases    : %0d", cov_overflow);
        $display("DIV BY ZERO cases : %0d", cov_div_by_zero);

       // Final check
if (cov_add>0 && cov_sub>0 && cov_and>0 && cov_or>0 &&
    cov_xor>0 && cov_not>0 && cov_mul>0 && cov_div>0) begin
    $display("\n✔ FULL OPCODE COVERAGE ACHIEVED");
    $display("Opcode Coverage: 100%%");   
end
else
    $display("\n✘ SOME OPCODES NOT COVERED");

$finish;
    end

endmodule