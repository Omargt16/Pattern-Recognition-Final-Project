clc
clear all
close all
warning off all
%non indexed database
non_indexed_db = [];
for no_img=1:34
    %read image
    url_base = strcat('C:\Users\datre\OneDrive\Documentos\PatRec\imagenes\db_image_',num2str(no_img),".jpg"); 
    img=imread(url_base);
    %convert to binary image
    bw=im2bw(img);
    %clean the image
    s=strel('disk',3);
    bw=imdilate(bw,s);
    [L N] = bwlabel(bw);
    %get objects
    objetos=regionprops(L,'Area','Perimeter','Extent');
    %No indexed database
    for i=1:length(objetos)
        row = [objetos(i).Area,objetos(i).Perimeter,objetos(i).Extent,no_img];
        non_indexed_db = [non_indexed_db; row];
    end
end

%Indexed database
indexed_db={}
j=1
for i=1:34
    imageFeatures = [];
    %get features of all objects in an image
    while 1
        if j > length(non_indexed_db(:,1))
            break;
        end
        if non_indexed_db(j,4) == i
            imageFeatures = [imageFeatures;non_indexed_db(j,1:3)];
            j = j + 1;
        else
            break;
        end
    end 
    classVector = getClassVector(imageFeatures);
    if i >=1 && i<=5
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),2}}];
    elseif i >=6 && i<=10
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),4}}];
    elseif i >=11 && i<=15
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),3}}];
    elseif i >=16 && i<=20
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),1}}];
    elseif i >=21 && i<=23
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),24}}];
    elseif i >=24 && i<=26
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),23}}];
    elseif i >=27 && i<=31
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),5}}];
    else
        indexed_db=[indexed_db;{{classVector,strcat('db_image_',num2str(i),".jpg"),45}}];
    end
end

fprintf("PROYECTO FINAL DE PATTERN RECOGNITION\n\n")
loop=1;
while loop == 1
    imageName = input("Ingresa el nombre de la imagen que deseas cargar (db_image_*.jpg) : ","s");
    searchImage(indexed_db,imageName);
    continuar = input("¿Deseas continuar?(0=sí,1=no)");
    if continuar == 0
        loop=0;
    end
end

