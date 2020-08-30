

/*SQl joins note two tables sq.smallcustome and sq.smalltransaction*/
proc sql number;
title "Table: smallcustomer";
select *
	from sq.smallcustomer;
title "Table: smalltransaction";
select *
	from sq.smalltransaction;
title;
quit;



title "Cartesian Product";
proc sql number;
select *        /*joins every time which has redunant joins*/
	from  sq.smallcustomer, sq.smalltransaction;
quit;
title;

/*inner joins using SAS sql*/

proc sql;
select FirstName, LastName, State, Income, DateTime, MerchantID, Amount
	from sq.smallcustomer inner join sq.smalltransaction
    on smallcustomer.AccountID =smalltransaction.AccountID;
quit;

proc sql;
select FirstName, LastName, State, Income, DateTime, MerchantID, 
       Amount, smallcustomer.AccountID
    from sq.smallcustomer inner join 
         sq.smalltransaction
    on smallcustomer.AccountID = smalltransaction.AccountID
    where State = "NY"
    order by Amount desc;
quit;


/*Alternative SQL Inner Join Syntax*/


/*Using Table Aliases*/
proc sql number;
select Name, StateName, PopEstimate1, PopEstimate2, PopEstimate3
	from sq.statepopulation as p inner join 
         sq.statecode as s
	on p.Name = s.StateCode
    order by StateName;
quit;

/*Matching Rows with a Natural Join*/

/*Selecting Data from More Than Two Tables*/
proc sql;
select memname, name
	from dictionary.columns
	where libname="SQ" and 
          upcase(name)='BANKID';
quit;
proc sql;
select memname, name
	from dictionary.columns
	where libname="SQ" and 
          upcase(name)='MERCHANTID';
quit;


/*Performing an Inner Join with Four Tables*/
proc sql;
select FirstName, LastName, c.State, Income, DateTime, MerchantID, 
       Amount, c.AccountID, c.BankID
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID;
quit;


proc sql;
select FirstName, LastName, c.State, Income, DateTime,
       MerchantName, Amount, c.AccountID, c.BankID
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID inner join 
       sq.merchant as m
	on t.MerchantID = m.MerchantID;
quit;


proc sql;
select FirstName, LastName, c.State, Income, DateTime, 
       MerchantName, Amount, c.AccountID, b.Name
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID inner join 
       sq.merchant as m
    on t.MerchantID = m.MerchantID inner join 
       sq.bank as b
    on t.BankID = b.BankID;
quit;

/*Handling Missing Values*/
proc sql;
select FirstName, LastName, c.State, Income, DateTime, MerchantID, 
       Amount, c.AccountID, c.BankID
    from sq.smallcustomer as c inner join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID and 
	c.AccountID is not null;
quit;

/*Creating Non-Equijoins*/
proc sql;
select FirstName, LastName, Income format=dollar16., 
       TaxBracket
	from sq.smallcustomer as c inner join 
         sq.taxbracket as t
    on c.Income between t.LowIncome and t.HighIncome /*Complete the ON clause*/
	order by TaxBracket desc, Income desc;
quit;


/*Performing Left and Right Outer Joins*/

proc sql number;
	select FirstName, LastName, Income,  
           c.AccountID "c.AccountID", t.AccountID "t.AccountID", 
           DateTime, MerchantID, Amount 
	from sq.smallcustomer as c left join 
         sq.smalltransaction as t
	on c.AccountID = t.AccountID;
quit;

/*Joining Two Tables with a Full Join, note the use of coalescense */

proc sql;
select FirstName, LastName, Income, c.AccountID,   
       DateTime, MerchantID, Amount
    from sq.smallcustomer as c full join 
         sq.smalltransaction as t
      on c.AccountID = t.AccountID;
quit;


proc sql;
select FirstName, LastName, Income, t.AccountID,   
       DateTime, MerchantID, Amount
    from sq.smallcustomer as c full join 
         sq.smalltransaction as t
      on c.AccountID = t.AccountID;
quit;


proc sql;
select FirstName, LastName, Income,  
       coalesce(c.AccountID,t.AccountID) as AccountID format=10., 
       DateTime, MerchantID, Amount
    from sq.smallcustomer as c full join 
         sq.smalltransaction as t
    on c.AccountID = t.AccountID;
quit;


/*Identifying Nonmatching Rows*/


proc sql;
select FirstName, LastName, Income, 
       c.AccountID "c.AccountID", 
       t.AccountID "t.AccountID", 
       DateTime, MerchantID
    from sq.smalltransaction2 as t left join 
         sq.smallcustomer2 as c
      on c.AccountID = t.AccountID and
	     t.AccountID is not null;
quit;


proc sql;
select FirstName, LastName, Income, 
       c.AccountID "c.AccountID", 
       t.AccountID "t.AccountID", 
       DateTime, MerchantID
    from sq.smalltransaction2 as t left join 
         sq.smallcustomer2 as c
      on c.AccountID = t.AccountID and
	     t.AccountID is not null
    where c.AccountID is null;
quit;

/*complex joins,*Using Reflexive Joins*/
proc sql;
select e.EmployeeID, e.EmployeeName, e.StartDate format=date9., e.ManagerID
	from sq.employee as e inner join
         sq.employee as m
    on e.ManagerID = m.EmployeeID;
quit;


proc sql;
select e.EmployeeID, e.EmployeeName, e.StartDate format=date9., e.ManagerID,
       m.EmployeeName
	from sq.employee as e inner join
         sq.employee as m
    on e.ManagerID = m.EmployeeID;
quit;


proc sql;
select e.EmployeeID, e.EmployeeName, e.StartDate format=date9., e.ManagerID,
       m.EmployeeName as ManagerName
    from sq.employee as e inner join
         sq.employee as m
    on e.ManagerID = m.EmployeeID
    order by ManagerName;
quit;

/*Using Functions to Join Tables, no common table names, we can use substring to prepare a common column impressive*/

proc sql inobs=100 number;
select StateID, CustomerName, StateName
    from sq.transactionfull as t inner join 
         sq.statecode as s
	  on substr(t.StateID,1,2) = s.StateCode;
quit;

/*Using Functions to Join When Column Types Are Different, put and input functions to convert the table*/
proc sql;
create table customerzip
	(CustomerID num,
     ZipCode char(5),
     Gender char(1),
     Employed char(1));
insert into customerzip
    values(1,"14580","M","Y")
	values(2,"04429","M","Y")
	values(3,"50101","M","Y")
	values(4,"27519","M","Y")
	values(5,"14216","M","Y")
;
quit;



proc sql;
select c.CustomerID, c.ZipCode, c.Gender, 
       z.Zip, z.City, z.StateCode
    from customerzip as c inner join 
         sashelp.zipcode as z
      on c.ZipCode = put (z.Zip, z5.);
quit;