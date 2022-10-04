% get an RGB triple from a matlab character color
function rgb = get_rgb(s);
    rgb = rem(floor((strfind('kbgcrmyw', s) - 1) * [0.25 0.5 1]), 2);
