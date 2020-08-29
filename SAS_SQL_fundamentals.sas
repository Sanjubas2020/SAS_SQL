/*where clause*/

proc print data=sq.customer (obs=100);
run;

proc sql number;
select FirstName, LastName, State 
   from sq.customer
   where State = 'VT';
quit;

proc sql number;
select FirstName, LastName, State 
   from sq.customer
   where State in ('VT','SC');
quit;

proc sql number;
select FirstName, LastName, State 
   from sq.customer
   where State in ('VT','SC');
quit;


proc sql number;
select FirstName, LastName, State 
   from sq.customer
   where State in ('VT','SC', 'GA');
quit;


/*where clause with operators*/

proc sql number;
select FirstName, LastName, UserID, CreditScore
	from sq.customer
where creditscore < 500 and creditscore is not null;
quit;

proc sql number;
select FirstName, LastName, UserID, CreditScore
	from sq.customer
where creditscore < 500 and creditscore ne .;
quit;

/*Date value can be used with the*/
/*where DOB < "01JAN2000"d*/


/*sorting by two varialbes, the first is the key and the second will be sorted within first*/
proc sql;
select FirstName, LastName, CreditScore
	from sq.customer
	where CreditScore > 830
    order by creditscore desc,lastname;
quit;
proc sql;
select FirstName, LastName, CreditScore
	from sq.customer
	where CreditScore > 830
    order by 3 desc, 2;
quit;
*\Enhancing reports, title footnotes and labels*\

title 'Customer from Hawaii';
footnote 'August 27 2020';

proc sql;
select FirstName, LastName, State, 
       UserID label= 'Email Address', 
       Income label= 'Estimated Income', 
       DOB format dollar16.2
	from sq.customer
	where State = "HI" and 
          BankID is not null
	order by Income desc;
quit;

title; /*Clear title*/
footnote; /*Clear footnote*/

title "DOB Prior to December 31, 1940";
title2 "Retirement Campaign";
proc sql;
select CustomerID, State, Zip format=z5., 
       DOB format date9., UserID, 
       HomePhone, CellPhone
    from sq.customer
    where DOB <'31DEC1940'd and Employed ='Y'
	order by DOB desc;
quit;
title;


/*Creating new columns*/

proc sql;
select FirstName, LastName, UserID,
	yrdif (dob, '01jan2019'd) as age
    from sq.customer;
quit;

/* subsetting calculated values*/


proc sql;
select FirstName, LastName, UserID,
	yrdif (dob, '01jan2019'd) as age
    from sq.customer
    where calculated age >= 70;
quit;

/*Assigning Values Conditionally*/
proc sql;
select FirstName, LastName, State, CreditScore,
	   case
	         when CreditScore >=750 then "Excellent"
		 when CreditScore >=700 then "Good"
		 when CreditScore >=650 then 'Fair'
		 when CreditScore >=550 then "Poor"
		 when CreditScore >=0 then "Bad"
		 else 'Unknown'
       end as CreditCategory
	from sq.customer(obs=1000)
	where calculated creditcategory ='Excellent';
quit;

/*Assigning Values Conditionally   case operand*/
proc sql;
select FirstName, LastName, State, CreditScore, Married,
       case Married
          when "M" then "Married"
		  when "D" then "Divorced"
		  when "S" then "Single"
		  when "W" then "Widow"
		  else 'Unknown'
       end as MarriedCategory
    from sq.customer(obs=1000);
quit;

/*Eliminating Duplicate Rows with the DISTINCT Keywor*/

proc sql;
select distinct married
    from sq.customer;
quit;

proc sql;
select distinct state
    from sq.customer;
quit;

/*summarizing data
SQL	SAS	Returned Value
AVG	MEAN	Mean (average) value
COUNT	FREQ, N	Number of nonmissing values
MAX	MAX	Largest value
MIN	MIN	Smallest nonmissing value
SUM	SUM	Sum of nonmissing values
 	NMISS	Number of missing values
 	STD	Standard deviation
 	VAR	Variance  */
	
proc sql inobs=10;
describe table sq.statepopulation;
select Region, Division, Name, PopEstimate1, PopEstimate2, PopEstimate3
    from sq.statepopulation;
quit;

/*Method 1 - Down a Column: Find the count, mean, std, min and max of the PopEstimate1 column*/
proc sql;
select count(PopEstimate1) as TotalStates,
       mean(PopEstimate1) as Mean format=comma16.,
	    std(PopEstimate1) as Stdev format=comma16.,
		 min(PopEstimate1) as Min format=comma16.,
		  max(PopEstimate1) as Max format=comma16.
    from sq.statepopulation;
quit;


/*SAS Method - PROC MEANS*/
proc means data=sq.statepopulation maxdec=0;
	var PopEstimate1;
run;

/*Method 2 - Across a Column: Find the mean, std, min and max of the PopEstimate1 column*/

