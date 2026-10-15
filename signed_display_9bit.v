module signed_display_9bit (
    input wire signed [8:0] value,
    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3
);
    localparam [6:0] SEG_BLANK = 7'b1111111;
    localparam [6:0] SEG_MINUS = 7'b0111111;

    reg [8:0] magnitude;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] units;
    
    // Registros internos para el algoritmo Double Dabble
    reg [11:0] bcd;
    reg [8:0] shift_reg;
    integer i;

    function [6:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_7seg = 7'b1000000;
                4'd1: digit_to_7seg = 7'b1111001;
                4'd2: digit_to_7seg = 7'b0100100;
                4'd3: digit_to_7seg = 7'b0110000;
                4'd4: digit_to_7seg = 7'b0011001;
                4'd5: digit_to_7seg = 7'b0010010;
                4'd6: digit_to_7seg = 7'b0000010;
                4'd7: digit_to_7seg = 7'b1111000;
                4'd8: digit_to_7seg = 7'b0000000;
                4'd9: digit_to_7seg = 7'b0010000;
                default: digit_to_7seg = SEG_BLANK;
            endcase
        end
    endfunction

    always @(*) begin
        // 1. Obtener la magnitud absoluta a partir del complemento a dos
        if (value[8])
            magnitude = (~value) + 9'd1;
        else
            magnitude = value;

        // 2. Inicializar los registros para el Double Dabble
        bcd = 12'd0;
        shift_reg = magnitude;
        
        // 3. Iterar sobre los 9 bits de la magnitud (Shift-and-Add-3)
        for (i = 0; i < 9; i = i + 1) begin
            // Si el valor BCD de cualquier columna es >= 5, sumar 3
            if (bcd[3:0] >= 4'd5)
                bcd[3:0] = bcd[3:0] + 4'd3;
            if (bcd[7:4] >= 4'd5)
                bcd[7:4] = bcd[7:4] + 4'd3;
            if (bcd[11:8] >= 4'd5)
                bcd[11:8] = bcd[11:8] + 4'd3;
            
            // Desplazar BCD a la izquierda, ingresando el bit MSB de shift_reg
            bcd = {bcd[10:0], shift_reg[8]};
            // Desplazar el registro de magnitud
            shift_reg = shift_reg << 1;
        end

        // 4. Extraer los dígitos BCD resultantes
        units    = bcd[3:0];
        tens     = bcd[7:4];
        hundreds = bcd[11:8];

        // 5. Asignar a los displays de 7 segmentos con supresión de ceros a la izquierda
        HEX0 = digit_to_7seg(units);
        HEX1 = (magnitude >= 9'd10)  ? digit_to_7seg(tens) : SEG_BLANK;
        HEX2 = (magnitude >= 9'd100) ? digit_to_7seg(hundreds) : SEG_BLANK;
        HEX3 = value[8] ? SEG_MINUS : SEG_BLANK;
    end
endmodule
