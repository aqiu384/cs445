output_x = [-651, 980];
output_y = [-51, 460];

output_width = output_x(2) - output_x(1) + 1;
output_height = output_y(2) - output_y(1) + 1;

input_x = [1, 480];
input_y = [1, 360];

input_width = input_x(2) - input_x(1) + 1;
input_height = input_y(2) - input_y(1) + 1;

load('./homographies/panorama.mat');

frame_450 = im2double(imread('./frames/f0450.jpg'));
frame_270 = im2double(imread('./frames/f0270.jpg'));
M = ones(input_height, input_width);


T = maketform('projective', master_trans(:, :, 3)');
mask_450 = imtransform(M, T, 'XData', output_x, 'YData', output_y);
trans_450 = imtransform(frame_450, T, 'XData', output_x, 'YData', output_y);

T = maketform('projective', master_trans(:, :, 2)');
mask_270 = imtransform(M, T, 'XData', output_x, 'YData', output_y);
trans_270 = imtransform(frame_270, T, 'XData', output_x, 'YData', output_y);

bite = mask_270 - mask_450;

rows = sum(bite(1:floor(end/2), :), 1);
rows(rows > 1) = 1;
rows(rows < 1) = 0;
[~, TOP_RIGHT] = ismember(-1, diff(rows));
TOP_RIGHT = TOP_RIGHT - 652;

rows = sum(bite(floor(end/2):end, :), 1);
rows(rows > 1) = 1;
rows(rows < 1) = 0;
[~, BOTTOM_LEFT] = ismember(-1, diff(rows));
BOTTOM_LEFT = BOTTOM_LEFT - 652;

rows = sum(mask_270, 1);
rows(rows > 1) = 1;
rows(rows < 1) = 0;
[~, RIGHT] = ismember(-1, diff(rows));

UP = 0 + 53;
DOWN = 360 + 52;
LEFT = 0 + 653;

[costs, ~] = imgradient(sum(abs(trans_450 - trans_270), 3), 'prewitt');
costs = costs(UP:DOWN, LEFT:RIGHT);
costs = 1 - costs;

% costs = sum(abs(trans_450 - trans_270), 3);
% costs = costs(UP:DOWN, LEFT:RIGHT);
% costs = abs(costs(:, 1:end-1) - costs(:, 2:end));

costs(1, :) = Inf;
costs(:, 1:2) = Inf;
costs(:, end-1:end) = Inf;
costs(1, TOP_RIGHT) = 0;

for i = 2:360
    %prev_costs = min([costs(i-1, 1:end-2); costs(i-1, 2:end-1); costs(i-1, 3:end)]); 
    prev_costs = min([costs(i-1, 1:end-4); costs(i-1, 2:end-3); costs(i-1, 3:end-2); costs(i-1, 4:end-1); costs(i-1, 5:end)]); 
    my_costs = costs(i, 3:end-2);
    costs(i, 3:end-2) = prev_costs + my_costs;
end

j = BOTTOM_LEFT;

[costs2, ~] = imgradient(sum(abs(trans_450 - trans_270), 3), 'prewitt');
costs2 = costs2(UP:DOWN, LEFT:RIGHT);
costs2 = 1 - costs2;

imagesc(costs);
axis equal;

% costs2 = sum(abs(trans_450 - trans_270), 3);
% costs2 = costs2(UP:DOWN, LEFT:RIGHT);

for i = 360:-1:2
    %costs2(i, 1:j-1) = 1;
    %costs2(i, j:end) = 0;
    costs2(i, j) = -Inf;
    [~, offset] = min(costs(i-1, j-2:j+2));
    j = j - 3 + offset;
end

imagesc(costs2);
axis equal;

costs2(1, 1:TOP_RIGHT-1) = 1;   
costs2(1, TOP_RIGHT:end) = 0;

%costs2 = (repmat(costs2, 1, 1, 3) == 0);
% 
% bite_270 = trans_270(UP:DOWN, LEFT:RIGHT, :);
% bite_270(costs2) = 0;
% trans_270(UP:DOWN, LEFT:RIGHT, :) = bite_270;
% 
% bite_450 = trans_450(UP:DOWN, LEFT:RIGHT, :);
% bite_450(~costs2) = 0;
% trans_450(UP:DOWN, LEFT:RIGHT, :) = bite_450;
% 
% figure();
% imshow(trans_450 + trans_270);


% function output = cut_path(bndcost, display_path)
%     [overlap, patchsize] = size(bndcost);
% 
%     for col = 1:patchsize - 1
%         sum_col = zeros(overlap, 1);
%         
%         for row = 2:overlap - 1
%             sum_col(row) = min(bndcost(row - 1:row + 1, col));
%         end
%         
%         sum_col(1) = min(bndcost(1:2, col));
%         sum_col(end) = min(bndcost(end-1:end, col));
%         
%         bndcost(:, col + 1) = bndcost(:, col + 1) + sum_col;
%     end
%     
%     bndcost = transpose(bndcost);
%     x_ers = 1:patchsize;
%     
%     output = ones(patchsize, patchsize);
%     [~, min_index] = min(bndcost(patchsize, :));
% 
%     for row = patchsize:-1:1
%         if min_index == 1
%             [~, min_index] = min(bndcost(row, 1:2));
%         elseif min_index == overlap
%             [~, temp_index] = min(bndcost(row, end-1:end));
%             min_index = overlap - 2 + temp_index;
%         else
%             [~, temp_index] = min(bndcost(row, min_index - 1:min_index + 1));
%             min_index = min_index + temp_index - 2;
%         end
%         
%         if display_path
%             x_ers(row) = min_index;
%         else
%             output(row, 1:min_index) = 0;
%         end
%     end
%     
%     if display_path
%         figure(1);
%         imagesc(bndcost);
%         axis equal;
%         
%         figure(2);
%         imagesc(bndcost);
%         hold on;
%         plot(x_ers, 1:patchsize, 'r');
%         hold off;
%         axis equal;
%     end
% end

