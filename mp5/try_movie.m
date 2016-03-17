addpath vlfeat-0.9.19/
addpath vlfeat-0.9.19/toolbox/
vl_setup;

REF_PATH = './video2';
FRAMES_PATH = strcat(REF_PATH, '/frames/f%04d.jpg');
PANORAMA_PATH = strcat(REF_PATH, '/homographies/panorama.mat');
HOMOGRAPHY_PATH = strcat(REF_PATH, '/homographies/movie.mat');
WEIGHTS_PATH = strcat(REF_PATH, '/movie/weights.mat');
MOVIE_PATH = strcat(REF_PATH, '/movie/f%04d.jpg');
COMPUTE_HOMOGRAPHIES = false;
FRAME_COUNT = 600;
input_x = [1, 480];
input_y = [1, 270];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

master_frames = [0.1, 0.3, 0.5, 0.7, 0.9] * FRAME_COUNT;
master_deps = FRAME_COUNT / length(master_frames);

output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

index = 1;

if COMPUTE_HOMOGRAPHIES
    movie_trans = zeros(3, 3, 900);

    for i = 1:length(master_frames)
        I = imread(sprintf(FRAMES_PATH, master_frames(i)));

        for y = 1:master_deps
            disp(index);
            
            I_p = imread(sprintf(FRAMES_PATH, index));
            movie_trans(:, :, index) = auto_homography(I_p, I);
            
            index = index + 1;
        end

        movie_trans(:, :, master_frames(i)) = eye(3);
    end

    save(HOMOGRAPHY_PATH, 'movie_trans');
else
    load(PANORAMA_PATH);
    load(HOMOGRAPHY_PATH);
    
    figure();
    
    frame_weights = zeros(output_height, output_width, 3);
    M = ones(input_height, input_width, 3);
    
    for i = 1:length(master_frames)
        T = master_trans(:, :, i);
        
        for j = 1:master_deps
            disp(index)

            I_p = im2double(imread(sprintf(FRAMES_PATH, index)));
            T_p = maketform('projective', (T * movie_trans(:, :, index))');

            imt = imtransform(I_p, T_p, 'XData', output_x, 'YData', output_y);
            mt = imtransform(M, T_p, 'XData', output_x, 'YData', output_y);
            
            frame_weights = frame_weights + mt;
            imwrite(imt, sprintf(MOVIE_PATH, index));
            imshow(imt);
            
            index = index + 1;
        end
    end
    
    save(WEIGHTS_PATH, 'frame_weights');
end