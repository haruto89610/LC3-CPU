module LOGIC (
    input [15:0] BUS,
    input LD, CLK,
    output Nout, Zout, Pout
);
    reg Nin;
    reg Zin;
    reg Pin;

    registerFF N(
        .in(Nin),
        .LD(LD),
        .CLK(CLK),
        .out(Nout)
    );

    registerFF Z(
        .in(Zin),
        .LD(LD),
        .CLK(CLK),
        .out(Zout)
    );

    registerFF P(
        .in(Pin),
        .LD(LD),
        .CLK(CLK),
        .out(Pout)
    );

    always @(*) begin
        Nin = 1'b0;
        Zin = 1'b0;
        Pin = 1'b0;

        if (BUS[15:0] == 16'b0)
            Zin < 1'b1;
        else if (BUS[15] == 1'b1)
            Nin = 1'b1;
        else if (BUS[15] == 1'b0)
            Pin = 1'b1;
    end
endmodule

module BR_COMP (
    input [2:0] IR,
    input CLK, LD, N, Z, P,
    output reg BEN
);
    always @(posedge CLK) begin
        if (LD) begin
            if ((N && IR[2]) || (Z && IR[1]) || (P && IR[0]))
                assign BEN <= 1'b1;
            else
                assign BEN <= 1'b0;
        end
    end
endmodule