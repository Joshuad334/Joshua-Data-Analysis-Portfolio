USE Logistics;

--Creating table to insert datasets via PANDAs

CREATE TABLE dbo.EmployeeDetails
(
    E_ID INT PRIMARY KEY NOT NULL,
    E_NAME VARCHAR(30) NOT NULL,
    E_DESIGNATION VARCHAR(40) NOT NULL,
    E_ADDR VARCHAR(100) NOT NULL,
    E_BRANCH VARCHAR(15) NOT NULL,
    E_CONT_NO INT NOT NULL
);
-------------------------------------------------------------------
CREATE TABLE EmployeeMembership
(
    M_ID INT PRIMARY KEY,
    Start_date DATETIME NULL,
    End_date DATETIME NULL
);

---------------------------------------------------------------------
CREATE TABLE Customer
(
    C_ID INT PRIMARY KEY NOT NULL,
    M_ID INT
        FOREIGN KEY REFERENCES dbo.EmployeeMembership (M_ID) NOT NULL,
    C_NAME VARCHAR(100) NOT NULL,
    C_EMAIL_ID VARCHAR(50) NOT NULL,
    C_TYPE VARCHAR(50) NOT NULL,
    C_ADDR VARCHAR(50) NOT NULL,
    C_CONT_NO BIGINT NOT NULL
);
---------------------------------------------------------------------
CREATE TABLE PaymentDetails
(
    Payment_ID UNIQUEIDENTIFIER NOT NULL,
    C_ID INT NOT NULL,
    SH_ID INT NOT NULL,
    AMOUNT INT,
    Payment_Status VARCHAR(50),
    Payment_Mode VARCHAR(50),
    Payment_Date DATETIME,
);
---------------------------------------------------------------------
CREATE TABLE ShipmentDetails
(
    SH_ID INT PRIMARY KEY NOT NULL,
    C_ID INT
        FOREIGN KEY REFERENCES dbo.Customer (C_ID) NOT NULL,
    SH_DOMAIN VARCHAR(25) NOT NULL,
    SER_TYPE VARCHAR(25) NOT NULL,
    SH_WEIGHT BIGINT NOT NULL,
    SH_CHARGES BIGINT NOT NULL,
    SR_ADDR VARCHAR(50) NOT NULL,
    DS_ADDR VARCHAR(50) NOT NULL
);
---------------------------------------------------------------------
CREATE TABLE ShipmentStatus
(
    SH_ID INT PRIMARY KEY NOT NULL,
    Current_Status VARCHAR(50) NOT NULL,
    Sent_date DATETIME,
    Delivery_date DATETIME
);
---------------------------------------------------------------------
CREATE TABLE EmployeeShipManagement
(
    Employee_E_ID INT
        FOREIGN KEY REFERENCES dbo.EmployeeDetails (E_ID) NOT NULL,
    Shipment_Sh_ID INT
        FOREIGN KEY REFERENCES dbo.ShipmentDetails (SH_ID) NOT NULL,
    Status_Sh_ID INT NOT NULL
);


--. Count the customer base based on customer type to identify current customer preferences and
--  sort them in descending order.


SELECT C_TYPE AS CustomerType,
       COUNT(C_ID) AS CustomerCount
FROM Logistics.dbo.Customer
GROUP BY C_TYPE
ORDER BY C_TYPE;

--  Calculates Customer PaymentCount 
SELECT C.C_NAME AS Name,
       SUM(IIF(PD.Payment_Status = 'PAID', 1, 0)) AS PaidStatusCount,
       SUM(IIF(PD.Payment_Status = 'NOT PAID', 1, 0)) AS NotPaidStatusCount
FROM Logistics.dbo.Payment_Details AS PD
    INNER JOIN Logistics.dbo.Customer AS C
        ON C.C_ID = PD.C_ID
GROUP BY C.C_NAME,
         PD.Payment_Date;


-- Segement Customer Phone Numbers with Dashes 
-- Made CustomerPhone a bigint to throw a monkey wrench for improperly formatted data. 
SELECT C_NAME,
       LEFT(CAST(C_CONT_NO AS VARCHAR(10)), 3) + '-' + SUBSTRING(CAST(C_CONT_NO AS VARCHAR(10)), 3, 3) + '-'
       + RIGHT(CAST(C_CONT_NO AS VARCHAR(10)), 4) AS CustomerPhoneNumber
FROM Logistics.dbo.Customer;



SELECT 
       ED.E_NAME,
       DATEDIFF(YEAR, EM.Start_date, EM.End_date) AS YearsWorked
FROM Logistics.dbo.Employee_Details AS ED
    INNER JOIN Logistics.dbo.EmployeeMembership AS EM
        ON ED.E_ID = EM.M_ID
WHERE ED.E_DESIGNATION LIKE '%Manager%'
ORDER BY YearsWorked DESC;



USE Logistics;
GO

CREATE PROCEDURE dbo.GetCustomerPaymentCount @CustomerID VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
           C.C_ID,
           C.C_NAME AS Name,
           SUM(   CASE
                      WHEN PD.Payment_Status = 'PAID' THEN
                          1
                      ELSE
                          0
                  END
              ) AS PaidStatusCount,
           SUM(   CASE
                      WHEN PD.Payment_Status = 'NOT PAID' THEN
                          1
                      ELSE
                          0
                  END
              ) AS NotPaidStatusCount
    FROM Logistics.dbo.Payment_Details AS PD
        INNER JOIN Logistics.dbo.Customer AS C
            ON C.C_ID = PD.C_ID
    WHERE C.C_ID = @CustomerID
    GROUP BY C.C_NAME,
             C.C_ID;
END;
GO
EXEC dbo.GetCustomerPaymentCount @CustomerID = 230;






