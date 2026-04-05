module gen_rtl (
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0] opcode,
    output reg [31:0] gen_result,   // result
    output reg carry,
    output reg V,            // overflow flag
    output zero
);

    always @(*) begin
        carry = 0;
        V = 0;
        gen_result= 0;

        case (opcode)

            // ADD
            3'b000: begin
                {carry, gen_result} = A + B;

                // Overflow detection (signed)
                V = (A[31] & B[31] & ~gen_result[31]) | 
                    (~A[31] & ~B[31] & gen_result[31]);
            end

            // SUB
            3'b001: begin
                {carry, gen_result} = A - B;

                // Overflow detection (signed)
                V = (A[31] & ~B[31] & ~gen_result[31]) | 
                    (~A[31] & B[31] & gen_result[31]);
            end

            // AND
            3'b010: gen_result= A & B;

            // OR
            3'b011:gen_result= A | B;

            // XOR
            3'b100: gen_result= A ^ B;

            // NOT
            3'b101: gen_result = ~A;

            // SHIFT LEFT
            3'b110:gen_result = A * B;
            

            // SHIFT RIGHT
            3'b111:gen_result = A / B;

            default: begin
                gen_result= 32'b0;
                carry = 0;
                V = 0;
            end

        endcase
    end

    // ZERO FLAG
    assign zero = (gen_result== 32'b0);

endmodule