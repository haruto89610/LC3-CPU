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

	 integer i;
    initial begin
		  //readmemh("memory_init.hex", memory);
//        for (i = 0; i < 65536; i = i + 1) begin
//            memory[i] = 16'b0; // Set each word to 0
//        end
		  ready = 1'b0;
    end

    always @(posedge CLK) begin
        if (CS) begin
            ready <= 1'b0;
            if (WE) begin
                memory[ADDR] <= DataIn;
                out <= 16'bZ;
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