proc sql;
select Name, 
       PopEstimate1 format=comma16., 
       PopEstimate2 format=comma16., 
       PopEstimate3 format=comma16.,
	   mean(PopEstimate1, PopEstimate2, PopEstimate3) as Mean format=comma16., 
       min(PopEstimate1, PopEstimate2, PopEstimate3) as Min format=comma16.,
       max(PopEstimate1, PopEstimate2, PopEstimate3) as Max format=comma16. 
	from sq.statepopulation;
quit;


/*Summarizing Data Using the COUNT Function*/
/* count (*) missing values not included, count (married) missing values are included*/
proc sql;
select count(*) as TotalRows format=comma10.,
       count(Married) as MaritalStatus format=comma10.
	from sq.customer;
quit;

/*You can use DISTINCT with the COUNT function to return the number of distinct, nonmissing values from a column8*/
proc sql;
select count(*) as TotalRows format=comma10.,
       count(distinct Married) as MaritalStatus format=comma10.
	from sq.customer;
quit;


/*Grouping data*/

proc sql;
select State, count (*) as Totalcustomers format=comma7.
    from sq.customer(obs=1000)
    group by State; 

quit;

proc sql;
select BankID, Employed, count (*) as Totalcustomers format=comma7.
    from sq.customer
    group by BankID, Employed
/*	having calculated Totalcustomers > 1000*/
	order by Totalcustomers desc;
quit;


/*Summarizing Date and Time Data*/
proc sql;
select month(datepart(DateTime)) as Month, 
       Median(Amount) as MedianSpent format=dollar16.
    from sq.transaction
    group by Month;
quit;

proc sql;
select QTR(datepart(DateTime)) as QTR, 
       Median(Amount) as MedianSpent format=dollar16.
    from sq.transaction
    group by QTR;
quit;


/*Counting Rows Using a Boolean Expression*/
proc sql;
create table CustomerCount as
select State, 
       yrdif(DOB,"01JAN2020"d,'age') <25 as Under25,
	   yrdif(DOB,"01JAN2020"d,'age') >64 as Over64
    from sq.customer
quit;

proc sql;
create table CustomerCount as
select State, 
       sum(yrdif(DOB,"01JAN2020"d,'age') <25) as Under25,
	   sum (yrdif(DOB,"01JAN2020"d,'age') >64) as Over64
    from sq.customer
	group by state;
quit;

/*Creating tables in SAS SQL*/

proc sql;
create table Top5States as
select Name label="State Name", 
       PopEstimate1 format=comma14. label="Population Estimate"
    from sq.statepopulation
	order by PopEstimate1 desc;
quit;


/* USE THE TABLE IN A VISUALIZATION*/
title "Next Year's Top 5 State Population Estimate";
footnote "Created on %left(%qsysfunc(today(),weekdate.))";/             *<-----Automatically adds the current date as the footnote*/
proc sgplot data=Top5States;                                             /*<------------Top5States table from above*/
   vbar Name / response=PopEstimate1                                     /*<----Specifies the numeric response value*/
			   categoryorder=respdesc                        /*<---Specify the order in which the columns are arranged*/
               dataskin=matte                                            /*<-----------Specifies a special effect to be used on the bars*/
			   fillattrs=(color=bigb);                       /*<---Specifies the fill color*/
run;
title;
footnote;

proc sql;
create table work.highcredit       
     like sq.customer(keep=FirstName LastName 
                           UserID CreditScore);
quit;


/*Inserting Rows with a Query*/              

proc sql;
insert into work.highcredit(FirstName, LastName, UserID, CreditScore)
select FirstName, LastName, UserID, CreditScore
     from sq.customer
     where CreditScore > 700;
quit;



/*Inserting Rows with the SET Clause */       

proc sql;
insert into highcredit
    set FirstName="",  /*<-----Add your first name*/
	    LastName="",   /*<-----Add your last name*/
		UserID="",    /*<-----Add your first initial followed by your last name*/
		CreditScore=700; /*<-----Add any number from 701 - 850*/
quit;


/*Drop table*/
proc sql;
drop table highcredit;
quit;


/*using dictionary tables tables columns libnames*/
proc sql;
describe table dictionary.dictionaries;
select *
	from dictionary.dictionaries;
quit;

proc sql;
describe table dictionary.dictionaries;
select distinct memname, memlabel
	from dictionary.dictionaries;
quit;


/*explore dictionary tables*/

proc sql inobs=100;
describe table dictionary.tables;
select *
	from dictionary.tables;
quit;

/*SAS Equivalent of dictionary.tables*/
proc print data=sashelp.vtable;
	where Libname = "SQ";
run;
/*SAS Equivalent of dictionary.columns*/
proc sql;
describe table dictionary.columns;
select *
	from dictionary.columns
	where Libname = "SQ";
quit;

proc sql;
describe table dictionary.columns;
select distinct libname
	from dictionary.columns
quit;


/*SAS Equivalent of dictionary.columns*/
proc print data=sashelp.vcolumn(obs=100);
	where Libname = "SQ";
run;


/*SAS Equivalent of dictionary.libnames*/
proc sql;
describe table dictionary.libnames;
select *
	from dictionary.libnames;
quit;

/*SAS Equivalent of dictionary.members*/
proc print data=sashelp.vlibnam;
    where Libname = "SQ";
run;
