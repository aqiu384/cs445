object_background = im2double(imread('./video1/object_background.png'));
object_mask = im2double(imread('./video1/object_mask.png'));

REF_PATH = './video1';
FRAMES_PATH = strcat(REF_PATH, '/inverse/f%04d.jpg');
PANORAMA_PATH = strcat(REF_PATH, '/homographies/panorama.mat');
HOMOGRAPHY_PATH = strcat(REF_PATH, '/homographies/movie.mat');
OBJECT_PATH = strcat(REF_PATH, '/objects/f%04d.jpg');
NUM_FRAMES = 900;
input_x = [1, 480];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

master_frames = [0.1, 0.3, 0.5, 0.7, 0.9] * NUM_FRAMES;
master_deps = NUM_FRAMES / length(master_frames);

output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

load(PANORAMA_PATH);
load(HOMOGRAPHY_PATH);

index = 1;
figure();

for i = 1:length(master_frames)
    T = master_trans(:, :, i);

    for j = 1:master_deps
        disp(index)

        T_inv = maketform('projective', inv(T * movie_trans(:, :, index))');

        object = imtransform(object_background, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);
        mask = imtransform(object_mask, T_inv, 'UData', output_x, 'VData', output_y, 'XData', input_x, 'YData', input_y);
        frame = im2double(imread(sprintf(FRAMES_PATH, index)));
        
        frame = frame .* (1 - mask) + object .* mask;
        imwrite(frame, sprintf(OBJECT_PATH, index));
        imshow(frame);

        index = index + 1;
    end
end

    background = im2double(imread(sprintf('./objects/f%04d.jpg', i)));
    foreground = im2double(imread(sprintf('./foreground/f%04d.jpg', i)));
    foremask = im2double(imread(sprintf('./foremask/f%04d.jpg', i)));