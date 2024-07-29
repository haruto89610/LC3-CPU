module FSM (
    input CLK, RESET, READY, 
    input BEN,
    input wire [15:0] IR,

    input wire N, Z, P,

    output reg LD_MAR, LD_MDR, LD_IR, LD_PC, LD_REG, LD_BEN, LD_CC,
    output reg GateMARMUX, GateMDR, GateALU, GatePC,

    output reg MARMUXsel, ADDR1MUXsel,
    output reg [1:0] ADDR2MUXsel,
    output reg [1:0] PCMUXsel, 
    output reg [1:0] SR1MUXsel, 
    output reg CS, WE, 
    output reg [1:0] ALUK, 
    output reg [1:0] DRMUXsel
);
	reg internal_ben;

    typedef enum logic [5:0] {
        // FETCH
        FETCH1 = 6'd18,
        FETCH2 = 6'd33,
        FETCH3 = 6'd35,
        
        // DECODE
        DECODE = 6'd32,

        ADD     = 6'd8,
        AND     = 6'd5,
        NOT     = 6'd9,
        TRAP1   = 6'd15,
        TRAP2   = 6'd28,
        TRAP3   = 6'd30,
        LEA     = 6'd14,
        LD      = 6'd2,
        LDR     = 6'd6,
        LDI1    = 6'd10,
        LDI2    = 6'd24,
        LDI3    = 6'd26,
        STI1    = 6'd11,
        STI2    = 6'd29,
        STI3    = 6'd31,
        STR     = 6'd7,
        ST      = 6'd3,
        JSR     = 6'd4,
        JSR1    = 6'd21,
        JSR0    = 6'd20,
        JMP     = 6'd12,
        BR1     = 6'd0,
        BR2     = 6'd22,

        MEM11   = 6'd25,
        MEM12   = 6'd27,
        MEM21   = 6'd23,
        MEM22   = 6'd16
    } state_t;

    state_t current_state, next_state;

    always @(posedge CLK or posedge RESET) begin
        if (RESET)
            current_state <= FETCH1;
        else
            current_state <= next_state;
    end


    // Next state logic
    always @(CLK) begin

    LD_MAR = 1'b0;
    LD_MDR = 1'b0;
    LD_IR = 1'b0;
    LD_PC = 1'b0;
    LD_REG = 1'b0;
    LD_BEN = 1'b0;
    LD_CC = 1'b0;

    GateMARMUX = 1'b0;
    GateMDR = 1'b0;
    GateALU = 1'b0;
    GatePC = 1'b0;

    MARMUXsel = 1'b0;
    ADDR1MUXsel = 1'b0;
    ADDR2MUXsel = 2'b00;
    PCMUXsel = 2'b00;
    SR1MUXsel = 2'b00;
    CS = 1'b0;
    WE = 1'b0;
    ALUK = 2'b00;
    DRMUXsel = 2'b00;

        case (current_state)
            FETCH1: next_state = FETCH2;
            FETCH2: next_state = FETCH3;
            FETCH3: next_state = DECODE;
            DECODE: begin
                case (IR[15:12])
                    4'b0001: next_state = ADD;
                    4'b0101: next_state = AND;
                    4'b0000: next_state = BR1;
                    4'b1100: next_state = JMP;
                    4'b0100: next_state = JSR;
                    4'b1111: next_state = TRAP1;
                    4'b0010: next_state = LD;
                    4'b1010: next_state = LDI1;
                    4'b0110: next_state = LDR;
                    4'b1110: next_state = LEA;
                    4'b1001: next_state = NOT;
                    4'b0011: next_state = ST;
                    4'b1011: next_state = STI1;
                    4'b0111: next_state = STR;
                    default: next_state = FETCH1;
                endcase
            end

            BR1: begin
                case (internal_ben)
                    1'b0: next_state = FETCH1;
                    1'b1: next_state = BR2;
                    default: next_state = FETCH1;
                endcase
            end

            BR2: next_state = FETCH1;

            ADD: next_state = FETCH1;
            AND: next_state = FETCH1;
            NOT: next_state = FETCH1;
            LEA: next_state = FETCH1;
            JMP: next_state = FETCH1;

            TRAP1: next_state = TRAP2;

            TRAP2: begin
                if (READY)
                    next_state = TRAP3;
                else 
                    next_state = TRAP2;
            end
            TRAP3: next_state = FETCH1;

            LD: next_state = MEM11;
            LDR: next_state = MEM11;
            LDI1: next_state = LDI2;

            LDI2: begin
                if (READY)
                    next_state = LDI3;
                else
                    next_state = LDI2;
            end
            
            LDI3: next_state = MEM11;

            MEM11: begin
                if (READY)
                    next_state = MEM12;
                else
                    next_state = MEM11;
            end

            MEM12: next_state = FETCH1;

            STI1: next_state = STI2;
            STI2: begin
                if (READY)
                    next_state = STI3;
                else
                    next_state = STI2;
            end

            STI3: next_state = MEM21;
            STR: next_state = MEM21;
            ST: next_state = MEM21;

            MEM21: next_state = MEM22;
            MEM22: begin
                if (READY)
                    next_state = FETCH1;
                else
                    next_state = MEM22;
            end

            JSR: begin
                if (IR[11])
                    next_state = JSR1;
                else
                    next_state = JSR0;
            end
            JSR0: next_state = FETCH1;
            JSR1: next_state = FETCH1;

            default: next_state = FETCH1;
        endcase
    end

    // Output logic
    always @(CLK) begin
        // CONTROL SIGNALS
        LD_MAR = 1'b0;
        LD_MDR = 1'b0;
        LD_IR = 1'b0;
        LD_PC = 1'b0;
        LD_REG = 1'b0;
        LD_BEN = 1'b0;
        LD_CC = 1'b0;

        GateMARMUX = 1'b0;
        GateMDR = 1'b0;
        GateALU = 1'b0;
        GatePC = 1'b0;

        MARMUXsel = 1'b0;
        ADDR1MUXsel = 1'b0;
        ADDR2MUXsel = 2'b00;
        PCMUXsel = 2'b00;
        SR1MUXsel = 2'b00;
        CS = 1'b0;
        WE = 1'b0;
        ALUK = 2'b00;
        DRMUXsel = 2'b00;

        case (current_state)
            FETCH1: begin
		// MAR <- PC
		// PC <- PC + 1
                LD_MAR <= 1'b1;
                GatePC <= 1'b1;
                LD_PC <= 1'b1;
                PCMUXsel <= 2'b00;
            end
            FETCH2: begin
		// MDR <- M
                CS <= 1'b1;
                LD_MDR <= 1'b1;
            end
            FETCH3: begin
		// IR <- MDR
                LD_IR <= 1'b1;
                GateMDR <= 1'b1;
            end
            DECODE: begin
                assign internal_ben = (IR[11] & N) | (IR[10] & Z) | (IR[9] & P);
            end
            ADD: begin
                // DR <- SR1 + OP2
                // Set CC
                LD_REG <= 1'b1;
                DRMUXsel <= 2'b00;
                SR1MUXsel <= 2'b01;
                ALUK <= 2'b00;
                GateALU <= 1'b1;
                LD_CC <= 1'b1;
            end
            AND: begin
                // DR <- SR1 & OP2
                // Set CC
                LD_REG <= 1'b1;
                DRMUXsel <= 2'b00;
                SR1MUXsel <= 2'b01;
                ALUK = 2'b01;
                GateALU <= 1'b1;
                LD_CC <= 1'b1;
            end
            NOT: begin
                // DR <- NOT(SR)
                // Set CC
                LD_REG <= 1'b1;
                DRMUXsel <= 2'b00;
                SR1MUXsel <= 2'b01;
                ALUK = 2'b10;
                GateALU <= 1'b1;
                LD_CC <= 1'b1;
            end
            TRAP1: begin
                // MAR <- ZEXT[IR[7:0]]
                MARMUXsel <= 1'b0;
                GateMARMUX <= 1'b1;
                LD_MAR <= 1'b1;
            end
            TRAP2: begin
                // MDR <- M[MAR]
                // R7 <- PC
                CS <= 1'b1;
                LD_MDR <= 1'b1;
                DRMUXsel <= 2'b01;
                LD_REG <= 1'b1;
                GatePC <= 1'b1;
            end
            TRAP3: begin
                // PC <- MDR
                GateMDR <= 1'b1;
                PCMUXsel <= 2'b01;
                LD_PC <= 1'b1;
            end
            LEA: begin
                // DR <- PC + off9
                // Set CC
                DRMUXsel <= 2'b00;
                LD_REG <= 1'b1;
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
                LD_CC <= 1'b1;
            end
            LD: begin
                // MAR <- PC + off9
                LD_MAR <= 1'b1;
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
            end
            LDR: begin
                // MAR <- BaseR + off6
                SR1MUXsel <= 2'b01;
                ADDR1MUXsel <= 1'b1;
                ADDR2MUXsel <= 2'b01;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
                LD_MAR <= 1'b1;
            end
            LDI1: begin
                // MAR <- PC + off9
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
                LD_MAR <= 1'b1;
            end
            LDI2: begin
                // MDR <- M[MAR]
                CS <= 1'b1;
                LD_MDR <= 1'b1;
            end
            LDI3: begin
                // MAR <- MDR
                GateMDR <= 1'b1;
                LD_MAR <= 1'b1;
            end
            MEM11: begin
                // MDR <- M[MAR]
                CS <= 1'b1;
                LD_MDR <= 1'b1;
            end
            MEM12: begin
                // DR <- MDR
                // Set CC
                GateMDR <= 1'b1;
                LD_REG <= 1'b1;
                DRMUXsel <= 2'b00;
                LD_CC <= 1'b1;
            end
            STI1: begin
                // MAR <- PC + off9
                LD_MAR <= 1'b1;
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
            end
            STI2: begin
                // MDR <- M[MAR]
                CS <= 1'b1;
                LD_MDR <= 1'b1;
            end
            STI3: begin
                // MAR <- MDR
                GateMDR <= 1'b1;
                LD_MDR <= 1'b1;
            end
            STR: begin
                // MAR <- BaseR + off6
                SR1MUXsel <= 2'b01;
                ADDR1MUXsel <= 1'b1;
                ADDR2MUXsel <= 2'b01;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
                LD_MAR <= 1'b1;
            end
            ST: begin
                // MAR <- PC + off9
                LD_MAR <= 1'b1;
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                MARMUXsel <= 1'b1;
                GateMARMUX <= 1'b1;
            end
            MEM21: begin
                // MDR <- SR
                SR1MUXsel <= 2'b00;
                ALUK <= 2'b11;
                GateALU <= 1'b1;
                CS <= 1'b0;
                LD_MDR <= 1'b1;
            end
            MEM22: begin
                // M[MAR] <- MDR
                CS <= 1'b1;
                WE <= 1'b1;
            end
            JSR: begin
                // R7 <- PC
                GatePC <= 1'b1;
                DRMUXsel <= 2'b01;
                LD_REG <= 1'b1;
            end
            JSR0: begin
                // PC <- BaseR
                SR1MUXsel <= 2'b01;
                ADDR1MUXsel <= 1'b1;
                ADDR2MUXsel <= 2'b00;
                PCMUXsel <= 2'b10;
                LD_PC <= 1'b1;
            end
            JSR1: begin
                // PC <- PC + off11
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b11;
                PCMUXsel <= 2'b10;
                LD_PC <= 1'b1;
            end
            JMP: begin
                // PC <- BaseR
                SR1MUXsel <= 2'b01;
                ADDR1MUXsel <= 1'b1;
                ADDR2MUXsel <= 2'b00;
                PCMUXsel <= 2'b10;
                LD_PC <= 1'b1;
            end
            BR1: begin
                // [BEN]
                LD_BEN <= 1'b1;
            end
            BR2: begin
                // PC <- PC + off9
                LD_PC <= 1'b1;
                ADDR1MUXsel <= 1'b0;
                ADDR2MUXsel <= 2'b10;
                PCMUXsel <= 2'b10;
            end
            default: begin
                next_state <= FETCH1;
            end
        endcase
    end

endmodule
