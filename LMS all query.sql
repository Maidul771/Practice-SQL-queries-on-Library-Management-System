--LEVEL 1
--1.List all members with their names and addresses.
select member_id, member_name from members

--2.Show all books with their categories and rental prices.
select isbn, category, rental_price from books

--3.Find all employees and their positions.
select emp_id,emp_name, position from employees

--4.Display all branches with their contact numbers.
select branch_id,contact_no from branch

--5.Show all issued books with issue dates.
select issued_book_name, issued_date from issued_status

--6.List all returned books with return dates.
select return_book_isbn, return_date from return_status

--7.Display all employees working in a specific branch.
select e.emp_id, b.branch_id 
from employees e
join branch b on e.branch_id=b.branch_id
where b.branch_id='B002'

--8.Show all members who have issued at least one book.

--9.List books that are currently marked as 'Available'.
select isbn, status from books where status='yes'
--10.Show members registered after a specific date('2021-12-05')
select member_id, member_name, reg_date from members 
where reg_date >'2021-12-05'

--11.Display all employees with a salary greater than 50,000.
select emp_id, salary from employees where salary>50000;

--12.List books written by a specific author.
select book_title, author from books where author='Harper Lee'

--13.Show all issued books handled by a specific employee(emp_id='E105').
select*from issued_status where issued_emp_id='E105'

--14.Find the number of branches in the library system.
select count(branch_id) as TotalBranch from branch

--15.Show all books with a rental price less than 100.
select book_title, rental_price from books where rental_price<100

--LEVEL 2: CRUD Operations
--Task 1. Create a New Book Record
insert into Books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-0-670-81302-0', 'The Kite Runner', 'Drama',160,'yes','Khaled Hosseini', 'Riverhead Books')
--Task 2: Update an Existing Member's Address
update members
set member_name='Steven smith'
where member_id='C102'
--Task 3: Delete a Record from the Issued Status Table
Delete from issued_status
where issued_id='IS140'
--Task 4: Retrieve All Books Issued by a Specific Employee 'John Doe'
--with subquery
select*from books
where isbn in(select issued_book_isbn from issued_status where issued_emp_id in(select emp_id from employees where emp_name='John Doe' ));
--with join
select*from books b
join issued_status iss on b.isbn=iss.issued_book_isbn
where issued_emp_id='E101'

--LEVEL 3
--Task 1: List Members Who Have Issued at least One or more Book
--with subquery
select m.member_id,m.member_name, 
TotalIssuedBooks=(select count(issued_member_id) from issued_status where issued_book_isbn in(select isbn from books) and issued_member_id =m.member_id) 
from members m
where (select count(issued_member_id) from issued_status where issued_book_isbn in(select isbn from books) and issued_member_id =m.member_id)>=1

--with join
select m.member_id,m.member_name, count(iss.issued_member_id) as TotalIssuedBooks from members m
join issued_status iss on m.member_id=iss.issued_member_id
join books b on iss.issued_book_isbn=b.isbn
group by m.member_id,m.member_name
having count(iss.issued_member_id)>=1

--Task 2: List Members Who Have Issued More Than One Book
--with subquery
select m.member_id,m.member_name, TotalIssuedBook=(select count(issued_member_id) from issued_status where issued_book_isbn in(select isbn from books)and issued_member_id=member_id)
from members m
where (select count(issued_member_id) from issued_status where issued_book_isbn in(select isbn from books)and issued_member_id=member_id)>1

select m.member_id,m.member_name, count(iss.issued_member_id) as TotalIssuedBooks from members m
join issued_status iss on m.member_id=iss.issued_member_id
join books b on iss.issued_book_isbn=b.isbn
group by m.member_id,m.member_name
having count(iss.issued_member_id)>1

--Task 3: List Members Who don't Issued any Book
--with subquery
select m.member_id,m.member_name from members m
where member_id not in(select issued_member_id from issued_status where issued_book_isbn in(select isbn from books))

--with join
select m.member_id,m.member_name from members m
left join issued_status iss on m.member_id=iss.issued_member_id
left join books b on iss.issued_book_isbn=b.isbn
where issued_member_id is null

--Task 4:List all members and the number of books they issued.
select m.member_id, m.member_name,
TotalIssuedBook=(select Count(issued_member_id) from issued_status where issued_book_isbn in(select isbn from books)and issued_member_id=member_id)
from members m

