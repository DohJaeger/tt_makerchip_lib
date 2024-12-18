// UART Receiver
module uart_rx 
    #(parameter int FREQUENCY = 10_000_000, parameter int BAUD_RATE = 9600)
    (
        input logic clk,
        input logic rx_serial,
        input logic reset,
        output logic rx_done,
        output logic [7:0] rx_byte
    );

    localparam int CLKS_PER_BIT = FREQUENCY / (16 * BAUD_RATE);

    typedef enum logic [2:0] {
        s_IDLE          = 3'b000,
        s_RX_START_BIT  = 3'b001,
        s_RX_DATA_BITS  = 3'b010,
        s_RX_STOP_BIT   = 3'b011,
        s_CLEANUP       = 3'b100
    } state_t;

    state_t r_SM_Main = s_IDLE;

    logic r_Rx_Data_R = 1'b1;
    logic r_Rx_Data = 1'b1;

    int unsigned r_Clock_Count = 0;
    int unsigned r_Bit_Index = 0; // 8 bits total
    logic [7:0] r_Rx_Byte = 8'h00;
    logic r_Rx_DV = 1'b0;

    // Purpose: Double-register the incoming data to avoid metastability
    always_ff @(posedge clk) begin
        r_Rx_Data_R <= rx_serial;
        r_Rx_Data   <= r_Rx_Data_R;
    end

    // RX state machine
    always_ff @(posedge clk) begin
        if (reset) begin
            r_SM_Main      <= s_IDLE;
            r_Rx_DV        <= 1'b0;
            r_Clock_Count  <= 0;
            r_Bit_Index    <= 0;
            r_Rx_Byte      <= 8'h00;
        end else begin
            case (r_SM_Main)
                s_IDLE: begin
                    r_Rx_DV       <= 1'b0;
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0;

                    if (r_Rx_Data == 1'b0) // Start bit detected
                        r_SM_Main <= s_RX_START_BIT;
                end

                s_RX_START_BIT: begin
                    if (r_Clock_Count == (CLKS_PER_BIT - 1) / 2) begin
                        if (r_Rx_Data == 1'b0) begin
                            r_Clock_Count <= 0;  // Reset counter, found the middle
                            r_SM_Main     <= s_RX_DATA_BITS;
                        end else begin
                            r_SM_Main <= s_IDLE;
                        end
                    end else begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end
                end

                s_RX_DATA_BITS: begin
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Clock_Count <= 0;
                        r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;

                        if (r_Bit_Index < 7) begin
                            r_Bit_Index <= r_Bit_Index + 1;
                        end else begin
                            r_Bit_Index <= 0;
                            r_SM_Main   <= s_RX_STOP_BIT;
                        end
                    end
                end

                s_RX_STOP_BIT: begin
                    if (r_Clock_Count < CLKS_PER_BIT - 1) begin
                        r_Clock_Count <= r_Clock_Count + 1;
                    end else begin
                        r_Rx_DV       <= 1'b1;
                        r_Clock_Count <= 0;
                        r_SM_Main     <= s_CLEANUP;
                    end
                end

                s_CLEANUP: begin
                    r_SM_Main <= s_IDLE;
                    r_Rx_DV   <= 1'b0;
                end

                default: r_SM_Main <= s_IDLE;
            endcase
        end
    end

    assign rx_done = r_Rx_DV;
    assign rx_byte = r_Rx_Byte;

endmodule