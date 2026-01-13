module traffic_2way (
    input  wire clk,
    input  wire reset,
    output reg A_red,
    output reg A_yellow,
    output reg A_green,
    output reg B_red,
    output reg B_yellow,
    output reg B_green
);

    // -----------------------------
    // State encoding
    // -----------------------------
    parameter A_GREEN  = 2'b00;
    parameter A_YELLOW = 2'b01;
    parameter B_GREEN  = 2'b10;
    parameter B_YELLOW = 2'b11;

    reg [1:0] state, next_state;

    // -----------------------------
    // Timing parameters (in clock cycles)
    // -----------------------------
    parameter GREEN_TIME  = 10;
    parameter YELLOW_TIME = 3;

    reg [3:0] timer;

    // -----------------------------
    // State register
    // -----------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= A_GREEN;
            timer <= 0;
        end else begin
            state <= next_state;
            timer <= timer + 1;
        end
    end

    // -----------------------------
    // Next state logic
    // -----------------------------
    always @(*) begin
        next_state = state;

        case (state)
            A_GREEN:
                if (timer >= GREEN_TIME)
                    next_state = A_YELLOW;

            A_YELLOW:
                if (timer >= YELLOW_TIME)
                    next_state = B_GREEN;

            B_GREEN:
                if (timer >= GREEN_TIME)
                    next_state = B_YELLOW;

            B_YELLOW:
                if (timer >= YELLOW_TIME)
                    next_state = A_GREEN;

            default:
                next_state = A_GREEN;
        endcase
    end

    // -----------------------------
    // Timer reset on state change
    // -----------------------------
    always @(posedge clk) begin
        if (state != next_state)
            timer <= 0;
    end

    // -----------------------------
    // Output logic
    // -----------------------------
    always @(*) begin
        // Default OFF
        A_red    = 0;
        A_yellow = 0;
        A_green  = 0;
        B_red    = 0;
        B_yellow = 0;
        B_green  = 0;

        case (state)
            A_GREEN: begin
                A_green = 1;
                B_red   = 1;
            end

            A_YELLOW: begin
                A_yellow = 1;
                B_red    = 1;
            end

            B_GREEN: begin
                B_green = 1;
                A_red   = 1;
            end

            B_YELLOW: begin
                B_yellow = 1;
                A_red    = 1;
            end
        endcase
    end

endmodule
