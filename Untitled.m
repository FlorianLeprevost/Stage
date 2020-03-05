data = round( 2 * ( rand(20) - 0.5 ) );
figure; hAxes = gca;
imagesc( hAxes, data );
colormap( hAxes , jet )