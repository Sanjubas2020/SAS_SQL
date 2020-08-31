/*subquerry corelated and noncorelated*/
/*Using a Subquery in the WHERE Clause*/
proc sql;
select Name, PopEstimate1
	from sq.statepopulation;
quit;


proc sql;
select avg(PopEstimate1)
    from sq.statepopulation;
quit;

/*combined or use of subquery*/
proc sql;
select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 > (select Name, PopEstimate1 from sq.statepopulation)                          /*Add Subquery Value*/
    order by popEstimate1 desc;
quit;


/*Using a Subquery in the HAVING Clause*/

proc sql;
select avg(PopEstimate1)
	from sq.statepopulation;
quit;


proc sql;
select Division, avg(PopEstimate1) as avgDivisionPop
	from sq.statepopulation
	group by Division
	having avgDivisionPop > 6278420; /*Complete the HAVING clause*/
quit;

proc sql;
select Division, avg(PopEstimate1) as avgDivisionPop
	from sq.statepopulation
	group by Division
	having avgDivisionPop > (select avg(PopEstimate1) from sq.statepopulation);
quit;

/*Subquery That Returns Multiple Values*/
proc sql;
select Division, Name
    from sq.statepopulation
    where Division = '3';
quit;



proc sql;
create table division3 as
select *
	from sq.customer
	where State in ('IL', 'IN', 'MI', 'OH', 'WI'); /*Enter state values*/;
quit;


proc sql;
create table division3 as
select *
	from sq.customer
	where State in (select Name from sq.statepopulation where Division = '3'); /*Enter state values*/
quit;


proc sql number;
select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 < any (select PopEstimate1
                                  from sq.statepopulation
                                  where Name in ("NY","FL"));
quit;

/*Using the ANY Keyword*/
proc sql number;
select Name, PopEstimate1
    from sq.statepopulation
    where PopEstimate1 < (select max(PopEstimate1)
                              from sq.statepopulation
                              where Name in ("NY","FL"));
quit;


/*Using Correlated Subqueries*/
/*-Line Views (Query in the FROM Clause)*/
/*Using Temporary Tables*/
proc sql;
select c.State, 
       c.TotalCustomer, 
       s.EstimateBase, 
       c.TotalCustomer/s.EstimateBase as PctCustomer format=percent7.3
    from (select State,count(*) as TotalCustomer  /* Using an In-Line View */
    		 from sq.customer
    		 group by State
             order by TotalCustomer desc) as c 
       inner join sq.statepopulation as s
    on c.State = s.Name
    order by PctCustomer;
quit;


proc sql;
select c.State, 
       c.TotalCustomer, 
       s.EstimateBase, 
       c.TotalCustomer/s.EstimateBase as PctCustomer format=percent7.3
    from (select State,count(*) as TotalCustomer/* Using an In-Line View */
    		 from sq.customer
    		 group by State) as c 
       inner join sq.statepopulation as s
    on c.State = s.Name
    order by PctCustomer;
quit;

/*Creating a View*/
proc sql;
create view VWtotalcustomer as
select State,count(*) as TotalCustomer
    from sq.customer
    group by State;
quit;


title "Total Customers by States";
proc sql;
select *
    from VWtotalcustomer
	order by TotalCustomer desc;
quit;


proc sgplot data=VWtotalcustomer;
	hbar State / response=TotalCustomer
                 dataskin=crisp
                 categoryorder=respdesc;
    xaxis label="Total Customer Count";
quit;
title;

/*Using a Subquery in the SELECT Clause*/

proc sql;
select Name, PopEstimate1, sum(PopEstimate1) format=comma12.
    from sq.statepopulation;
quit;


proc sql;
select Name, PopEstimate1/sum(PopEstimate1) as PctPop format=percent7.2
    from sq.statepopulation;
quit;


proc sql;
select Name, PopEstimate1/sum(PopEstimate1) as PctPop format=percent7.2
    from sq.statepopulation;
quit;

proc sql;
select Name, PopEstimate1/sum(PopEstimate1) as PctPop format=percent7.2
    from sq.statepopulation
    order by PctPop desc;
quit;

/*Controlling Remerging*/
proc sql noremerge;
select Region, 
       sum(PopEstimate1) as TotalRegion format=comma14.
    from sq.statepopulation;
quit;


proc sql noremerge;
select Region, 
       sum(PopEstimate1) as TotalRegion format=comma14.
    from sq.statepopulation
	group by region;
quit;