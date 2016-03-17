REF_PATH = './video1';
FRAMES_PATH = strcat(REF_PATH, '/background/f%04d.jpg');
PANORAMA_PATH = strcat(REF_PATH, '/homographies/panorama.mat');
HOMOGRAPHY_PATH = strcat(REF_PATH, '/homographies/movie.mat');
WEIGHTS_PATH = strcat(REF_PATH, '/movie/weights.mat');
MOVIE_PATH = strcat(REF_PATH, '/movie/f%04d.jpg');
BACKGROUND_PATH = strcat(REF_PATH, '/background.jpg');
INVERSE_PATH = strcat(REF_PATH, '/inverse/f%04d.jpg');
FOREGROUND_PATH = strcat(REF_PATH, '/foreground/f%04d.jpg');
COMPUTE_INVERSE = false;
NUM_FRAMES = 900;
THRESHOLD = 0.4;
input_x = [1, 480];
input_y = [1, 270];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

master_frames = [0.1, 0.3, 0.5, 0.7, 0.9] * NUM_FRAMES;
master_deps = NUM_FRAMES / length(master_frames);

output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

index = 1;
figure();

if COMPUTE_INVERSE
    load(PANORAMA_PATH);
    load(HOMOGRAPHY_PATH);
        
    frame_weights = zeros(output_height, output_width, 3);
    M = ones(input_height, input_width, 3);
    
    for i = 1:length(master_frames)
        T = master_trans(:, :, i);
        
        for j = 1:master_deps
            disp(index)

            I_p = im2double(imread(sprintf(MOVIE_PATH, index)));
            T_inv = maketform('projective', inv(T * movie_trans(:, :, index))');

            imt = imtransform(I_p, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);
            imwrite(imt, sprintf(INVERSE_PATH, index));
            imshow(imt);
            
            index = index + 1;
        end
    end
else
    for i = 1:NUM_FRAMES
        disp(i);
        
        background = im2double(imread(sprintf(FRAMES_PATH, i)));
        foreground = im2double(imread(sprintf(INVERSE_PATH, i)));
        
        diff_mask = repmat((sum(abs(background - foreground), 3) < THRESHOLD), 1, 1, 3);
        foreground(diff_mask) = 0;
        
        imwrite(foreground, sprintf(FOREGROUND_PATH, i));
        %imwrite(~diff_mask, sprintf('./foremask/f%04d.jpg', i));
        imshow(double(~diff_mask));
    end
end