clc; 
clear; 
close all;

% Define Parameters
fs = 1000; % Sampling frequency
bit_duration = 0.01; % Bit duration (10ms per bit)
t = 0:1/fs:bit_duration-1/fs; % Time vector for each bit
data = 'Hi'; % Message to transmit
binary_data = reshape(dec2bin(data, 8)' - '0', 1, []); % Convert to binary

% Transmitter: OOK Modulation (LED ON = 1, LED OFF = 0)
tx_signal = repmat(binary_data, length(t), 1); % Repeat each bit over time

% Simulate Optical Channel (Attenuation + Noise)
noise = 0.2 * randn(size(tx_signal)); % Add random noise
rx_signal = tx_signal + noise; % Received signal with noise

% Receiver: OOK Demodulation
received_bits = mean(rx_signal) > 0.5; % Threshold detection
received_data = char(bin2dec(num2str(reshape(received_bits, 8, [])')))';

% Display Results
disp(['Original Data: ', data]);
disp(['Received Data: ', received_data]);

% Plot Signals
figure;
subplot(3,1,1);
stairs(binary_data, 'LineWidth', 2); ylim([-0.2, 1.2]); grid on;
title('Transmitted Binary Data');
subplot(3,1,2);
plot(rx_signal(:), 'r'); grid on;
title('Received Signal (with Noise)');
subplot(3,1,3);
stairs(received_bits, 'LineWidth', 2); ylim([-0.2, 1.2]); grid on;
title('Decoded Binary Data');
