output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

input_x = [1, 480];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

CONFIGURE_INVERSE = false;
NUM_FRAMES = 900;

master_frames = [90, 270, 450, 630, 810];
master_deps = NUM_FRAMES / length(master_frames);

index = 1;
figure();

SAMPLE_START = 181;
SAMPLE_END = 420;
OFFSET = 90;
SAMPLE_DURATION = SAMPLE_END - SAMPLE_START;

WIDTH = 133 - 78;
HEIGHT = 263 - 213;

X_FRAMES = round(394:(213-394)/SAMPLE_DURATION:213);
Y_FRAMES = round(116:(78-116)/SAMPLE_DURATION:78);

ADD_START = SAMPLE_START - OFFSET;
ADD_END = SAMPLE_END - OFFSET;

if CONFIGURE_INVERSE
    load('./video1/homographies/panorama.mat');
    load('./video1/homographies/movie.mat');
    
    combined_trans = zeros(3, 3, NUM_FRAMES);
    
    for i = 1:length(master_frames)
        T = master_trans(:, :, i);

        for j = 1:master_deps
            disp(index)

            combined_trans(:, :, index) = T * movie_trans(:, :, index);
            index = index + 1;
        end
    end
    
    save('./video1/homographies/combined.mat', 'combined_trans');
else
    load('./video1/homographies/combined.mat');
    
    for i = ADD_START:ADD_END
        disp(i);

        T_edit = inv(combined_trans(:, :, i));
        T_copy = combined_trans(:, :, i + OFFSET);
        T_fin = maketform('projective', (T_edit * T_copy)');

        X = X_FRAMES(index);
        Y = Y_FRAMES(index);
        
        args_x = [X, X+WIDTH, X+WIDTH, X, X];
        args_y = [Y, Y, Y+HEIGHT, Y+HEIGHT, Y];

        edit_frame = im2double(imread(sprintf('./video1/frames/f%04d.jpg', i)));
        copy_frame = im2double(imread(sprintf('./video1/frames/f%04d.jpg', i + OFFSET)));
        mask_frame = repmat(poly2mask(args_x, args_y, input_height, input_width), 1, 1, 3);
        
        copy_frame = imtransform(copy_frame, T_fin, 'XData', input_x, 'YData', input_y);
        mask_frame = imtransform(mask_frame, T_fin, 'XData', input_x, 'YData', input_y);
        
        edit_frame = edit_frame .* (1 - mask_frame) + copy_frame .* mask_frame;
        imshow(edit_frame);
        imwrite(edit_frame, sprintf('./video1/replicated/f%04d.jpg', i));

        index = index + 1;
    end
end

