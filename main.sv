module main (
// PERIPHERALS
    inout [15:0] BUS,
    input CLK, RST
);

    wire [1:0] ALUK;
// MUX SIGNALS
    wire ADDR1sel;
    wire [1:0] ADDR2sel;
    wire [1:0] MARMUXsel;
    wire [1:0] PCMUXsel;
    wire [1:0] DRMUXsel;
    wire [1:0] SR1MUXsel;
// GATE SIGNALS
    wire GateMDR, GateMARMUX, GatePC, GateALU;
// LD SIGNALS
    wire LD_MAR, LD_MDR, LD_IR, LD_PC, LD_REG, LD_CC, LD_BEN;
// REG SIGNALS
    wire MIO_EN, WE;

    wire [15:0] MARout;
    wire [15:0] RAMout;
    wire [15:0] MEMMUXOUT;
    wire [15:0] MDRout;

    wire [15:0] PCMUXout;
    wire [15:0] PCout;

    wire [15:0] IRout;

    wire [15:0] ADDR1MUXout;

    wire [15:0] ADDR2MUXout;
    wire [15:0] ADDR2ADDR1sum;

    wire [15:0] MARMUXout;

    wire [2:0] DRMUXout;
    wire [2:0] SR1MUXout;

    wire [15:0] SR1out;
    wire [15:0] SR2out;

    wire [15:0] SR2MUXout;

    wire BEN;

    reg Nout, Zout, Pout;

    reg [15:0] ALUout;

// REGISTER FILE
    mux4x1 DRMUX(
        .in0(IRout[11:9]),
        .in1(3'b111),
        .in2(3'b110),
        .in3(3'bZ),
        .select1(DRMUXsel[1]),
        .select0(DRMUXsel[0]),
        .out(DRMUXout)
    );

    mux4x1 SR1MUX(
        .in0(IRout[11:9]),
        .in1(IRout[8:6]),
        .in2(3'b110),
        .in3(3'bZ),
        .select1(SR1MUXsel[1]),
        .select0(SR1MUXsel[0]),
        .out(SR1MUXout)
    );

    REG_FILE REG_FILE(
        .DataIn(BUS),
        .DR(DRMUXout),
        .SR1(SR1MUXout),
        .SR2(IRout[2:0]),
        .LD(LD_REG),
        .CLK(CLK),
        .SR1out(SR1out),
        .SR2out(SR2out)
    );

// RAM SECTION
    registerFF MAR(
        .in(BUS),
        .LD(LD_MAR),
        .CLK(CLK),
        .out(MARout)
    );

    registerFF MDR(
        .in(MEMMUXOUT),
        .LD(LD_MDR),
        .CLK(CLK),
        .out(MDRout)
    );

    mux2x1 MEM_MUX(
        .in0(BUS),
        .in1(RAMout),
        .select(MIO_EN),
        .out(MEMMUXOUT)
    );

    tristate TRI_MDR(
        .in(MDRout),
        .OE(GateMDR),
        .out(BUS)
    );

    RAM RAM(
        .DataIn(MDRout),
        .ADDR(MARout),
        .WE(WE),
        .CS(MIO_EN),
        .CLK(CLK),
        .out(RAMout),
        .ready(ready)   //TODO ready signal
    );

// IR OUTPUTS
    registerFF IR(
        .in(BUS),
        .LD(LD_IR),
        .CLK(CLK),
        .out(IRout)
    );

// ADDRESS1MUX
    mux2x1 ADDRESS1MUX(
        .in0(PCout),
        .in1(SR1out),     //TODO add SR1out
        .select(ADDR1sel),
        .out(ADDR1MUXout)
    );

// ADDRESS2MUX
    assign ADDR2ADDR1sum = ADDR2MUXout + ADDR1MUXout;
    
    mux4x1 ADDRESS2MUX(
        .in0(16'b0),
        .in1({{10{IRout[5]}}, IRout[5:0]}),
        .in2({{7{IRout[8]}}, IRout[8:0]}),
        .in3({{5{IRout[10]}}, IRout[10:0]}),
        .select1(ADDR2sel[1]),
        .select0(ADDR2sel[0]),
        .out(ADDR2MUXout)
    );

// MARMUX
    mux2x1 MARMUX(
        .in0({8'b0, IRout[7:0]}),
        .in1(ADDR2ADDR1sum),
        .select(MARMUXsel),
        .out(MARMUXout)
    );

    tristate TRI_MARMUX(
        .in(MARMUXout),
        .OE(GateMARMUX),
        .out(BUS)
    );

// PROGRAM COUNTER
    mux4x1 PCMUX(
        .in0(PCout + 1'b1),
        .in1(BUS),
        .in2(ADDR2ADDR1sum),
        .in3(16'bZ),
        .select1(PCMUXsel[1]),
        .select0(PCMUXsel[0]),
        .out(PCMUXout)
    );

    registerFF PC(
        .in(PCMUXout),
        .LD(LD_PC),
        .CLK(CLK),
        .out(PCout)
    );

    tristate TRI_PC(
        .in(PCout),
        .OE(GatePC),
        .out(BUS)
    );

// ALU
    mux2x1 SR2MUX(
        .in0(SR2out),
        .in1({{11{IRout[4]}}, IRout[4:0]}),
        .select(IRout[5]),
        .out(SR2MUXout)
    );

    always @(*) begin
        case(ALUK)
            2'b00: ALUout = SR2MUXout + SR1out;
            2'b01: ALUout = SR2MUXout & SR1out;
            2'b10: ALUout = ~SR1out;
            2'b11: ALUout = SR1out;
            default: ALUout = 16'bZ;
        endcase
    end

    tristate TRI_ALU(
        .in(ALUout),
        .OE(GateALU),
        .out(BUS)
    );

// FSM
    LOGIC LOGIC(
        .BUS(BUS),
        .LD(LD_CC),
        .CLK(CLK),
        .Nout(Nout),
        .Zout(Zout),
        .Pout(Pout)
    );

    BR_COMP BR_COMP(
        .IR(IRout[11:9]),
        .CLK(CLK),
        .LD(LD_BEN),
        .N(Nout),
        .Z(Zout),
        .P(Pout),
        .BEN(BEN)
    );

    FSM FSM(
        .CLK(CLK),
        .RESET(RST),
        .READY(ready),
        .BEN(BEN),
        .N(Nout),
        .P(Pout),
        .Z(Zout),
        .IR(IRout),
        .LD_MAR(LD_MAR),
        .LD_MDR(LD_MDR),
        .LD_IR(LD_IR),
        .LD_PC(LD_PC),
        .LD_REG(LD_REG),
        .LD_BEN(LD_BEN),
        .LD_CC(LD_CC),
        .GateMARMUX(GateMARMUX),
        .GateMDR(GateMDR),
        .GateALU(GateALU),
        .GatePC(GatePC),
        .MARMUXsel(MARMUXsel),
        .ADDR1MUXsel(ADDR1sel),
        .ADDR2MUXsel(ADDR2sel),
        .PCMUXsel(PCMUXsel),
        .SR1MUXsel(SR1MUXsel),
        .CS(MIO_EN),
        .WE(WE),
        .ALUK(ALUK),
        .DRMUXsel(DRMUXsel)
    );

endmodule