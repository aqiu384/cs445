function makehdr_ldr_wor()
    slow = im2double(imread('1-125F.jpg')) .* (30 / 125);
    med = im2double(imread('1-30F.jpg')) .* 1;
    fast = im2double(imread('1-8F.jpg')) .* (30 / 8);
    
    slow_gray = rgb2gray(slow);
    med_gray = rgb2gray(med);
    fast_gray = rgb2gray(fast);
    
    slow_weight = mat2gray(1.0 - abs(slow_gray - 1.0));
    med_weight = mat2gray(1.0 - abs(med_gray - 1.0));
    fast_weight = mat2gray(1.0 - abs(fast_gray - 1.0));        
    
    % double(1.0 - abs(pixel - 1.0));
    
    % w = @(z) double(128-abs(z-128))
    
    output_naive = (slow + med + fast) / 3;
    output = (slow .* repmat(slow_weight, 1, 1, 3) + med .* repmat(med_weight, 1, 1, 3) + fast .* repmat(fast_weight, 1, 1, 3)) / 3;
    % output = (slow + med + fast) / 3;
    % hdrwrite(output, 'naive.hdr');
    subplot(121);
    imshow(output_naive);
    subplot(122);
    imshow(output);
end
