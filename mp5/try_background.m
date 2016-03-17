REF_PATH = './video1';
FRAMES_PATH = strcat(REF_PATH, '/background/f%04d.jpg');
PANORAMA_PATH = strcat(REF_PATH, '/homographies/panorama.mat');
HOMOGRAPHY_PATH = strcat(REF_PATH, '/homographies/movie.mat');
WEIGHTS_PATH = strcat(REF_PATH, '/movie/weights.mat');
MOVIE_PATH = strcat(REF_PATH, '/movie/f%04d.jpg');
BACKGROUND_PATH = strcat(REF_PATH, '/background.jpg');
COMPUTE_BACKGROUND = true;
NUM_FRAMES = 900;
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

if COMPUTE_BACKGROUND
    load(WEIGHTS_PATH);
    output = zeros(output_height, output_width, 3);

    for i = 1:NUM_FRAMES
        disp(i);
        output = output + im2double(imread(sprintf(MOVIE_PATH, i)));
    end
    
    frame_weights(frame_weights < 1) = 1;
    output = output ./ frame_weights;
    imwrite(output, BACKGROUND_PATH);
else
    load(PANORAMA_PATH);
    load(HOMOGRAPHY_PATH);
    
    I = imread(BACKGROUND_PATH);
    
    for i = 1:length(master_frames)
        T = master_trans(:, :, i);
        
        for j = 1:master_deps
            disp(index)
            
            T_inv = maketform('projective', inv(T * movie_trans(:, :, index))');
            
            imt = imtransform(I, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);
            imwrite(imt, sprintf(FRAMES_PATH, index));
            imshow(imt);
            
            index = index + 1;
        end
    end
end