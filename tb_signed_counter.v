`timescale 1ns / 1ps

module tb_signed_counter_fsm();

    // Entradas al DUT
    reg clk;
    reg reset;
    reg tick;
    reg pause_pulse;
    reg inc_pulse;
    reg dec_pulse;
   
    // Salidas del DUT
    wire signed [8:0] count;
    wire [1:0] state;

    // Instancia del módulo FSM
    signed_counter_fsm uut (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .pause_pulse(pause_pulse),
        .inc_pulse(inc_pulse),
        .dec_pulse(dec_pulse),
        .count(count),
        .state(state)
    );

    // Generación de reloj de 50 MHz (periodo de 20 ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Tarea para generar un pulso de 'tick' de un solo ciclo
    task send_tick;
        begin
            @(posedge clk);
            tick = 1;
            @(posedge clk);
            tick = 0;
        end
    endtask

    // Secuencia de estímulos basada en la Tabla de Pruebas (Sección 12)
    initial begin
        // Inicialización de señales
        reset = 0;
        tick = 0;
        pause_pulse = 0;
        inc_pulse = 0;
        dec_pulse = 0;

        $display("--- Iniciando Tabla de Pruebas ---");

        // 1. Valor actual: 0 | Evento: RESET | Esperado: 0 (PAUSA)
        reset = 1; #20; reset = 0; #20;
        $display("1. RESET -> Count: %d, State: %d", count, state);

        // 2. Valor actual: 0 | Evento: INC y despues tick | Esperado: 1 (ASCENDENTE)
        @(posedge clk); inc_pulse = 1; @(posedge clk); inc_pulse = 0;
        send_tick();
        $display("2. INC y tick -> Count: %d, State: %d", count, state);

        // 3. Valor actual: 58 | Evento: tick | Esperado: 59 (ASCENDENTE)
        // Ya estamos en 1, avanzamos 57 ticks para llegar a 58
        repeat(57) send_tick();
        $display("3. Alcanzado valor 58, aplicando tick...");
        send_tick();
        $display("   Esperado: 59 -> Count: %d", count);

        // 4. Valor actual: 255 | Evento: tick | Esperado: -256 (ASCENDENTE)
        // Estamos en 59, faltan 196 ticks para llegar a 255
        repeat(196) send_tick();
        $display("4. Alcanzado valor 255, aplicando tick (Overflow)...");
        send_tick();
        $display("   Esperado: -256 -> Count: %d", count);

        // 5. Valor actual: 0 | Evento: DEC y despues tick | Esperado: -1 (DESCENDENTE)
        reset = 1; #20; reset = 0; // Regresamos a 0
        @(posedge clk); dec_pulse = 1; @(posedge clk); dec_pulse = 0;
        send_tick();
        $display("5. DEC y tick -> Count: %d, State: %d", count, state);

        // 6. Valor actual: -58 | Evento: tick | Esperado: -59 (DESCENDENTE)
        // Estamos en -1, restamos 57 ticks
        repeat(57) send_tick();
        $display("6. Alcanzado valor -58, aplicando tick...");
        send_tick();
        $display("   Esperado: -59 -> Count: %d", count);

        // 7. Valor actual: -256 | Evento: tick | Esperado: 255 (DESCENDENTE)
        // Estamos en -59, restamos 197 ticks para llegar a -256
        repeat(197) send_tick();
        $display("7. Alcanzado valor -256, aplicando tick (Underflow)...");
        send_tick();
        $display("   Esperado: 255 -> Count: %d", count);

        // 8. Valor actual: 45 | Evento: PAUSA y varios ticks | Esperado: 45 (PAUSA)
        reset = 1; #20; reset = 0;
        @(posedge clk); inc_pulse = 1; @(posedge clk); inc_pulse = 0;
        repeat(45) send_tick(); // Llegamos a 45
        $display("8. Alcanzado valor 45, aplicando PAUSA y 5 ticks extras...");
        @(posedge clk); pause_pulse = 1; @(posedge clk); pause_pulse = 0;
        repeat(5) send_tick();
        $display("   Esperado: 45 -> Count: %d, State: %d", count, state);

        // 9. Valor actual: -123 | Evento: RESET | Esperado: 0 (PAUSA)
        reset = 1; #20; reset = 0;
        @(posedge clk); dec_pulse = 1; @(posedge clk); dec_pulse = 0;
        repeat(123) send_tick(); // Llegamos a -123
        $display("9. Alcanzado valor -123, aplicando RESET...");
        reset = 1; #20; reset = 0;
        $display("   Esperado: 0 -> Count: %d, State: %d", count, state);

        // Fin de simulación
        #100 $finish;
    end

endmodule
