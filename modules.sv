module tristate (
    input [15:0] in,
    input OE,
    output wire [15:0] out
);
    assign out = OE? in : 16'bZ;
endmodule

module mux2x1 #(parameter BIT = 16) (
    input [BIT-1:0] in0,
    input [BIT-1:0] in1,
    input select,
    output reg [BIT-1:0] out
);
    always @(*) begin
        case(select)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = {BIT{1'bZ}};
        endcase
    end
endmodule

module mux4x1 #(parameter BIT = 16) (
    input [BIT-1:0] in0,
    input [BIT-1:0] in1,
    input [BIT-1:0] in2,
    input [BIT-1:0] in3,
    input select1, select0,
    output reg [BIT-1:0] out
);  
    always @(*) begin
        case({select1, select0})
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = {BIT{1'bZ}};
        endcase
    end
endmodule

module registerFF (
    input [15:0] in,
    input LD, CLK,
    output reg [15:0] out
);
    always @(posedge CLK) begin
        if (LD) out <= in;
    end
endmodule

module RAM (
    input [15:0] DataIn,
    input [15:0] ADDR,
    input WE, CS, CLK,
    output reg [15:0] out,
    output reg ready
);

    reg [15:0] memory [0:2**16];

    initial begin // PLACE INSTRUCTION HERE
        memory[0] <= 16'b0101000000100000;
        memory[1] <= 16'b0101001001100000;
        memory[2] <= 16'b0101010010100000;
        memory[3] <= 16'b0010000000000010;
        memory[4] <= 16'b0010001000000010;
        memory[5] <= 16'b0001010001000000;
        memory[6] <= 16'h000a;
        memory[7] <= 16'h0005;
        ready = 1'b0;
    end

    always @(*) begin
        if (CS) begin
            ready <= 1'b0;
            if (WE) begin
                memory[ADDR] <= DataIn;
                out <= 16'bZ;
                ready <= 1'b0;
            end else if (!WE && CS) begin
                out <= memory[ADDR];
                ready <= 1'b1;
            end
        end
    end
endmodule

module REG_FILE (
    input [15:0] DataIn,
    input [2:0] DR,
    input [2:0] SR1,
    input [2:0] SR2,
    input LD, CLK,
    output reg [15:0] SR1out,
    output reg [15:0] SR2out
);
    reg [15:0] memory [7:0];

    always @(posedge CLK) begin
        if (LD) begin
            memory[DR] <= DataIn;
        end
    end

    always @(*) begin
        SR1out <= memory[SR1];
        SR2out <= memory[SR2];
    end
endmodule
