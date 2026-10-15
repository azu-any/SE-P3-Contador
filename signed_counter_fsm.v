module signed_counter_fsm (
    input wire clk,
    input wire reset,
    input wire tick,
    input wire pause_pulse,
    input wire inc_pulse,
    input wire dec_pulse,
    output reg signed [8:0] count,
    output reg [1:0] state
);
    // Uso del 100% de las combinaciones de un registro de 2 bits
    localparam [1:0] S_PAUSE_UP   = 2'd0;
    localparam [1:0] S_UP         = 2'd1;
    localparam [1:0] S_DOWN       = 2'd2;
    localparam [1:0] S_PAUSE_DOWN = 2'd3;

    localparam signed [8:0] MAX_VALUE = 9'sd255;
    localparam signed [8:0] MIN_VALUE = 9'b1_0000_0000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= MIN_VALUE;
            state <= S_PAUSE_UP; // Inicia pausado, apuntando hacia arriba
        end else if (pause_pulse) begin
            // Transiciones directas entre estado de conteo y su respectiva pausa
            case (state)
                S_UP:         state <= S_PAUSE_UP;
                S_DOWN:       state <= S_PAUSE_DOWN;
                S_PAUSE_UP:   state <= S_UP;
                S_PAUSE_DOWN: state <= S_DOWN;
            endcase
        end else if (inc_pulse) begin
            state <= S_UP;
        end else if (dec_pulse) begin
            state <= S_DOWN;
        end else if (tick) begin
            // Solo cuenta si está explícitamente en S_UP o S_DOWN
            if (state == S_UP) begin
                if (count == MAX_VALUE)
                    count <= MIN_VALUE;
                else
                    count <= count + 9'sd1;
            end else if (state == S_DOWN) begin
                if (count == MIN_VALUE)
                    count <= MAX_VALUE;
                else
                    count <= count - 9'sd1;
            end
        end
    end
endmodule
