function [gx gy gz] = readAcc(out,calCo)
       
        %mapping between analog inputs and X,Y,Z axes.
%         Xch = 1;
%         Ych = 3;
%         Zch = 2;
       
        fprintf(out.s,'R');
        %read voltages from accelerometer and reorder

        reordered(1)= fscanf(out.s,'%u');
        reordered(2)= fscanf(out.s,'%u');
        reordered(3)= fscanf(out.s,'%u');
        
        %determine what offset and gain values to use
        offset = calCo.offset;
        gain = calCo.g;
        accel = (reordered - offset) ./ gain;

        %map analog inputs to axes
        gx = accel(1);
        gy = accel(2);
        gz = accel(3);
end
