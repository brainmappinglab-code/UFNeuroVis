function [ date_asinform ] = date_fromBOVAtoINFORM( date_asbova1 )
%[ date_asinform ] = date_fromBOVAtoINFORM( date_asbova1 )

    threshold_90=40;%year to start to consider date 90's 
    year1=str2double(date_asbova1(7:8));
    if year1>threshold_90 %this is an old date, assume it is 90's
        year_str1=sprintf('19%02d',year1);
    else %this is a low number, assume it is in the 2000.... beautiful
        year_str1=sprintf('20%02d',year1);
    end
    
    month_str1=date_asbova1(1:2);
    day_str1=date_asbova1(4:5);
    date_asinform=sprintf('%s-%s-%s',year_str1,month_str1,day_str1);
end