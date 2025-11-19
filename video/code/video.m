clc;
clear;
close all;

%% Load Video File
videoFile = 'D:\tiny_wild_bird_searching_for_food_in_nature_6892037.mp4';
vidObj = VideoReader(videoFile);
numFrames = floor(vidObj.Duration * vidObj.FrameRate);
disp(['Total frames: ', num2str(numFrames)]);

% Limit number of frames for faster simulation
maxFrames = 29;
frames = cell(1, maxFrames);

% Read and resize frames
for k = 1:maxFrames
    if hasFrame(vidObj)
        frame = readFrame(vidObj);
        frames{k} = imresize(frame, [128, 128]); % Resize to reduce load
    end
end

%% Transmitter: Video to Signal
disp('Encoding video...');
txData = [];
for k = 1:maxFrames
    img = frames{k}; % RGB image
   
    % Process each channel separately
    for c = 1:3
        channel = img(:, :, c);
        binImg = dec2bin(channel(:), 8)'; % Binary per pixel
        binStream = binImg(:)' - '0'; % Convert char to binary (0/1)
        txData = [txData binStream]; % Concatenate all channels
    end
end

%% Li-Fi Channel (Simple Simulation: Add noise + attenuation)
disp('Simulating Li-Fi Channel...');
snr = 25; % Signal-to-noise ratio
rxData = awgn(double(txData), snr, 'measured');

% Threshold receiver (ideal binary decision)
rxBits = rxData > 0.5;

%% Receiver: Signal to Video
disp('Decoding video...');
frameSize = [128, 128];
channelPixels = prod(frameSize);
videoOut = zeros([frameSize, 3, maxFrames], 'uint8');

bitIndex = 1;
for k = 1:maxFrames
    for c = 1:3
        bits = rxBits(bitIndex : bitIndex + 8*channelPixels - 1);
        bits = reshape(bits, 8, [])';
        bytes = uint8(bin2dec(char(bits + '0')));
        channel = reshape(bytes, frameSize);
        videoOut(:, :, c, k) = channel;
        bitIndex = bitIndex + 8*channelPixels;
    end
end

%% Display Original and Received Video Frames
disp('Displaying results...');
figure;
for k = 1:maxFrames
    subplot(1,2,1);
    imshow(frames{k});
    title('Original Frame');

    subplot(1,2,2);
    imshow(videoOut(:,:,:,k));
    title('Received Frame');

    pause(0.3);
end
