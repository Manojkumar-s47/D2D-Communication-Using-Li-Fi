clc; clear; close all;

% Load the original color image
img = imread('image.jpg');

% Separate the R, G, and B channels
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% Convert each channel to binary
bin_R = dec2bin(R(:), 8);
bin_G = dec2bin(G(:), 8);
bin_B = dec2bin(B(:), 8);

% Convert binary data into a serial stream
bin_stream_R = bin_R';
bin_stream_G = bin_G';
bin_stream_B = bin_B';

% Flatten to 1D binary stream
bin_stream_R = bin_stream_R(:)';
bin_stream_G = bin_stream_G(:)';
bin_stream_B = bin_stream_B(:)';
% Modulate using OOK (On-Off Keying)
mod_signal_R = double(bin_stream_R == '1');
mod_signal_G = double(bin_stream_G == '1');
mod_signal_B = double(bin_stream_B == '1’);  

% Add noise to simulate real-world conditions
snr = 30; % Signal-to-Noise Ratio
noisy_signal_R = awgn(mod_signal_R, snr, 'measured');
noisy_signal_G = awgn(mod_signal_G, snr, 'measured');
noisy_signal_B = awgn(mod_signal_B, snr, 'measured');
% Demodulate the received signals
received_bin_R = noisy_signal_R > 0.5;
received_bin_G = noisy_signal_G > 0.5;
received_bin_B = noisy_signal_B > 0.5;

% Convert binary stream back to original format
received_bin_matrix_R = reshape(char(received_bin_R + '0'), 8, []).';
received_bin_matrix_G = reshape(char(received_bin_G + '0'), 8, []).';
received_bin_matrix_B = reshape(char(received_bin_B + '0'), 8, []).';

% Convert binary to decimal pixel values
received_pixel_R = uint8(bin2dec(received_bin_matrix_R));
received_pixel_G = uint8(bin2dec(received_bin_matrix_G));
received_pixel_B = uint8(bin2dec(received_bin_matrix_B));

% Reshape to reconstruct the color image
reconstructed_R = reshape(received_pixel_R, size(R));
reconstructed_G = reshape(received_pixel_G, size(G));
reconstructed_B = reshape(received_pixel_B, size(B));

% Combine the channels into a color image
reconstructed_image = cat(3, reconstructed_R, reconstructed_G, reconstructed_B);

% Display results
figure;
subplot(2,2,1); imshow(img); title('Original Color Image');
subplot(2,2,2); stairs(mod_signal_R(1:100)); title('Transmitted Binary Data (R)');
subplot(2,2,3); plot(noisy_signal_R(1:1000)); title('OOK Modulated Signal (R)');
subplot(2,2,4); imshow(reconstructed_image); title('Reconstructed Color Image');
