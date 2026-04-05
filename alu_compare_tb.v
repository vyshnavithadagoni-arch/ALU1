

module alu_compare_tb;

    reg [31:0] A, B;
    reg [2:0] opcode;

    wire [31:0] ref_out;
    wire Z_ref, C_ref, V_ref, S_ref;

    wire [31:0] gen_out;
    wire carry_gen, zero_gen, V_gen;

    integer i;
    integer errors;

    // Instantiate reference RTL
    ref_rtl REF (
        .A(A),
        .B(B),
        .opcode(opcode),
        .ref_out(ref_out),
        .Z(Z_ref),
        .C(C_ref),
        .V(V_ref),
        .S(S_ref)
    );

    // Instantiate generated RTL
    gen_rtl GEN (
        .A(A),
        .B(B),
        .opcode(opcode),
        .gen_result(gen_out),
        .carry(carry_gen),
        .V(V_gen),
        .zero(zero_gen)
    );

    initial begin
        errors = 0;
        $display("Starting Test...");

        for (i = 0; i < 20; i = i + 1) begin
            A = $random;
            B = $random;
            opcode = $random % 6; // avoid mismatch ops

            #10;

            // Compare result
            if (ref_out !== gen_out) begin
                $display(" RESULT MISMATCH A=%0d B=%0d op=%b REF=%0d GEN=%0d",
                          A, B, opcode, ref_out, gen_out);
                errors = errors + 1;
            end

            // Compare ZERO
            if (Z_ref !== zero_gen) begin
                $display(" ZERO MISMATCH REF=%b GEN=%b", Z_ref, zero_gen);
                errors = errors + 1;
            end

            // Compare CARRY
            if ((opcode == 3'b000 || opcode == 3'b001) &&
                (C_ref !== carry_gen)) begin
                $display(" CARRY MISMATCH REF=%b GEN=%b", C_ref, carry_gen);
                errors = errors + 1;
            end

            // Compare OVERFLOW
            if ((opcode == 3'b000 || opcode == 3'b001) &&
                (V_ref !== V_gen)) begin
                $display(" OVERFLOW MISMATCH REF=%b GEN=%b", V_ref, V_gen);
                errors = errors + 1;
            end
        end

        if (errors == 0)
            $display(" ALL TESTS PASSED");
        else
            $display(" TOTAL ERRORS = %0d", errors);

        $finish;
    end

endmodule