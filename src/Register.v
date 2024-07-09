module register(
    input LD,
    input [15:0] in,
    output reg [15:0] out
);

    always @(posedge LD) begin
        out <= in;
    end
endmodule