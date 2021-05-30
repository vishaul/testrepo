REM @D:\Ex5\a5.sql"
SET ECHO ON;
SET LINESIZE 200;
SET SERVEROUTPUT ON;

REM Q1> Check whether the given model is manufactured by any maker. If
REM available, display the maker full name and country else display:
REM �The given model is not manufactured / Invalid Model�

REM CREATE OR REPLACE PROCEDURE findModel IS
DECLARE
	model model_details.model%TYPE;
	o_country_name countries.country_name%TYPE; 
	o_fullName car_makers.fullName%TYPE;
BEGIN
	model := '&model';

	SELECT country_name, fullname INTO o_country_name, o_fullName
	FROM countries a, car_makers b, model_details c
	WHERE a.country_id = b.country
	AND b.id = c.maker
	AND c.model = model;
	dbms_output.put_line('-----------------------------------------------------------');
	IF SQL%FOUND THEN
		dbms_output.put_line('MODEL ' || model || ' IS MANUFACTURED');
		dbms_output.put_line('Maker name: ' || o_fullName);
		dbms_output.put_line('Country: ' || o_country_name);
	END IF;
EXCEPTION
	WHEN no_data_found THEN
		dbms_output.put_line('The given model is not manufactured / Invalid Model');
	WHEN others THEN
		dbms_output.put_line('Error!');
END;
/

REM Q2> An user is desired to buy a car with the specific mileage. Ask the user for
REM a mileage, and find the car that is equal or closest to the desired mileage.
REM Print the car number, model, description and mileage. Also print the
REM number of car(s) that is equal or closest to the given mileage.

SET SERVEROUTPUT ON;

DECLARE
	o_car_id car_names.id%TYPE;
	o_model car_names.model%TYPE;
	o_carName car_names.descr%TYPE;
	o_mpg car_details.mpg%TYPE;

	mileage car_details.mpg%TYPE;
	close_mpg car_details.mpg%TYPE;
	c NUMBER;

	CURSOR desiredCar IS
		SELECT a.id, a.model, a.descr, b.mpg
		FROM car_names a, car_details b
		WHERE a.id = b.id;

BEGIN
	mileage := &mileage;
	c := 0;
	SELECT MAX(mpg) INTO close_mpg FROM car_details;
	OPEN desiredCar;
		LOOP
			FETCH desiredCar INTO o_car_id, o_model, o_carName, o_mpg;
			EXIT WHEN desiredCar%NOTFOUND;
			IF abs(mileage - o_mpg) < close_mpg THEN
				close_mpg := abs(mileage - o_mpg);
			END IF;
		END LOOP; 
		-- dbms_output.put_line('close mpg: ' || close_mpg);
	CLOSE desiredCar;
	dbms_output.put_line('CAR_ID MODEL                 CAR_NAME               MILEAGE');
	dbms_output.put_line('-----------------------------------------------------------');
	OPEN desiredCar;
		LOOP
			FETCH desiredCar into o_car_id, o_model, o_carName, o_mpg;
			EXIT WHEN desiredCar%NOTFOUND;
			IF abs(mileage - o_mpg) = close_mpg THEN
				dbms_output.put_line(lpad(to_char(o_car_id), 10) ||'    '|| lpad(o_model, 20) ||'  '|| lpad(o_carName, 15) ||'  '||lpad(to_char(o_mpg),10));
				c := c + 1;
			END IF;
		END LOOP;
	CLOSE desiredCar;
	dbms_output.put_line('-----------------------------------------------------------');
	dbms_output.put_line(c || ' car(s) found EQUAL/CLOSEST to given mileage.');
END;
/

REM Qn 3> For a given country name, display the number of cars manufactured in 
REM each model by the car makers as shown below. Check for the availability 
REM of country name

DECLARE
	grand_total NUMBER;
	flag NUMBER;

	cname countries.country_name%TYPE;
	chk_country_name countries.country_name%TYPE;

	CURSOR list IS
		SELECT a.country_name, b.fullName, c.model, count(d.id) total_number
		FROM countries a, car_makers b, model_details c, car_names d
		WHERE a.country_id = b.country (+)
			AND b.id = c.maker (+)
			AND c.model = d.model (+)
		GROUP BY b.fullName, c.model, a.country_name;
		 
BEGIN
	cname := '&cname';
	grand_total := 0;
	flag := -1;
	FOR record in list
	LOOP
		IF record.country_name = cname THEN
			IF flag = -1 and record.total_number != 0 THEN
				dbms_output.put_line('------------------------------------------------------');
				dbms_output.put_line('Country Name: ' || cname);
				dbms_output.put_line(lpad('Maker Name', 25) ||' '|| lpad('Model', 20) ||' '|| lpad('No of Cars', 20));
				dbms_output.put_line('------------------------------------------------------');
				flag := 1;
			ELSIF record.total_number = 0 THEN
				flag := 0;
			END IF;
			IF flag = 1 THEN
				dbms_output.put_line(lpad(record.fullName, 25) ||' '|| lpad(record.model, 20) ||' '|| lpad(to_char(record.total_number), 5) );
				grand_total := grand_total + record.total_number;
			END IF;
		END IF;
	END LOOP;
	IF flag = 0 THEN
		dbms_output.put_line('The country '||cname||' does not produce any cars');
	ELSIF flag = 1 THEN
		dbms_output.put_line('------------------------------------------------------');
		dbms_output.put_line('Total: ' || grand_total);
	ELSE
		dbms_output.put_line('COUNTRY NOT FOUND IN DATABASE');
	END IF;
END;
/

/
/

REM ---------------

