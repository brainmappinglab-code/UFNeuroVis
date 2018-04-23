function df = derive_function_handle(f, d)
	%derive_function_handle(f, d)
	%	f: function handle
	%	d: order of derivation
	
    f_sym = sym (f);%convert to symbolic
    %diff can derive your symbolic function
    df_sym = diff(f_sym, d);
    df = matlabFunction(df_sym);%convert to function handle