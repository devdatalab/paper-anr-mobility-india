% writes a graph in PNG format only, copies the PNG to ~/public_html
function [] = write_png(fn);

    print(fn, '-dpng');

