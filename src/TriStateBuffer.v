module TRI (
    input [15:0] in,
    input ENA,
    output [15:0] out
);

    assign out = ENA ? in : 16'bz;
endmodule