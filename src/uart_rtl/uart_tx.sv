module uart_tx 
    #(parameter int FREQUENCY = 10000000, parameter int BAUD_RATE = 9600)
    (
        input logic clk,
        input logic reset,
        input logic tx_dv,
        input logic [7:0] tx_byte, 
        output logic tx_active,
        output logic tx_serial,
        output logic tx_done
    );

    typedef enum logic [2:0] {
        s_IDLE          = 3'b000,
        s_TX_START_BIT  = 3'b001,
        s_TX_DATA_BITS  = 3'b010,
        s_TX_STOP_BIT   = 3'b011,
        s_CLEANUP       = 3'b100
    } state_t;

    localparam int CLKS_PER_BIT = FREQUENCY / (16 * BAUD_RATE);

    state_t r_SM_Main = s_IDLE;
    logic [7:0] r_Clock_Count = 0;
    logic [2:0] r_Bit_Index = 0;
    logic [7:0] r_Tx_Data = 0;
    logic r_Tx_Done = 0;
    logic r_Tx_Active = 0;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            r_SM_Main <= s_IDLE;
            r_Clock_Count <= 0;
            r_Bit_Index <= 0;
            r_Tx_Data <= 0;
            r_Tx_Done <= 0;
            r_Tx_Active <= 0;
            tx_serial <= 1;
        end else begin
            case (r_SM_Main)
                s_IDLE: begin
                    tx_serial <= 1; // Line idle state
                    r_Tx_Done <= 0;
                    r_Clock_Count <= 0;
                    r_Bit_Index <= 0;
                    
                    if (tx_dv) begin
                        r_Tx_Active <= 1;
                        r_Tx_Data <= tx_byte;
                        r_SM_Main <= s_TX_START_BIT;
                    end else begin
                        r_SM_Main <= s_IDLE;
                    end
                end

                s_TX_START_BIT: begin
                    tx_serial <= 0; // Start bit
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        r_SM_Main <= s_TX_DATA_BITS;
                    end
                end

                s_TX_DATA_BITS: begin
                    tx_serial <= r_Tx_Data[r_Bit_Index];
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        if (r_Bit_Index < 7) begin
                            r_Bit_Index <= r_Bit_Index + 1;
                        end else begin
                            r_Bit_Index <= 0;
                            r_SM_Main <= s_TX_STOP_BIT;
                        end
                    end
                end

                s_TX_STOP_BIT: begin
                    tx_serial <= 1; // Stop bit
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Tx_Done <= 1;
                        r_Clock_Count <= 0;
                        r_Tx_Active <= 0;
                        r_SM_Main <= s_CLEANUP;
                    end
                end

                s_CLEANUP: begin
                    r_Tx_Done <= 1;
                    r_SM_Main <= s_IDLE;
                end

                default: r_SM_Main <= s_IDLE;
            endcase
        end
    end

    assign tx_active = r_Tx_Active;
    assign tx_done = r_Tx_Done;

endmodule