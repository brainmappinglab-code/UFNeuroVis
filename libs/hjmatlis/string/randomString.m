function string = randomString(n)
	% string = randomString(n)
	% random string generator
	charas = char(97:122); % consider all allowed lowercase characters
	charas = [charas  char(65:90)]; % upper case
	charas = [charas  char(48:57)]; % numbers
	
	string = charas(ceil(length(charas).*rand(1,n)));