%Testing 
function searchImage(indexed_db,label)
    url_base = strcat('C:\Users\datre\OneDrive\Documentos\PatRec\imagenes\',label); 
    img=imread(url_base);
    figure('Name','Input','NumberTitle','off');
    imshow(img);
    bw=im2bw(img);
    s=strel('disk',3);
    bw=imdilate(bw,s);
    [L N] = bwlabel(bw);
    if N <= 9 
        objetos=regionprops(L,'Area','Perimeter','Extent');
        imageFeatures = [];
        for i=1:length(objetos)
            row = [objetos(i).Area,objetos(i).Perimeter,objetos(i).Extent];
            imageFeatures = [imageFeatures; row];
        end
        %Area  min=2661   max=28215
        %Perimeter  min=280.57   max=976.21
        %Extent  min=0.194   max=0.77119
        unkwown = 0;
        for k=1:length(imageFeatures(:,1))
            if (imageFeatures(k,1) < 2200 || imageFeatures(k,1) > 30000) && (imageFeatures(k,2) < 200 || imageFeatures(k,2) > 1200) || (imageFeatures(k,3) < 0.15 || imageFeatures(k,3) > 0.8)
                unkwown = 1;
                break;
            end
        end
        if unkwown == 1 
            image=imread('C:\Users\datre\OneDrive\Documentos\PatRec\imagenes\unknown.jpg');
            figure('Name','Result','NumberTitle','off');
            imshow(image);  
        else
            classVector = getClassVector(imageFeatures);
            for j=1:34
                distancia(j) = getEuclidianDistance(classVector,indexed_db{j}{1});
            end
            [~, indices] = sort(distancia(:), 'ascend');
            %First match category
            classTable = getClassTable(indexed_db,indexed_db{indices(1)}{3});
            for j=1:max(size(classTable))
                distancia2(j) = getEuclidianDistance(classVector,classTable{j}{1});
            end
            [~, indices2] = sort(distancia2(:), 'ascend');
            indexes = [ classTable{indices2(1)}{2} classTable{indices2(2)}{2} classTable{indices2(3)}{2}];
            for k=1:length(indexes)
                imageName = indexed_db{indexes(k)}{2};
                imagePath = strcat('C:\Users\datre\OneDrive\Documentos\PatRec\imagenes\',imageName); 
                image=imread(imagePath);
                figure('Name',strcat("Result_",num2str(k)),'NumberTitle','off');
                imshow(image);    
            end
        end
    else
        image=imread('C:\Users\datre\OneDrive\Documentos\PatRec\imagenes\unknown.jpg');
        figure('Name','Result','NumberTitle','off');
        imshow(image);
    end
end

function classTable = getClassTable(indexed_db,class)
    classTable = {};
    for i=1:34
        if indexed_db{i}{3} == class
            classTable=[classTable;{{indexed_db{i}{1},i}}];
        end
    end
end

function clase = mahalanobisClassifier(vector)
    %Clase 1 
    colas_pato = [21284 21655 21603 22372 22093 22966 22662 23425 24228 24298 26711 26113 27379 26143 28215   ;  646.709 652.324 661.363 663.902 672.164 672.892 684.876 680.599 686.587 693.715 700.622 714.947 741.947 780.684 750.647  ;  0.713462 0.72044 0.700941 0.706009 0.699367 0.705171 0.705322 0.715049 0.726259 0.705046 0.76778 0.743198 0.706373 0.648436 0.708492];
    %Clase 2 
    rondanas = [15587 15633 15374 15358 14932 14941 14615 14234 13861 14200 14114 14056 13375 13540 12234 11578 11446 11509 10877 10743 10415 10668 10211 10286 10348 10411 8424 8448 8316 8343 7881 8076 8136 7921 7652 7737 7579   ;  477.801 469.383 470.68 468.406 475.649 470.407 468.364 452.529 450.931 447.012 450.037 443.44 434.946 433.673 411.74 402.503 400.245 401.13 389.089 387.104 383.58 383.58 376.476 377.94 379.048 379.048 341.915 341.849 337.64 341.129 333.587 334.679 336.432 331.238 325.259 325.631 320.983   ;   0.711638 0.723583 0.711463 0.720525 0.710337 0.710664 0.704847 0.716104 0.712501 0.719424 0.725283 0.722302 0.712649 0.716251 0.723948 0.712317 0.715554 0.719313 0.713246 0.721976 0.705528 0.722764 0.715056 0.720308 0.72465 0.729062 0.715596 0.717635 0.713024 0.728774 0.708086 0.718761 0.724166 0.718523 0.721342 0.722274 0.743039];
    %Clase 3
    alcayatas = [10295 8892 8488 7868 7476 7982 6055 6127 5620 4943 5486 6342 5383 5522 6639 5020 5521 6917 4711 6568 6140 6682 6139 6494 5931 5861 6806   ;  943.513 935.522 855.08 858.717 834.329 777.407 751.967 747.369 734.979 715.446 718.961 728.844 692.521 705.919 723.609 671.018 687.915 708.606 661.814 686.756 669.15 683.787 676.808 674.318 667.298 649.161 636.258    ;    0.250121 0.232836 0.251095 0.23285 0.234983 0.27158 0.185509 0.228756 0.207595 0.193995 0.206303 0.228129 0.216707 0.227271 0.265464 0.205065 0.235036 0.264695 0.210698 0.252654 0.243786 0.267098 0.258375 0.2626281 0.258229 0.262366 0.305888];
    %Clase 4
    tornillos = [7959 7393 6777 6164 5216 6326 6122 5372 2819 2273 2883 2835 3211 4183 4893 3837 5080 4020 3979 4151 3655 4064 4054 3932 3858 3938 4088   ;   777.013 711.564 686.586 652.349 572.136 551.049 504.909 477.907 362.696 387.232 400.499 371.776 367.137 418.363 445.53 421.413 421.695 411.043 400.027 401.143 380.418 375.985 373.686 371.874 359.576 368.772 375.1   ;   0.497749 0.545166 0.511549 0.527018 0.527348 0.531597 0.556141 0.543615 0.319615 0.345967 0.418736 0.431507 0.431238 0.479043 0.502671 0.50754 0.518579 0.531746 0.540111 0.549074 0.478153 0.511452 0.534124 0.542345 0.54155 0.551541 0.569677];
    %Clase 5
    armellas = [21150 21679 19159 19410 19376 17072 16311 14734 13740 14004 13637 13504 13225 13219 12972 12647 12728 12298 12597 11864 11592 11608 12543 11783 11282   ;  942.426 937.338 976.214 941.01 894.102 818.595 805.305 736.263 696.251 770.496 730.624 711.261 746.219 726.074 726.752 709.989 741.391 729.961 733.684 712.048 706.655 702.379 739.192 768.458 709.641   ;  0.333728 0.355907 0.291179 0.314128 0.341223 0.364273 0.367945 0.37147 0.374591 0.343775 0.351143 0.360049 0.338772 0.339218 0.343202 0.345207 0.327974 0.324263 0.33136 0.332604 0.324597 0.324391 0.310355 0.296204 0.307747];
    % Calcula la media de las 5 clases
    M(:,1) = mean(colas_pato,2);
    M(:,2) = mean(rondanas,2);
    M(:,3) = mean(alcayatas,2);
    M(:,4) = mean(tornillos,2);
    M(:,5) = mean(armellas,2);
    
    Matrix_cov(:,:,1) = (colas_pato-M(:,1))*(colas_pato-M(:,1))';
    Matrix_cov(:,:,2) = (rondanas-M(:,2))*(rondanas-M(:,2))';
    Matrix_cov(:,:,3) = (alcayatas-M(:,3))*(alcayatas-M(:,3))';
    Matrix_cov(:,:,4) = (tornillos-M(:,4))*(tornillos-M(:,4))';
    Matrix_cov(:,:,5) = (armellas-M(:,5))*(armellas-M(:,5))';

    for i=1:5
        Inv_Matrix_cov(:,:,i) = inv(Matrix_cov(:,:,i));
    end
    
    for i=1:5
        distancia(i) = (vector-M(:,i))'*Inv_Matrix_cov(:,:,i)*(vector-M(:,i));
    end
    minima=min(min(distancia));
    clase=find(distancia==minima);
end

%classifier 
function clase = euclidianClassifier(vector)
    %colum vector
    %Clase 1 ok
    colas_pato = [21284 21655 21603 22372 22093 22966 22662 23425 24228 24298 26711 26113 27379 26143 28215   ;  646.709 652.324 661.363 663.902 672.164 672.892 684.876 680.599 686.587 693.715 700.622 714.947 741.947 780.684 750.647  ;  0.713462 0.72044 0.700941 0.706009 0.699367 0.705171 0.705322 0.715049 0.726259 0.705046 0.76778 0.743198 0.706373 0.648436 0.708492];
    %Clase 2 ok
    rondanas = [15587 15633 15374 15358 14932 14941 14615 14234 13861 14200 14114 14056 13375 13540 12234 11578 11446 11509 10877 10743 10415 10668 10211 10286 10348 10411 8424 8448 8316 8343 7881 8076 8136 7921 7652 7737 7579   ;  477.801 469.383 470.68 468.406 475.649 470.407 468.364 452.529 450.931 447.012 450.037 443.44 434.946 433.673 411.74 402.503 400.245 401.13 389.089 387.104 383.58 383.58 376.476 377.94 379.048 379.048 341.915 341.849 337.64 341.129 333.587 334.679 336.432 331.238 325.259 325.631 320.983   ;   0.711638 0.723583 0.711463 0.720525 0.710337 0.710664 0.704847 0.716104 0.712501 0.719424 0.725283 0.722302 0.712649 0.716251 0.723948 0.712317 0.715554 0.719313 0.713246 0.721976 0.705528 0.722764 0.715056 0.720308 0.72465 0.729062 0.715596 0.717635 0.713024 0.728774 0.708086 0.718761 0.724166 0.718523 0.721342 0.722274 0.743039];
    %Clase 3
    alcayatas = [10295 8892 8488 7868 7476 7982 6055 6127 5620 4943 5486 6342 5383 5522 6639 5020 5521 6917 4711 6568 6140 6682 6139 6494 5931 5861 6806   ;  943.513 935.522 855.08 858.717 834.329 777.407 751.967 747.369 734.979 715.446 718.961 728.844 692.521 705.919 723.609 671.018 687.915 708.606 661.814 686.756 669.15 683.787 676.808 674.318 667.298 649.161 636.258    ;    0.250121 0.232836 0.251095 0.23285 0.234983 0.27158 0.185509 0.228756 0.207595 0.193995 0.206303 0.228129 0.216707 0.227271 0.265464 0.205065 0.235036 0.264695 0.210698 0.252654 0.243786 0.267098 0.258375 0.2626281 0.258229 0.262366 0.305888];
    %Clase 4
    tornillos = [7959 7393 6777 6164 5216 6326 6122 5372 2819 2273 2883 2835 3211 4183 4893 3837 5080 4020 3979 4151 3655 4064 4054 3932 3858 3938 4088   ;   777.013 711.564 686.586 652.349 572.136 551.049 504.909 477.907 362.696 387.232 400.499 371.776 367.137 418.363 445.53 421.413 421.695 411.043 400.027 401.143 380.418 375.985 373.686 371.874 359.576 368.772 375.1   ;   0.497749 0.545166 0.511549 0.527018 0.527348 0.531597 0.556141 0.543615 0.319615 0.345967 0.418736 0.431507 0.431238 0.479043 0.502671 0.50754 0.518579 0.531746 0.540111 0.549074 0.478153 0.511452 0.534124 0.542345 0.54155 0.551541 0.569677];
    %Clase 5
    armellas = [21150 21679 19159 19410 19376 17072 16311 14734 13740 14004 13637 13504 13225 13219 12972 12647 12728 12298 12597 11864 11592 11608 12543 11783 11282   ;  942.426 937.338 976.214 941.01 894.102 818.595 805.305 736.263 696.251 770.496 730.624 711.261 746.219 726.074 726.752 709.989 741.391 729.961 733.684 712.048 706.655 702.379 739.192 768.458 709.641   ;  0.333728 0.355907 0.291179 0.314128 0.341223 0.364273 0.367945 0.37147 0.374591 0.343775 0.351143 0.360049 0.338772 0.339218 0.343202 0.345207 0.327974 0.324263 0.33136 0.332604 0.324597 0.324391 0.310355 0.296204 0.307747];
    % Calcula la media de las 5 clases
    M(:,1) = mean(colas_pato,2);
    M(:,2) = mean(rondanas,2);
    M(:,3) = mean(alcayatas,2);
    M(:,4) = mean(tornillos,2);
    M(:,5) = mean(armellas,2);
    % Calcula la distancia entre las medias y el vector
    for i=1:5
        distancia(i) = norm(vector-M(:,i));
    end
    minima=min(min(distancia));
    clase=find(distancia==minima);
end

%Get class vector 
function classVector = getClassVector(featureMatrix)
    classVector = [0 0 0 0 0 0 0 0 0];
    for i=1:length(featureMatrix(:,1))
        class = mahalanobisClassifier(featureMatrix(i,:).');
        classVector(i) = class;
    end
end

%get euclidian distance
function distancia = getEuclidianDistance(v1,v2)
    acc = 0;
    for i=1:length(v1)
        n = v1(i) - v2(i)
        acc = acc + n*n;
    end
    distancia = sqrt(acc);
end
%{
X=[];%Area
Y=[];%Perimeter
Z=[];%Extent
for j=1:length(non_indexed_db)
    X(end+1)=non_indexed_db(j,1);
    Y(end+1)=non_indexed_db(j,2);
    Z(end+1)=non_indexed_db(j,3);
end
hold on;
plot3(X,Y,Z,'o','Color','r');
plot3(26143,780.6840,0.6484,'h','Color','g');%Cola de pato
plot3(10295,943.5130,0.2501,'h','Color','b');%Alcayata
plot3(7959,777.0130,0.4977,'h','Color','c');%Tornillo
plot3(12234,411.7400,0.7239,'h','Color','m');%Rondanas o arandelas
plot3(17072,818.6,0.36427,'h','Color','k');%Armellas
xlabel('Area')
ylabel('Perimeter')
zlabel('Extent')
%}