--Task 5:Show all books and their issuing members (if any).
--with subquery
select b.isbn, b.book_title,(select top 1 issued_member_id from issued_status iss where iss.issued_book_isbn=b.isbn) as MemberId
from books b
where b.isbn in(select issued_book_isbn from issued_status where issued_member_id in(select member_id from members))

--with join
select b.isbn, b.book_title, iss.issued_member_id from books b
join issued_status iss on b.isbn=iss.issued_book_isbn
join members m on iss.issued_member_id=m.member_id

--Task 6:Find all employees who issued at least 3 books.
select e.emp_id, e.emp_name, Count(iss.issued_emp_id) as IssuedBook from employees e
join issued_status iss on e.emp_id=iss.issued_emp_id
join books b on iss.issued_book_isbn=b.isbn
group by e.emp_id, e.emp_name
having Count(iss.issued_emp_id)>3

--Task 7:Show all books issued by members from a specific city('678 Pine St').
select b.isbn, b.book_title, m.member_id, m.member_name from books b
join issued_status iss on b.isbn=iss.issued_book_isbn
join members m on iss.issued_member_id=m.member_id
where member_address='678 Pine St'

--Task 8:List all branches and how many employees Per branch they have.
select b.branch_id, count(emp_id) as TotalEmployee from branch b
join employees e on b.branch_id=e.branch_id
group by b.branch_id

--Task 9:List all branches and how many employees they have.
select count(emp_id) as TotalEmployee from branch b
join employees e on b.branch_id=e.branch_id

--Task 10:Find the most expensive book in the library.
select top 1 rental_price as MostExpensiveBook from books
order by rental_price desc

--Task 11:Display all issued books along with their return dates (if returned).
select iss.issued_book_name, rs.return_book_name from issued_status iss
join return_status rs on iss.issued_id=rs.issued_id

--Task 12:Show the total rental income from all issued books.
select Sum(rental_price) as TotalRentalIncome from books

--Task 13:Display the top 5 members who issued the most books.
select top 5 m.member_id,count(iss.issued_member_id) MostIsuuedBook from members m
join issued_status iss on m.member_id=iss.issued_member_id
group by m.member_id
order by count(iss.issued_member_id) desc 

--Task 14:Find all employees who haven’t issued any book.
select emp_id, emp_name from employees
where emp_id not in(select issued_emp_id from issued_status)

--Task 15:Show members and the last book they issued.
select m.member_id,m.member_name, Max(iss.issued_date) as LastIssuedBook from members m
join issued_status iss on m.member_id=iss.issued_member_id
group by m.member_id, m.member_name
--order by Max(iss.issued_date) desc

--Task 16:Display employees and the total number of books they issued.
select e.emp_id, e.emp_name,count(emp_id) as TotalIssuedBook from employees e
join issued_status iss on e.emp_id=iss.issued_emp_id
group by e.emp_id, e.emp_name

--Task 17:List branches with no employees.
select b.branch_id ,e.emp_id from branch b
join employees e on b.branch_id=e.branch_id
where emp_id is null

--Task 18:Find the average salary of all employees.
select count(emp_id) as TotalEmp, sum(salary) as TotalSalary, avg(salary) as Totalavgsalary from employees

--Task 19:Show members who issued books from multiple branches.
select m.member_id, m.member_name, count(distinct b.branch_id) as IssFromMultipleBranch from members m
join issued_status iss on m.member_id=iss.issued_member_id
join employees e on iss.issued_emp_id=e.emp_id
join branch b on e.branch_id=b.branch_id
group by m.member_id, m.member_name
having count(distinct b.branch_id)>1

--Task 20:Find books that were issued more than 3 times.
select count(isbn) as IssuedId, b.book_title from books b
join issued_status iss on b.isbn=iss.issued_book_isbn
group by b.book_title
having count(isbn)>=2

--Task 21:Find the branch that issued the highest number of books.
select b.branch_id ,count(iss.issued_member_id) HighestIssuedBranch from  branch b
join employees e on b.branch_id=e.branch_id
join issued_status iss on e.emp_id=iss.issued_emp_id
group by b.branch_id 

--Task 22:List the top 3 employees who issued the most books.
select top 3 e.emp_id, e.emp_name, count(issued_emp_id) as EMP from employees e
join issued_status iss on e.emp_id=iss.issued_emp_id
group by e.emp_id, e.emp_name 
order by count(issued_emp_id) desc

--Task 23:Show the total salary expense per branch.
select b.branch_id, count(e.emp_id) as TotalEmp, sum(e.salary) TotalSal from employees e
join branch b on e.branch_id=b.branch_id
group by b.branch_id
