function [images] = read_images(image_path)
    files = dir(image_path);
    files = files(3:end);
    images = struct();
end

