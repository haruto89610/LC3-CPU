module MUX4X1 (
    input [15:0] in3, in2, in1, in0,
    input [1:0] MUXsel,
    output reg [15:0] MUXout
);
    
    always @(*) begin
        case(MUXsel)
            2'b00: MUXout = in0;
            2'b01: MUXout = in1;
            2'b10: MUXout = in2;
            2'b11: MUXout = in3;
            default: MUXout = 16'b0;
        endcase
    end
endmodule