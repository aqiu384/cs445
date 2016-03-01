function makehdr_response()
    SIZE = 255;
    COUNT = 3;

    WEIGHTS = [24, 60, 120, 205, 553];
    IMAGES = zeros(SIZE, SIZE, 3, COUNT);
    TOTAL_SCALE = zeros(SIZE, SIZE, 3);
    
    weight_fun = @(z) 128 - abs(z - 128);
    output = zeros(SIZE, SIZE, 3);
    
    IMAGE_FILES = {
        './inputs/0024.jpg'
        './inputs/0060.jpg'
        './inputs/0120.jpg'
        './inputs/0205.jpg'
        './inputs/0553.jpg'
    };
    
    for i = 1:COUNT
        IMAGES(:, :, :, i) = floor(imresize(double(imread(IMAGE_FILES{i})), [SIZE, SIZE], 'bilinear'));
    end
    
    POINT_INDEX = sparse(randi(SIZE, 1, 100), randi(SIZE, 1, 100), ones(1, 100), SIZE, SIZE) == 1;
    
    for i = 1:3
        CHANNELS = squeeze(IMAGES(:, :, i, :));
        MY_WEIGHTS = weight_fun(CHANNELS);
        POINTS = zeros(100, COUNT);
        
        for j = 1:COUNT
            CHANNEL = CHANNELS(:, :, j);
            POINTS(:, j) = CHANNEL(POINT_INDEX);
        end

        % Z B l w
        Z = POINTS;
        B = ones(1, COUNT) ./ WEIGHTS(1:COUNT);
        lambda = 100;
        w = weight_fun;

        [g, ~] = gsolve(Z, B, lambda, w);        
        combined = g(1 + CHANNELS);
        
        for j = 1:COUNT
            combined(:, :, j) = combined(:, :, j) - B(j);
            MY_WEIGHTS(:, :, j) = WEIGHTS(j) * MY_WEIGHTS(:, :, j);
        end
        
        output(:, :, i) = exp(sum(MY_WEIGHTS .* combined, 3) ./ sum(MY_WEIGHTS, 3));
    end
    
    imshow(mat2gray(output));
        
%     [HEIGHT, WIDTH, DEPTH] = size(slow);
%     
%     weight_fun = @(z) 1.0 - abs(z - 1.0);
%     gray_fun = @(z) repmat(weight_fun(rgb2gray(z)), 1, 1, 3);
% 
%     POINT_INDEX = sparse(randi(SIZE, 1, 100), randi(SIZE, 1, 100), ones(1, 100)) == 1;
%     output = zeros(size(slow));
    
%     subplot(221);
%     imshow(slow);
%     subplot(222);
%     imshow(med);
%     subplot(223);
%     imshow(fast);
%     subplot(224);
%     imshow(output);
end

