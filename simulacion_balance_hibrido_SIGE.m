%% ========================================================================
% PROYECTO: Sistema Inteligente de Gestión Energética (SIGE)
% RETO 2 - Modelado del Balance Híbrido
% Descripción: Script que simula el comportamiento energético de una
% micro-red durante un ciclo de 24 horas, modelando la generación solar,
% la generación eólica, la generación híbrida total y la demanda de la
% comunidad, para su posterior análisis gráfico.
% ========================================================================

clear; clc; close all;

%% 1. DEFINICIÓN DEL VECTOR TIEMPO
% Vector fila de 24 posiciones, cada una representa una hora del día (1 a 24)
horas = 1:24;

%% 2. GENERACIÓN SOLAR
% Parámetro de diseño: potencia máxima de los paneles solares
P_max_solar = 25;      % kW

% Inicializamos el vector de generación solar en ceros (24 horas)
generacion_solar = zeros(1, 24);

% Definimos el rango de horas de luz solar (horas 6 a 18)
horas_dia = 6:18;

% Ecuación senoidal: modela el ascenso y descenso de la irradiancia solar,
% con valor 0 al amanecer (hora 6) y al atardecer (hora 18), y pico
% máximo (P_max_solar) exactamente al mediodía (hora 12)
generacion_solar(horas_dia) = P_max_solar * sin(pi * (horas_dia - 6) / 12);

% Se garantiza explícitamente que las horas nocturnas (1 a 5 y 19 a 24)
% permanezcan en 0 kW (ya lo están por la inicialización; se refuerza aquí)
generacion_solar([1:5, 19:24]) = 0;

%% 3. GENERACIÓN EÓLICA (AEROGENERADORES)
P_max_eolica = 15;     % kW - potencia nominal máxima de diseño

% Se fija la semilla del generador aleatorio para que la simulación
% sea reproducible en cada ejecución (mismo resultado siempre)
rng(7);

% Se modela una componente base de variación suave (tendencia del viento)
% usando una función senoidal con periodo distinto al de la solar
tendencia_viento = 7 + 4 * sin(2*pi*horas/9 + 1.5);

% Se añade una componente aleatoria (ráfagas de viento) para simular
% las fluctuaciones irregulares características de la velocidad del viento
rafagas = 3 * randn(1, 24);

% Generación eólica total: suma de tendencia + ráfagas
generacion_eolica = tendencia_viento + rafagas;

% Se restringe el vector para que ningún valor sea negativo ni supere
% la potencia máxima nominal del aerogenerador (0 <= P <= 15 kW)
generacion_eolica = max(generacion_eolica, 0);
generacion_eolica = min(generacion_eolica, P_max_eolica);

%% 4. GENERACIÓN HÍBRIDA TOTAL
% Suma elemento a elemento (vectorizada) de la generación solar y eólica
generacion_total = generacion_solar + generacion_eolica;

%% 5. DEMANDA DE LA COMUNIDAD
P_max_demanda = 15;    % kW - potencia máxima de diseño de la demanda

demanda = zeros(1, 24);

% Consumo mínimo nocturno (horas 1 a 5 y 22 a 24): régimen base entre 2-4 kW
horas_min = [1:5, 22:24];
demanda(horas_min) = 2 + (4-2) * rand(1, length(horas_min));

% Consumo diurno (horas 6 a 17): incremento moderado entre 6-10 kW
% (apertura de la escuela y bombeo agrícola)
horas_diurnas = 6:17;
demanda(horas_diurnas) = 6 + (10-6) * rand(1, length(horas_diurnas));

% Pico máximo de demanda (horas 18 a 21): alumbrado público + retorno
% doméstico, alcanzando la potencia máxima de diseño (15 kW)
horas_pico = 18:21;
% Perfil ascendente-descendente que toca el máximo de diseño (15 kW)
% en el centro del intervalo pico
perfil_pico = [12, 15, 15, 13];   % kW
demanda(horas_pico) = perfil_pico;

%% 6. VISUALIZACIÓN GRÁFICA
figure('Name', 'Balance Energético Híbrido - SIGE', 'NumberTitle', 'off');

plot(horas, generacion_total, '-o', 'Color', [0.85 0.33 0.10], 'LineWidth', 2);
hold on;
plot(horas, demanda, '-s', 'Color', [0 0.45 0.74], 'LineWidth', 2);
hold off;

title('Balance Energético de la Micro-red: Generación Híbrida vs Demanda');
xlabel('Tiempo en horas');
ylabel('Potencia en Kilovatios (kW)');
legend('Generación Total (Solar + Eólica)', 'Demanda de la Comunidad', 'Location', 'best');
grid on;
xlim([1 24]);
xticks(1:24);

%% 7. RESUMEN EN CONSOLA (útil para redactar el Análisis Funcional del informe)
fprintf('--- Resumen de la simulación SIGE ---\n');
fprintf('Generación total máxima: %.2f kW (hora %d)\n', max(generacion_total), find(generacion_total==max(generacion_total),1));
fprintf('Demanda máxima: %.2f kW (hora %d)\n', max(demanda), find(demanda==max(demanda),1));

balance = generacion_total - demanda;
horas_superavit = horas(balance >= 0);
horas_deficit = horas(balance < 0);
fprintf('Horas con superávit de energía: %s\n', mat2str(horas_superavit));
fprintf('Horas con déficit de energía (uso de baterías): %s\n', mat2str(horas_deficit));