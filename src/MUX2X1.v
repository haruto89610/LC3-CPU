module MUX2X1 (
    input [15:0] in1, in0,
    input MUXsel,
    output reg [15:0] MUXout
);

    always @(*) begin
        case(MUXsel)
            1'b0: MUXout = in0;
            1'b1: MUXout = in1;
            default: MUXout = 16'b0;
        endcase
    end
endmodule