function makehdr_weight()
    SIZE = 255;
    COUNT = 3;

    WEIGHTS = [24, 60, 120, 205, 553];
    IMAGES = zeros(SIZE, SIZE, 3, COUNT);
    TOTAL_SCALE = zeros(SIZE, SIZE, 3);
    
    weight_fun = @(z) 0.5 - abs(z - 0.5);
    
    IMAGE_FILES = {
        './inputs/0024.jpg'
        './inputs/0060.jpg'
        './inputs/0120.jpg'
        './inputs/0205.jpg'
        './inputs/0553.jpg'
    };
    
    for i = 1:COUNT
        image = imresize(im2double(imread(IMAGE_FILES{i})), [SIZE, SIZE], 'bilinear');
        scale = weight_fun(image);
        
        IMAGES(:, :, :, i) = WEIGHTS(i) * scale .* image;
        TOTAL_SCALE = TOTAL_SCALE + WEIGHTS(i) * scale;
    end

    naive = sum(IMAGES, 4) ./ TOTAL_SCALE;
    imshow(mat2gray(naive));
    axis equal;
end


