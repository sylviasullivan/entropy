% calculate the entropy of a random matrix of dimension m x m and a
% neighborhood of extent d
function H = entropy(m,d)

    % generate an m x m matrix and probability matrix of corresponding dims
    AA  = checkerboard(10);
    pp  = zeros(size(AA));

    % iterate through the matrix points 
    for ii = 1:size(AA,1)
    for jj = 1:size(AA,2)
        valeur = AA(ii,jj);

        c = 0;
        % what percentage of the neighboring values are the same?
        for dd = ii-d:ii+d
            for ee = jj-d:jj+d

                % apply doubly periodic boundaries
                if dd == 0; 
                    dd1 = size(AA,1) - d; 
                else if(dd < 0)
                        dd1 = dd + size(AA,1); 
                    else if(dd > size(AA,1))
                            dd1 = dd - size(AA,1);
                        else 
                            dd1 = dd;
                        end
                    end
                end
                
                if ee == 0; 
                    ee1 = size(AA,2) - d; 
                else if(ee < 0)
                        ee1 = ee + size(AA,2); 
                    else if(ee > size(AA,2))
                            ee1 = ee - size(AA,2);
                        else 
                            ee1 = ee;
                        end
                    end
                end
                    
                if(AA(dd1,ee1) == valeur)
                    pp(ii,jj) = pp(ii,jj) + 1;
                end
                c = c + 1;
            end
        end

        % normalize by (d+1)^2-1 total points in the neighborhood
        pp(ii,jj) = pp(ii,jj)/((d + d + 1)^2 - 1);

    end
    end

    % calculate entropy from the discrete probabilities
    H  = 0;
    pp = pp(:);
    for ii = 1:length(pp)
    H = H - pp(ii)*log2(pp(ii));
    end