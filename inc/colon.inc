%define current 0

%macro colon 2
	%%label:
	dq current
	%define current %%label	
	db %1, 0
	%2:										; 	
%endmacro	

